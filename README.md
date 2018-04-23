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
* Clone into your ~/bin (create folder if it does not exist already):

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

* Put emails from OTR into the folder set in OTRINCOMINGMAILSPATH, e.g. via another cronjob.

Example rule for maildrop:
```
if (/^From:.*webmaster@onlinetvrecorder\.com/:h)
{
        to "$MAILDIR/.otrAutoDownloader"
}
```
Then, set the OTRINCOMINGMAILSPATH to $MAILDIR/.otrAutoDownloader/cur. I have a script in place which copies the mail from my mailserver to the server which does the downloading and decoding. This is rather short. It uses a sub-folder inside otrAutoDownloader, named $remotePathOld in this script, where old, already parsed mails are stored:
```bash
fileCount=$(/usr/bin/ssh $server "ls $remotePath/cur/" | wc -l)
echo "File Count: $fileCount" >> $logFile
if [ ! "$fileCount" = "0" ]; then
  echo "$fileCount mails on remote server."
  # copy all mails from remotePath to localPath
  /usr/bin/scp -r $server:"$remotePath/cur/*" $localPath

  # move to subfolder
  /usr/bin/ssh $server "mv $remotePath/cur/* $remotePathOld/cur/"
else
  echo "No copying" >> $logFile
fi
```

* Enjoy!
