otrAutoDownload
===============

Script to download recordings from onlinetvrecorder.com automatically

Set up Rec'n'Go emails to that you receive emails for OTRKEY files in the needed quality and store those mails as plaintext in the folder set in OTRINCOMINGMAILSPATH.

Install
=======
* Install dependencies: curl, aria2 and git (on Ubuntu/Debian:

```bash
 sudo apt-get install curl aria2 git
```

)
* Clone into your ~/bin (create folder if not existing):

```bash
 cd && [ -d bin ] || mkdir bin
 cd ~/bin && git clone https://github.com/wasmitnetzen/otrAutoDownload.git
 cd otrAutoDownload
```

* Edit config file otr.conf and the variable otrAutoDownloadPath in cron.sh:

```bash
 cp otr.conf.sample otr.conf
 nano otr.conf
 nano cron.sh
```

* Setup cronjob:

```bash
 crontab -e
```

* Insert this line (replace $USER):

```
 42 * * * * /home/$USER/bin/otrAutoDownload/cron.sh
```

* Put emails from OTR into the folder set in OTRINCOMINGMAILSPATH, e.g. via a cronjob.

* Enjoy!
