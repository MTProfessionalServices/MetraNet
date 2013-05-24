stcmd.exe co -p "dblair:a3jfj4@lethe/MetraTech/Development" -f NCO -is -rp "E:\builds\tips\Development" /x > output.log 2>&1
copy /y *.gif E:\builds\tips\Development\doxygen\html
doxygen MetraNet.Doxyfile >> output.log 2>&1
