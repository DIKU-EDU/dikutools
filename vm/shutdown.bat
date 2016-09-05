echo shutdown -h now > shutdown.txt
putty.exe -P 1337 -ssh root@localhost -pw hamster2 -m shutdown.txt
