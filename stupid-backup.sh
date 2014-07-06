#!/bin/sh

# stupid-backup -- the world's stupidest backup utility
# Author: Perry E. Metzger
# See the accompanying README.md for instructions, or if it isn't around,
# try https://github.com/pmetzger/stupid-backup

if [ -z "$1" ]
then
    echo "usage: backup hostname..."
fi

# CUSTOMIZE HERE:
# Set "NUM" to the number of days of backups to preserve
# Set "BACKUPDIR" to the directory in which to leave the backup subdirs
NUM=5
BACKUPDIR=$HOME/misc/backups

DATE=`date +"%Y%m%d"`

for i in "$@"
do

HOST=$i
SHOST=$(echo $HOST | sed -r 's/\..+$//g')
DIR=$BACKUPDIR/$SHOST

if [ ! -d $DIR ]
then
    echo making $DIR
    mkdir -p $DIR
fi

cd $DIR

# Note: tar on remote side must be gtar!

/usr/bin/ssh -x -n -lroot $HOST \
   "cd / ; \
    /bin/tar -cf - -X /etc/backup.exc -T /etc/backup.inc | gzip && sleep 1" \
    > $SHOST.$DATE.tgz

if [ $? -gt 0 ]
then
    echo "Backup of $HOST failed."
    rm $SHOST.$DATE.tgz
    echo
    echo Existing backups of $HOST are:

    ls -lth $SHOST.*.tgz

    continue
fi

NUMBER=`ls -t $SHOST.*.tgz | wc -l`

if [ $NUMBER -gt $NUM ]
then
    K=`expr $NUMBER - $NUM`
    rm `ls -t $SHOST.*.tgz | tail -$K`
fi

echo
echo Backups of $HOST are:

ls -lth $SHOST.*.tgz

done
