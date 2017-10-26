while true
do
  VBoxManage controlvm Work keyboardputscancode 1c 9c
  sleep $(((RANDOM % 5)  + 1))
done
