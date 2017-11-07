@echo off

cd C:\Program Files (x86)\Streamlink\bin

SET /P url=[Please enter the twitch.tv username]
SET /P quality=[Please enter the quality]
SET /P videoID=[Please enter the video ID or live for livestream]

IF %videoID%==live (
    streamlink.exe twitch.tv/%url% %quality%
) ELSE (
    streamlink.exe twitch.tv/%url%/v/%videoID% %quality%
)
