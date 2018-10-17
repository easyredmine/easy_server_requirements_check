#!/bin/bash
#Author: Vítezslav Dvořák 2017

DISTRO="UNKNOWN"
VERSION="UNKNOWN"
MEMORYSIZE=""
DISKFREE=0
SCORE=0
MYSQLDEV="n/a"

function WhiteColor() {
  echo -en '\E[37m'"\033[1m$1\033[0m"   # Blue
}

function BlueColor() {
  echo -en '\E[34m'"\033[1m$1\033[0m"   # Blue
}

function RedColor() {
  echo -en '\E[31m'"\033[1m$1\033[0m"   # Red
}

function GreenColor() {
  echo -en '\E[32m'"\033[1m$1\033[0m"   # Green
}

function YellowColor() {
  echo -en '\E[33m'"\033[1m$1\033[0m"   # Yellow
}

function MagentaColor() {
  echo -en '\E[35m'"\033[1m$1\033[0m"   # Magenta
}

function OkMark() {
  echo -en '\E[1;32m'"\033[1m✔\033[0m"
}
function BadMark() {
  echo -en '\E[0;91m'"\033[1m✘\033[0m"
}
function WarningMark() {
  echo -en '\E[1;35m'"\033[1m⚠\033[0m"
}

function commandExists()
{
  if [ `which $1 2>&1 | grep -v ":" | wc -l` == "1" ]; then
    echo true
  else
    echo false
  fi
}


function InstallCurl(){
  if [ $(commandExists curl) == "false" ]; then
    YellowColor "\n Curl not found! Installing: "
    bash -c "sudo $INSTALLER install curl"
    echo
  fi
}

function AdaptToDistro() {
  case "$DISTRO" in
    "Debian" )
      INSTALLER="apt-get -y"
      MINVER="8"
      MYSQLDEV="libmysqlclient-dev"
      INSTQCMD="dpkg -l"
      DEPS="g++ libmagickcore-6.q16-dev libmagickwand-6-headers"
    ;;
    "Ubuntu" )
      INSTALLER="apt-get -y"
      MYSQLDEV="libmysqlclient-dev"
    ;;
    "Rhel" | "Centos" | "centos")
      INSTALLER="yum -y"
      MINVER="7"
      MYSQLDEV="mysql-devel"
    ;;
    *)
      RedColor "Unknown $DISTRO"
    ;;
  esac
}

function CheckRootAccess(){
  WhiteColor "Root access:    "

  if [[ $EUID -ne 0 ]]; then
    if type "sudo" &> /dev/null; then
      BlueColor "with sudo "
      if sudo -S -p '' echo -n < /dev/null 2> /dev/null ;
      then
        GreenColor "allowed " ; OkMark
      else
        RedColor "denied " ; BadMark
      fi
    else
      MagentaColor "unprivileged "
      WarningMark
    fi
  else
    OkMark
  fi
  echo
}

function CheckVersion(){
  WhiteColor "Distro Version: "
  if (( $(echo "${VERSION} ${MINVER}" | awk '{print ($1 >= $2)}') ))
  then
    YellowColor "${VERSION} "; OkMark
  else
    RedColor "${VERSION} "; BadMark
  fi
  echo
}

function CheckDistro() {
  WhiteColor "Distribution:  "
  if [ $(commandExists lsb_release) == "true" ]; then
    DISTRO=`lsb_release -i | awk '{print $3}'`
    VERSION=`lsb_release -r | awk '{print $2}'`
  else # LSB Not present

    if [ -f "/etc/os-release" ] #Debian/OLD Ubuntu
    then
      source /etc/os-release
      VERSION=$VERSION_ID
      DISTRO=$ID
    else #Other Distro
      if [ -f "/etc/debian_version" ] #Debian/OLD Ubuntu
      then
        VERSION=`cat /etc/debian_version`
      else #Other Distro
        RedColor "Unrecognized distro version\n"
      fi
    fi

  fi

  case "$DISTRO" in

    "Ubuntu" | "Debian" | "Redhat" | "Centos" | "centos" )
      YellowColor " ${DISTRO} "; OkMark; echo
    ;;
    *) RedColor "${DISTRO} "; BadMark; echo
    ;;
  esac

  AdaptToDistro
  CheckVersion

}

