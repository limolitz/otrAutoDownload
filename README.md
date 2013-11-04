otrAutoDownload
===============

Script to download recordings from onlinetvrecorder.com automatically



Install
=======
* Install dependencies: curl, aria2 and git (on Ubuntu/Debian: ```sudo apt-get install curl aria2 git```
* Clone into your ~/bin: 
```
cd ~/bin && git clone https://github.com/wasmitnetzen/otrAutoDownload.git
```
* Fetch submodule:
```
git submodule init && git submodule update
```
* Edit config file otr.conf and the variable otrAutoDownloadPath in cron.sh
* Setup IFTTT. Clone this recipe: https://ifttt.com/recipes/126421
* Setup Dropbox Uploader after https://github.com/andreafabrizi/Dropbox-Uploader/blob/master/README.md
* Setup cronjob:
```
crontab -e
```
* Insert this line (replace $USER):
```
42 * * * * /home/$USER/bin/otrAutoDownload/cron.sh
```
* Enjoy!
