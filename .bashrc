# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

tmlv()
{
    sudo tail -f /var/lib/docker/volumes/myaku_dev_$1_log/_data/$2
}

tpmlv()
{
    sudo tail -f /var/lib/docker/volumes/myaku_$1_log/_data/$2
}

lmlv()
{
    sudo less /var/lib/docker/volumes/myaku_dev_$1_log/_data/$2
}

lpmlv()
{
    sudo less /var/lib/docker/volumes/myaku_$1_log/_data/$2
}

dcc()
{
    container_id="$(sudo docker ps | grep "$1" | awk '{ print $1 }')"
    sudo docker exec -it $container_id /bin/bash
}

# Git aliases
alias gst='git status'
alias gad='git add'
alias gcm='git commit -m'
alias gca='git commit -a -m'
alias gch='git checkout'
alias gsh='git stash'
alias gsp='git stash pop'

# Myaku Docker
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'
alias rup='\
    docker stack deploy \
        -c ~/dev/Myaku/docker/docker-compose.yml \
        -c ~/dev/Myaku/docker/docker-compose.dev.yml \
        myaku_dev \
'
alias prup='\
    docker stack deploy \
        -c ~/dev/Myaku/docker/docker-compose.yml \
        myaku \
'
alias rdwn='docker stack rm myaku_dev'
alias prdwn='docker stack rm myaku'
alias crawlcid='\
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" \
        $(docker service ps -q myaku_dev_crawler) \
'
alias pcrawlcid='\
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" \
        $(docker service ps -q myaku_crawler) \
'
alias rap='docker exec -it $(crawlcid) /bin/bash'
alias prap='docker exec -it $(pcrawlcid) ipython'
alias dbcid='\
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" \
        $(docker service ps -q myaku_dev_crawldb) \
'
alias pdbcid='\
    docker inspect -f "{{.Status.ContainerStatus.ContainerID}}" \
        $(docker service ps -q myaku_crawldb) \
'
alias rdbip='\
    docker network inspect \
    -f "{{(index .Containers \"$(dbcid)\").IPv4Address}}" docker_gwbridge \
    | cut -d "/" -f 1 \
'
alias prdbip='\
    docker network inspect \
    -f "{{(index .Containers \"$(pdbcid)\").IPv4Address}}" docker_gwbridge \
    | cut -d "/" -f 1 \
'
alias rlv='docker volume inspect -f "{{.Mountpoint}}" myaku_dev_crawler_log'
alias prlv='docker volume inspect -f "{{.Mountpoint}}" myaku_crawler_log'
alias rmdangling='docker image rm $(docker images -f "dangling=true" -q)'

export AWS_CONN="ubuntu@ec2-3-15-210-166.us-east-2.compute.amazonaws.com"
alias awsc="ssh -i ~/Downloads/Nick-key-pair-ohio.pem \"$AWS_CONN\""

export AWS_CONN_W="ubuntu@ec2-52-15-90-136.us-east-2.compute.amazonaws.com"
alias awscw="ssh -i ~/Downloads/Nick-key-pair-ohio.pem \"$AWS_CONN_W\""

# Change autocomplete behavior
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'

# Set up virtualenvwrapper for python
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~/dev
source ~/.local/bin/virtualenvwrapper.sh

# Alias for working with git repo for system config files like dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

if [[ ":$PATH:" != *":/home/ruri/.local/bin/dart-sass:"* ]]; then
    export PATH=$PATH:/home/ruri/.local/bin/dart-sass
fi

if [[ ":$PYTHONPATH:" != *":/home/ruri/dev/Myaku:"* ]]; then
    export PYTHONPATH=$PYTHONPATH:/home/ruri/dev/Myaku
fi
if [[ ":$PYTHONPATH:" != *":/home/ruri/dev/Myaku/myakuweb-apiserver:"* ]]; then
    export PYTHONPATH=$PYTHONPATH:/home/ruri/dev/Myaku/myakuweb-apiserver
fi
