#!/usr/bin/env bash

while true
do
  VBoxManage controlvm work keyboardputscancode 1c 9c
  sleep $(((RANDOM % 5)  + 1))
done
