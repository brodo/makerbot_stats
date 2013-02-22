#!/usr/bin/env bash

# script name: findtty.sh
# author: Jerry Davis
#
# this little script determines what usb tty was just plugged in
# on osx especially, there is no utility that just displays what the usb
# ports are connected to each device.
#
# I named this script findtty.sh
# if run interactively, then it prompts you to connect the cable and either press enter or   it will timeout after 10 secs.
# if you set up an alias to have it run non-interactively, then it will just sleep for 10 secs.
# either way, this script gives you 10 seconds to plug in your device

# if run non interactively, a variable named MCPUTTY will be exported, this would be an advantage.
# it WAS an advantage to me, otherwise this would have been a 4 line script. :)
#
# to set up an alias to run non-interactively, do this:
#   osx: $ alias findtty='source findtty.sh',
#   or linux: $ alias findtty='. findtty.sh' (although source might still work)

\ls -1 /dev/tty* > before.tty.list

if [ -z "$PS1" ]; then
    read -s -n1 -t 10 -p "Connect cable, press Enter: " keypress
    echo
else
    sleep 10
fi

\ls -1 /dev/tty* > after.tty.list

ftty=$(diff before.tty.list after.tty.list 2> /dev/null | grep '>' | sed 's/> //')
echo $ftty
rm -f before.tty.list after.tty.list
export MCPUTTY=$ftty                     # this will have no effect if running interactively