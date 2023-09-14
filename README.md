# zshrc
My ~/.zshrc config

```bash
# just in case backup current local .zshrc config
mv -fv $HOME/.zshrc $HOME/.zshrc-$(date +%Y-%m-%d)-backup
# install new .zshrc file
curl -sS https://raw.githubusercontent.com/daggerok/zshrc/main/.zshrc >> $HOME/.zshrc
```

## Functionality

### git diff

```bash
##
# Function to simplify git diff workflow.
#
# Usage:
#
#   gdiff
#   gdiff 1
#   gdiff 2
#   gdiff 1 2
#   gdiff 2 1
#   gdiff 0 1
#   gdiff 1 0
##
function gdiff() {
  if [[ $# -eq 0 ]] ; then
    git diff HEAD~1 HEAD ;
  elif [[ $# -eq 1 ]] ; then
    git diff "HEAD~$1" HEAD ;
  else
    git diff "HEAD~$1" "HEAD~$2" ;
  fi
}
```

### watch commands

```bash
##
# Function to run any command in watch mode, repetably, each second.
#
# Usage:
# 
#   watch docker ps
##
function watch() {
  if [[ $# -lt 1 ]] ; then
    echo "Usage:\n\twatch <command>" ;
    return ;
  fi

  while :; do clear ; $* ; sleep 1 ; done ;
}
```

### fast and fun git commits

```bash
##
# Function to simplify git commits by using randomly generated fun commit messages from whatthecommit.com if you just don't want to type anything.
#
# Usage:
#
#   justcommit
#   justcommit 'My meaningful message.'
#
# Requires:
#
#   brew reinstall curl git
##
function justcommit() {
  if [[ -z "$1" ]] ; then
    joke="$(curl -s https://whatthecommit.com/index.txt)"
    git commit -am "${joke} (C) whatthecommit.com"
  else
    git commit -am "$1"
  fi
}
```

### easy switch java versions

```bash
##
# Simplify java versions switch.
#
# Usage:
#
#    use jdk 1.8 # or: use 1.8
#    use jdk 17  # or: use 17
#
# Requires:
#
#   brew reinstall temurin temurin17 temurin11 temurin8
##
function use() {
  function usage() {
    echo "Usage:\n\tuse jdk 1.8\nor:\n\tuse 17" ;
    return ;
  }

  if [[ $# -eq 0 ]] ; then
    usage ;
    return -1 ;
  fi

  if [[ $# -eq 2 ]] ; then
    USE_WHAT=${1:-jdk}
    if [[ "$USE_WHAT" != "jdk" ]] ; then
      usage ;
      return -2 ;
    fi
    export JAVA_VERSION=${2:-1.8}
  else
    export JAVA_VERSION=${1:-1.8}
  fi

  export JAVA_HOME=$(/usr/libexec/java_home -v $JAVA_VERSION)
  export PATH=$JAVA_HOME/bin:$PATH
  return 0 ;
}
```
