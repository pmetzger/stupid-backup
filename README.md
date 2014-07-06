# A Stupid Backup System

## What is this?

Ever have a very minimal Unix server (say a DNS server or firewall)
that has more configuration than you can afford to lose, but which
doesn't need a complicated backup program?

You want to back it up over the network to a management machine, but
most backup solutions will take more than five minutes to
install. What to do?

Stupid Backup is your solution!

It's a very simple shell script that's trivial to understand and
modify. It more or less just reads a list of host names on the command
line, ssh's to each box in turn, tars up things you feel need backing
up, and saves those tar files on the local machine in a directory for
each remote host.

It keeps a few days (five by default) of the tar files on hand, and is
smart enough not to remove any old backups if the host is unreachable.

Just edit one or two lines, throw it into cron, and go!

## How To Use It

You can be up and running in about five minutes. Really!

First, the account you run this from needs to be able to log in over
ssh without a password as root to the machines being backed up.

The only sane way to do this is public key authentication, with the
local account's public key on a line in the remote machine's root
account's `.ssh/authorized_keys` file.

(You can check that this was done correctly by then doing

    ssh root@remotehost echo hi

If that works without asking for a password, you're good to go.)

Second, there are also two lines near the top of the `stupid-backup`
shell script that you can edit.

One sets the variable `NUM` to the number of days of backups to
keep. It is set to five by default. Feel free to change it if you like.

The other, `BACKUPDIR`, sets the directory on the current machine in
which to keep the backups. *You will need to edit that one.*

(It should also go without saying that the directory the variable
points to needs to exist.)

Third, *every remote machine being backed up* will also need two files
in that machine's `/etc` directory. One is `/etc/backup.inc`, which
needs a set of lines saying which directories to back up. For example:

    etc
    var
    root
    u/perry

The second is a file named `/etc/backup.exc`, which is a set of files
and directories in the included directories *not* to back up. For
example:

    etc/postfix/*.db
    var/db
    var/run/*
    var/spool/postfix/private/*
    var/spool/postfix/public/*
    var/tmp/*

`backup.inc` and `backup.exc` are just fed as command line options to
`tar`, so there's nothing at all special about how they work.

Once you have edited `stupid-backup` and have set up the `backup.inc`
and `backup.exc` files on each box, and made sure the local machine
can ssh without a password to the root account on the remote machine,
you can test that everything is working this way (replace "host1" etc.
with the names of the machines you are backing up):

    stupid-backup host1 host2 host3

When you are sure that works, just put a line in the crontab for the
account doing the backups that looks sort of like this:

15 2 * * *	/home/youraccount/bin/stupid-backup host1 host2 host3

E-mail will be sent to that account every night listing the hosts that
have been backed up and showing the backup files that are present.

## History

Years ago, I (Perry Metzger) needed to back up a couple of boxes, and
most solutions available seemed to be designed for doing complicated
incremental backup schemes across a large number of machines. That was
far more than I required.

I hacked this together instead in a few minutes. It has served me well
ever since, with minimal changes.

## License

Stupid Backup is too stupid to claim rights to, so I have dedicated it
to the public domain.

<p xmlns:dct="http://purl.org/dc/terms/"
xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png"
    style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law,
  <span resource="[_:publisher]" rel="dct:publisher">
    <span property="dct:title">Perry E. Metzger</span></span>
  has waived all copyright and related or neighboring rights to
  <span property="dct:title">Stupid Backup</span>.
This work is published from:
<span property="vcard:Country" datatype="dct:ISO3166"
      content="US" about="[_:publisher]">
  United States</span>.
</p>

## Feedback

I'm actively interested in comments, suggestions and improvements to
this program. Please let me know, either with a bug report on Github
or by email. (My address is "perry" at the domain "piermont.com")