bytesToHuman() {
  b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
  while ((b > 1024)); do
    d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
    b=$((b / 1024))
    let s++
  done
  echo "$b$d ${S[$s]}"
}


function CheckMemory() {
  WhiteColor "Memory:         "
  OKMEM=4294967296
  BIGMEM=8589934592
  MEMORY=`free -b | sed -n 2p | awk '{ print $2 }'`
  HUMEM=`bytesToHuman $MEMORY`
  YellowColor $HUMEM
  if [ "$MEMORY" -ge "$BIGMEM" ]
  then
    GreenColor " - for large installation "; OkMark
  else
    if [ "$MEMORY" -ge "$OKMEM" ]
    then
      BlueColor " - for small installation"; OkMark
    else
      RedColor " is lower than required "; BadMark
    fi
  fi
  echo
}

function CheckDiskSpace() {
  WhiteColor "Disk space:     "
  OKDISK=10737418240
  BIGDISK=42949672960
  DISKFREE=`df --output=avail | tail -n +2 | sort -n | tail -n1`
  HUDISK=`bytesToHuman $DISKFREE`
  YellowColor $HUDISK
  if [ "$DISKFREE" -ge "$BIGDISK" ]
  then
    GreenColor " - for large installation "; OkMark
  else
    if [ "$DISKFREE" -le "$OKDISK" ]
    then
      BlueColor " - for small installation "; OkMark
    else
      RedColor " is lower than required "; BadMark
    fi
  fi
  echo
}

function CheckPing() {
  if ping -c 3 $1 &> /dev/null
  then
    OkMark
  else
    BadMark
  fi
  echo
}

function CheckCurl() {
  CURL_MAX_CONNECTION_TIMEOUT="-m 100"

  CURL_RETURN_CODE=0
  CURL_OUTPUT=`curl ${CURL_MAX_CONNECTION_TIMEOUT} $1 2> /dev/null` || CURL_RETURN_CODE=$?
  if [ ${CURL_RETURN_CODE} -ne 0 ]; then
    RedColor "Curl connection failed with return code - ${CURL_RETURN_CODE}"; BadMark
  else
    OkMark
  fi
  echo
}


function  CheckGemsConnectivity(){
  RUBYGEMSIP="151.101.194.2" #In 7/2017
  RUBYGEMSHOSTNAME="api.rubygems.org"

  WhiteColor "Ping rubygems.org (IP):    "
  CheckPing $RUBYGEMSIP
  WhiteColor "Ping rubygems.org (DNS):   "
  CheckPing $RUBYGEMSHOSTNAME
  WhiteColor "HTTP rubygems.org:         "
  CheckCurl "http://${RUBYGEMSHOSTNAME}"
  WhiteColor "HTTPS rubygems.org:        "
  CheckCurl "https://${RUBYGEMSHOSTNAME}"
}

function CheckRubyVersion(){
  MINRUBYVER="2.3"
  OKRUBYVER="2.4.3"

  if [ -f "/etc/profile.d/rvm.sh" ]; then
    source /etc/profile.d/rvm.sh

    if type "rvm" &> /dev/null; then
      OkMark
      YellowColor " RVM Detected\n"
      rvm list
    else
      WarningMark
      MagentaColor " RVM Coruppted! Consider reinstall by:"
      WhiteColor  " curl -sSL https://get.rvm.io | bash -s stable "
      echo
    fi
  fi

  if [ $(commandExists ruby) == "true" ]; then
    RUBYVER=`echo 'puts RUBY_VERSION' | ruby`
    WhiteColor "Ruby Installed:            "
    YellowColor "$RUBYVER "
    which ruby | awk '{ printf "%s", $0 }'

    if (( $(echo "${RUBYVER} ${MINRUBYVER}" | awk '{print ($1 >= $2)}') ))
    then
      if (( $(echo "${RUBYVER} ${OKRUBYVER}" | awk '{print ($1 >= $2)}') ))
      then
        GreenColor " Fresh enough  "
      else
        BlueColor  " Consider upgrade  "
      fi
      OkMark
    else
      RedColor " obsolete "
      BadMark
    fi
  else
    RedColor "Ruby not found "
    BadMark
  fi

  echo
}


