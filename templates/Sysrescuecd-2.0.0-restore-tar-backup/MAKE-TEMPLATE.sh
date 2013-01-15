#! /bin/sh -x
# By Martin Cleaver Blended Perspectives - 2013/01/13

BASEDIR=~/SoftwareDevelopment
VEEWEEDIR=$BASEDIR/veewee/
# From https://github.com/megastep/makeself
MAKESELF=$BASEDIR/makeself/makeself.sh
TEMPLATE=Sysrescuecd-2.0.0-restore-tar-backup
SUBTEMPLATE=Debian-6.0.6-amd64-netboot
IMAGE=restore


# --- 

if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
 echo "Using RVM"
 source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
 rvm use ruby-1.9.2@veewee --create
 rvm gemdir
 gem env gemdir

 alias veewee="bundle exec veewee"
 alias vagrant="bundle exec vagrant"
 alias irb="bundle exec irb"
 bundle install
fi


TEMPLATESDIR=$VEEWEEDIR/templates
TEMPLATEDIR=$TEMPLATESDIR/$TEMPLATE
RUNAFTERREBOOTED=run-after-rebooted
SUBTEMPLATEDESTDIR=$TEMPLATEDIR/$RUNAFTERREBOOTED/subtemplate


echo
echo "Using $SUBTEMPLATE for the subtemplate - deposited into $SUBTEMPLATEDESTDIR"
rm $SUBTEMPLATEDESTDIR/*
echo "This folder copied from $SUBTEMPLATE on `date`" > $SUBTEMPLATEDESTDIR/$SUBTEMPLATE
cp -rp $TEMPLATESDIR/$SUBTEMPLATE/* $SUBTEMPLATEDESTDIR/

echo "Packaging up $RUNAFTERREBOOTED:"
cd $TEMPLATEDIR
sh run-after-rebooted-CREATOR.sh $MAKESELF
echo

if [ "$1" = "forcebuild" ]; then
  cd $VEEWEEDIR && veewee vbox define $IMAGE $TEMPLATE --force  && veewee vbox build $IMAGE --force
else 
  echo Usage: $0 forcebuild to tear down and start
fi

