
# System wide environment and startup programs

export PS1="\u@\h:\w\\$ "

#core dumps are soft limited to 0 in pam_limit but it does not work for SGE
# - limit it once more!
ulimit -S -c 0

# just once in a session
#----------------------------------------------------------------------------

#we do not want to be called more than once!
test "$PROFILE_DONE" = "yes" && {
  return
}

#everyone allowed just 10000 processes - prevent DoS
ulimit -u 10000 >/dev/null 2>&1           # max processes 10k

# Ulimit virtual memory to 20G if not already limited tighter.
ulimit -S -v 20000000 2>/dev/null


#kill all proceses on exit of shell
shopt -s huponexit

export USER=`id -un`
export LOGNAME=$USER
export MAIL="/var/spool/mail/$USER"
export HOSTNAME=`/bin/hostname`
export EDITOR=vim

shopt -s histappend
export HISTFILESIZE=20000
export HISTSIZE=5000

export HISTCONTROL=ignoreboth

export CVS_RSH=ssh

export INPUTRC=/etc/inputrc

#do not remove! need to avoid recursions
export PROFILE_DONE=yes

# If we're in qlogin or qrsh or something, set tyhe TERM variable to "linux".
# We do this as a workaround for the fact that qlogin does not set the
# TERM variable, which causes "top" to not work, among presumably other things.
# This is really a bug in GridEngine.  If we don't do as follows, the TERM
# gets set to whatever terminal was active when sgeadm was started, which
# can be pretty random.
temp_var=`ps -p "$PPID" -o user= 2>/dev/null`
[ "$temp_var" == sgeadmin -o "$temp_var" == sge-adm ] && export TERM=linux
unset temp_var

# For non-system users, make the shell have nice value at least
# 7.  Note: for shells created via GridEngine this would print an
# error message as their nice value is already 10, so we redirect
# to /dev/null.
[ `id -u` -ge 1000 ] && renice -n 7 -p $$ >&/dev/null

# Complain if users have not set their email field.
[ `id -u` -ge 1000 ] && ! getent passwd $USER | grep '@' >/dev/null && \
  echo "***Your user information does not contain your email!  Use ypchfn to set it (use the Office field.).***" 1>&2;
