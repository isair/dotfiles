#!/usr/bin/env python3
"""Export and restore a dotfiles profile through a GitHub gist."""

import argparse
import base64
import binascii
import json
import os
from pathlib import Path, PureWindowsPath
import re
import shutil
import subprocess
import tempfile
from urllib.parse import urlparse


PROFILES_ROOT = Path(__file__).resolve().parent.parent / "profiles"
GIST_FILENAME = "dotfiles-profile.json"
PROFILE_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*\Z")
GIST_ID_PATTERN = re.compile(r"[0-9a-fA-F]{20,40}\Z")
MAX_PAYLOAD_BYTES = 10 * 1024 * 1024


class ProfileError(Exception):
    pass


def profile_name(value):
    if (not isinstance(value, str) or not PROFILE_PATTERN.fullmatch(value)
            or value in (".", "..") or PureWindowsPath(value).is_reserved()):
        raise ProfileError(f"Invalid profile name: {value}")
    return value


def gist_id(value):
    if value.startswith("https://"):
        url = urlparse(value)
        if url.hostname != "gist.github.com" or url.query or url.fragment:
            raise ProfileError("Expected a gist.github.com URL or gist ID")
        value = url.path.strip("/").split("/")[-1]
    if not GIST_ID_PATTERN.fullmatch(value):
        raise ProfileError("Expected a gist.github.com URL or gist ID")
    return value


def safe_relative_path(raw_path):
    if not isinstance(raw_path, str):
        raise ProfileError("Invalid file path in profile archive")
    parts = raw_path.split("/")
    if ("secure" in parts or any(
            part in ("", ".", "..") or "\\" in part or ":" in part
            or part.endswith((".", " ")) or PureWindowsPath(part).is_reserved()
            or any(ord(char) < 32 for char in part)
            for part in parts)):
        raise ProfileError(f"Unsafe profile path: {raw_path}")
    return parts


def run_gh(*args, input_text=None):
    try:
        result = subprocess.run(
            ["gh", *args], input=input_text, text=True, capture_output=True, check=True
        )
    except FileNotFoundError as exc:
        raise ProfileError("GitHub CLI (gh) is required") from exc
    except subprocess.CalledProcessError as exc:
        raise ProfileError(f"gh {' '.join(args[:2])} failed: {exc.stderr.strip()}") from exc
    return result.stdout


def export_profile(name):
    name = profile_name(name)
    source = PROFILES_ROOT / name
    if not source.is_dir() or source.is_symlink():
        raise ProfileError(f"Profile does not exist: {name}")

    files = {}
    for directory, dirnames, filenames in os.walk(source, followlinks=False):
        relative_dir = Path(directory).relative_to(source)
        dirnames[:] = sorted(d for d in dirnames if d != "secure")
        for dirname in dirnames:
            if (Path(directory) / dirname).is_symlink():
                raise ProfileError(f"Cannot upload symlink: {relative_dir / dirname}")
        for filename in sorted(filenames):
            path = Path(directory) / filename
            relative = path.relative_to(source).as_posix()
            if filename == ".DS_Store":
                continue
            if path.is_symlink():
                try:
                    target = path.resolve(strict=True).relative_to(PROFILES_ROOT.resolve())
                except (OSError, ValueError) as exc:
                    raise ProfileError(f"Cannot upload symlink outside profiles: {relative}") from exc
                if target.parts[0] not in (name, "shared") or "secure" in target.parts:
                    raise ProfileError(f"Cannot upload symlink outside profile or shared files: {relative}")
            if not path.is_file():
                raise ProfileError(f"Cannot upload non-regular file: {relative}")
            safe_relative_path(relative)
            files[relative] = base64.b64encode(path.read_bytes()).decode("ascii")

    if not files:
        raise ProfileError(f"Profile has no files to upload: {name}")
    payload = json.dumps(
        {"format": "isair-dotfiles-profile", "version": 1, "profile": name, "files": files},
        sort_keys=True,
        separators=(",", ":"),
    )
    if len(payload.encode("utf-8")) > MAX_PAYLOAD_BYTES:
        raise ProfileError("Profile exceeds the 10 MiB gist payload limit")
    return run_gh("gist", "create", "-", "--filename", GIST_FILENAME,
                  "--desc", f"dotfiles profile: {name}", input_text=payload).strip()


def decode_profile(payload):
    if len(payload.encode("utf-8")) > MAX_PAYLOAD_BYTES:
        raise ProfileError("Gist payload exceeds 10 MiB")
    try:
        data = json.loads(payload)
    except ValueError as exc:
        raise ProfileError("Gist is not a valid profile archive") from exc
    if not isinstance(data, dict) or data.get("format") != "isair-dotfiles-profile" or data.get("version") != 1:
        raise ProfileError("Gist is not a supported dotfiles profile archive")
    name = profile_name(data.get("profile", ""))
    contents = data.get("files")
    if not isinstance(contents, dict) or not contents:
        raise ProfileError("Gist profile has no files")
    decoded = {}
    for raw_path, encoded in contents.items():
        if not isinstance(encoded, str):
            raise ProfileError("Invalid file entry in gist")
        safe_relative_path(raw_path)
        try:
            decoded[raw_path] = base64.b64decode(encoded, validate=True)
        except (binascii.Error, ValueError) as exc:
            raise ProfileError(f"Invalid file content: {raw_path}") from exc
    return name, decoded


def restore_profile(gist, requested_name=None, replace=False):
    identifier = gist_id(gist)
    payload = run_gh("gist", "view", identifier, "--filename", GIST_FILENAME, "--raw")
    archived_name, files = decode_profile(payload)
    name = profile_name(requested_name) if requested_name else archived_name
    destination = PROFILES_ROOT / name
    if destination.is_symlink() or (destination.exists() and not destination.is_dir()):
        raise ProfileError(f"Profile path is not a directory: {destination}")
    if destination.exists() and not replace:
        raise ProfileError(f"Profile already exists: {name}; use --replace to keep a copy and restore")
    previous = PROFILES_ROOT / f"{name}.pre-gist-restore"
    if destination.exists() and (previous.exists() or previous.is_symlink()):
        raise ProfileError(f"Previous profile backup already exists: {previous}")

    PROFILES_ROOT.mkdir(parents=True, exist_ok=True)
    staged = Path(tempfile.mkdtemp(prefix=".gist-restore-", dir=PROFILES_ROOT))
    try:
        for relative, content in files.items():
            path = staged.joinpath(*relative.split("/"))
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
        if destination.exists():
            destination.rename(previous)
        try:
            staged.rename(destination)
        except OSError:
            if previous.exists():
                previous.rename(destination)
            raise
    finally:
        if staged.exists():
            shutil.rmtree(staged)
    return destination, previous if previous.exists() else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    backup = commands.add_parser("backup", help="Create an unlisted gist from a local profile")
    backup.add_argument("profile")
    restore = commands.add_parser("restore", help="Restore a profile from a gist")
    restore.add_argument("gist", help="Gist ID or gist.github.com URL")
    restore.add_argument("--profile", help="Save under a different profile name")
    restore.add_argument("--replace", action="store_true", help="Keep the old profile as .pre-gist-restore")
    args = parser.parse_args()
    try:
        if args.command == "backup":
            print(export_profile(args.profile))
        else:
            destination, previous = restore_profile(args.gist, args.profile, args.replace)
            print(f"Restored profile to {destination}")
            if previous:
                print(f"Previous profile saved at {previous}")
    except ProfileError as exc:
        parser.exit(1, f"Error: {exc}\n")


if __name__ == "__main__":
    main()
