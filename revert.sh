#!/bin/sh

function main() {
  TARGET=/opt/apache-tomcat_ecm
  VERSION=$1

  CURRENT=$TARGET
  PREV=$TARGET$VERSION

  FILENAME=$2

  CURRENT_FILES=(`find_files $CURRENT $FILENAME`)
  if [ ${#CURRENT_FILES[@]} -gt 1 ] ;
  then 
    echo "More than one file found under $CURRENT"
    exit 1
  fi

  PREV_FILES=(`find_files $PREV $FILENAME`)
  if [ ${#PREV_FILES[@]} -gt 1 ] ;
  then
    ecno "More than one file found under $PREV"
    exit 1
  fi

  echo 'Revert start'
  echo "From -> ${CURRENT_FILES[0]}"
  echo "To   ->${PREV_FILES[0]}"
  

  cp -p ${PREV_FILES[0]} ${CURRENT_FILES[0]}
}

function find_files() {
  PARENT=$1
  NAME=$2
  echo `find $PARENT -name $NAME`
}

if [ $# -lt 2 ] ;
then
  echo "Usage : ./revert.sh {Version revert from} {Revert target}"
else
  main $1 $2
fi
