#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cdwm='vim ~/suckless/dwm/config.h'
alias mdwm='cd ~/suckless/dwm; sudo make clean install; cd -'
alias backup='cd ~/suckless/dwm; cp config.h backupconfig; cp config.h config.def.h; cp dwm.c backupdwm; rm -f *.rej *.orig; cd -'
alias battery='cd; cat /sys/class/power_supply/BAT0/capacity; cd -'

PS1='[\u@\h \W]\$ '

fastfetch