function CheckMySQL(){
  WhiteColor "MySQL:                     "
  if [ $(commandExists mysql) == "true" ]; then
    YellowColor "MySQL "
    BlueColor "client "

    MYSQLSO=`/sbin/ldconfig -p | grep "mysqlclient.so " | awk '{print $4}'`;
    MYSQLH=`find /usr/ -name 'mysql.h'`

    if [ `echo $MYSQLSO |  wc -l` == "0" ] || [ `echo $MYSQLH | wc -l` == "0" ]
    then
      MagentaColor "Install MySQL Dev by:"
      echo " $INSTALLER $MYSQLDEV "
      WarningMark
    else
      GreenColor "$MYSQLSO $MYSQLH "
      OkMark
    fi

  else
    WarningMark
  fi
  echo
}

function CheckPostgreSQL(){
  WhiteColor "Postgresql:                "
  if [ $(commandExists psql) == "true" ]; then
    YellowColor "PostgreSQL "
    BlueColor "client "
    if type "pg_config" &> /dev/null;
    then
      if [ `find /usr/ -name 'pg_config.h'|wc -l` == "0" ];
      then
        YellowColor " pg_config.h not found "
        WarningMark
      else
        OkMark
      fi
    else
      YellowColor " pg_config not found "
      WarningMark
    fi
  else
    WarningMark
  fi
  echo
}

function CheckDatabase(){
  CheckMySQL
  CheckPostgreSQL
}

function CheckCompiler(){
  WhiteColor "C Compiler:                "
  if [ $(commandExists cc) == "true" ]; then
    CCVER=`cc --version | head -n 1 | awk '{ printf "%s", $0 }'`
    YellowColor "${CCVER} "
    OkMark
  else
    bash -c "sudo $INSTALLER install gcc"
    if [ $(commandExists cc) == "true" ]; then
      CCVER=`cc --version | head -n 1 | awk '{ printf "%s", $0 }'`
      YellowColor "Installed ${CCVER} "
      OkMark
    else
      RedColor "not found "
      BadMark
    fi
  fi
  echo
}

function CheckBundler(){
  CheckCompiler
  WhiteColor "Bundler:                   "

  if [ $(commandExists gem) == "true" ]; then

    if [ `gem list -i bundler` == "true" ]
    then
      BlueColor " gem installed "
      if [ $(commandExists bundle) == "true" ]; then
        GreenColor `bundle --version | awk '{print $3 }'`" "
        which bundle | awk '{ printf "%s", $0 }'
      else
        RedColor "bundle command not found! "
        WarningMark
      fi

    else
      YellowColor "\n gem command found! Installing: "
      gem install bundler
      if [ `gem list -i bundler` == "true" ]
      then
        if [ $(commandExists bundle) == "true" ]; then
          GreenColor `bundle --version | awk '{print $3 }'`" "
          which bundle | awk '{ printf "%s", $0 }'
        else
          RedColor "bundle command not found! "
          WarningMark
        fi
      else
        MagentaColor "gem not installed "
        WarningMark
      fi
    fi

  else
    RedColor "gem command not found! "
    WarningMark
  fi
  echo
}

function CheckImagick(){
  WhiteColor "Imagick development files: "
  if [ $(commandExists Magick-config) == "true" ]; then
    GreenColor `which Magick-config | awk '{ printf "%s", $0 }'`" "
    if [ `find /usr/ -name 'MagickCore.pc'|wc -l` == "0" ];
    then
      YellowColor " MagickCore.pc not found "
      WarningMark
    else
      if [ `find /usr/ -name 'MagickWand.h'|wc -l` == "0" ];
      then
        YellowColor " MagickWand.h not found "
        WarningMark
      else
        OkMark
      fi
    fi
  else
    YellowColor "Magick-config not found"
    WarningMark
  fi
  echo
}

function CheckRedmineInstaller(){
  WhiteColor "Redmine installer:         "
  if [ $(commandExists redmine) == "true" ]; then
    GreenColor `redmine --version | tail -n 1 |  awk '{print $3 }'`" "
    which redmine
  else
    YellowColor "Install it: "
    WhiteColor "gem install redmine-installer --pre"
  fi
  echo
}

MagentaColor "\nEasyRedmine requirements Check\n\n"


CheckRootAccess
CheckDistro
InstallCurl
CheckMemory
CheckDiskSpace
CheckRubyVersion
CheckGemsConnectivity
CheckBundler
CheckDatabase
CheckImagick
CheckRedmineInstaller
