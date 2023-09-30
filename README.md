# oc.cupsd

![Update oc.cupsd](https://github.com/abcdesktopio/oc.cupsd/workflows/Update%20oc.cupsd/badge.svg)
![Docker Stars](https://img.shields.io/docker/stars/abcdesktopio/oc.cupsd.18.04.svg) 
![Docker Pulls](https://img.shields.io/docker/pulls/abcdesktopio/oc.cupsd.18.04.svg)

## description 

Printer service for abcdesktop.io for kurbernetes
Printer servcice embedded :
- file-service from https://github.com/abcdesktopio/file-service
- printer-service from https://github.com/abcdesktopio/printer-service
- common-libraries from https://github.com/abcdesktopio/oc.user.libraries
- cups configuration files from https://github.com/abcdesktopio/cups


## to clone this repo 
```
git clone git://github.com/abcdesktopio/oc.cupsd
cd oc.cupsd
git submodule update --init --recursive --remote
```
