#!/bin/bash

if [ "$(hostname)" != "master" ]; then
  echo "You need to run this script on master"
  exit 1;
fi

echo -n "Please enter the new username (e.g. fbloggs): "
read user

if [ $(echo $user | wc -w) -ne 1 ]; then
  echo "Invalid username $user";
fi

if id $user 2>/dev/null; then
  echo "User $user already exists"
  exit 1;
fi

echo -n "Last user is: "
tail -n 1 /var/yp/ypfiles/passwd || exit 1;

echo -n "Enter new userid: "
read uid

if ! [ $uid -ge 1000 ]; then
  echo "Invalid userid $id (should be >= 1000 for regular user)"
  exit 1;  
fi

if grep -w $uid /var/yp/ypfiles/passwd; then
  echo "Userid $id seems to already be in use."
  exit 1;
fi

echo -n "Please enter the name of the new user (e.g. Fred Bloggs): "
read name

echo -n "Please enter the email address of the new user (e.g. fbloggs@gmail.com): "
read email

gid=$(tail -n 1 /var/yp/ypfiles/passwd | cut -d: -f4)

echo "Will use group-id $gid since it seems to be the most recently used one (ctrl-c if you don't like this)."
if ! [ $gid -gt 1 ]; then
  echo "Invalid group-id $gid"
  exit 1;
fi

echo "$user::$uid:$gid:$name,$email:/home/$user:/bin/bash" >> /var/yp/ypfiles/passwd

cd /var/yp/
if ! make; then
  echo "Error running make in /var/yp; aborting.  Clean it up yourself."
  exit 1;
fi

echo -n "Please enter the hostname where the home directory will be located (e.g. master, or nfs-01, or whatever.): "

read hostname

echo -n "Please enter the volume name (e.g. /mnt/local, or /mnt/ebs1)"

read volume

if ! ssh $hostname df $volume; then
  echo "Bad hostname or volume name (please finish this manually)"
  exit 1;
fi

echo "$user $hostname:$volume/$user" >> /var/yp/ypfiles/auto.home

echo -n "Creating auto.home entry: "
tail -n 1 /var/yp/ypfiles/auto.home

cd /var/yp/
if ! make; then
  echo "Error running make in /var/yp; aborting.  Clean it up yourself."
  exit 1;
fi


echo -n "Creating homedir."
scp -r /etc/skel $hostname:$volume/$user || exit 1;
chown -R $user /home/$user


echo -n "Testing that homedir exists and is accessible to the user"
if ! sudo -u $user touch /home/$user/foo; then
  echo "Error accessing user's homedir."
fi

sudo -u $user rm /home/$user/foo

echo -n "Setting user's password with yppaswd (enter root password then user's new password"
yppasswd $user

