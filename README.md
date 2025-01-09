# Arch setup scripts

1. boot arch usb
2. `curl -o setup.sh https://raw.githubusercontent.com/Link512/ArchSetup/master/setup-install.sh`
3. `chmod 755 setup.sh`
4. `./setup.sh` and provide the proper input (disk to partition, cpu type)
5. `reboot`
6. login into root
7. `cd /root/setup`
8. `./setup-root.sh` and provide required input (video card etc)
9. `logout`
10. login as new user
11. `cd ${HOME}/setup`
12. `chmod 755 usr.sh`
13. `./usr.sh`
14. `reboot`
15. ????
16. profit!!
