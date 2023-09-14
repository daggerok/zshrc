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

##
# Function to simplify git commits by using randomly generated fun commit messages from whatthecommit.com if you just don't want to type anything.
#
# Usage:
#
#   justcommit
#   justcommit 'My meaningful message.'
##
function justcommit() {
  if [[ -z "$1" ]] ; then
    joke="$(curl -s https://whatthecommit.com/index.txt)"
    git commit -am "${joke} (C) whatthecommit.com"
  else
    git commit -am "$1"
  fi
}

##
# Simplify java versions switch.
#
# Usage:
#
#    use jdk 1.8 # or: use 1.8
#    use jdk 17  # or: use 17
#
# Requires:
#   brew reinstall
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

##
# NVM: use latests NodeJS version
##
function use_latest_node {
  export NODE_DIR=$(ls -tr $NVM_DIR/versions/node | head -1)
  export PATH=$NVM_DIR/$NODE_DIR/bin:$PATH
}

use_latest_node

##
# Use specified NodeJS version
#
# Usage:
#
#   setnode $nodeVersion
##
function setnode {
  export NODE_VERSION=${1:-lts} ;
  nvm deactivate
  nvm unalias default
  nvm install $NODE_VERSION ;
  nvm alias default $NODE_VERSION ;
  nvm use $NODE_VERSION ;
  use_latest_node ;
}

##
# Get AWS EC2 IPs
#
# Requires Amazon SDK
##
function aws-ec2-ips() {
   function aws-ec2-ips-usage() {
     echo "Usage:" ;
     echo "" ;
     echo "\taws-ec2-ips io-adtrack-java-a-ondemand" ;
     echo "" ;
     echo "or:" ;
     echo "\taws-ec2-ips io-adtrack-java-a-ondemand" ;
     return 1 ;
   }

   SCALING_GROUP=${1:-undefined}
   if [[ "${SCALING_GROUP}" == "undefined" ]] ; then
     aws-ec2-ips-usage ;
     return $? ;
   fi

   aws ec2 describe-instances --filters "Name=tag:Name,Values=${SCALING_GROUP}" --output json --no-cli-pager --query "Reservations[].Instances[].PrivateIp
Address"
}

##
# SSH into aws machine
#
# Requires
#
#   brew reinstall jq
##
function aws-ec2-ssh() {
    function aws-ec2-ssh-usage() {
        echo "Usage:" ;
        echo "" ;
        echo "\taws-ec2-ssh io-mvpd-java-ue1-ondemand" ;
        echo "" ;
        echo "or:" ;
        echo "\taws-ec2-ssh io-mvpd-java-ue1-ondemand 0" ;
        return 1 ; # error: failed command execution
    }

    SCALING_GROUP=${1:-undefined-scaling-group}
    INSTANCE_INDEX=${2:-undefined-instance-index} ;
    if [[ "${SCALING_GROUP}" == "undefined-scaling-group" ]] ; then
        aws-ec2-ssh-usage ;
        return $? ;
    elif [[ "${INSTANCE_INDEX}" == "undefined-instance-index" ]] ; then
        INSTANCE_INDEX=0 ;
    fi

    AWS_EC2_IPS_JSON=$(aws-ec2-ips $SCALING_GROUP) ;
    AWS_EC2_IPS_BASH_ARRAY=($(echo $AWS_EC2_IPS_JSON | jq -c '.[]')) ;
    INDEX=0 ;
    for IP in ${AWS_EC2_IPS_BASH_ARRAY[@]} ; do
        if [[ $INDEX -eq $INSTANCE_INDEX ]] ; then
          ssh -i ~/.ssh/beachfront_id_rsa $(echo "maksim@$IP" | tr -d '"') ;
          return $? ;
        fi
        ((INDEX++)) ;
    done
    return 1 ; # error: failed command execution
}
