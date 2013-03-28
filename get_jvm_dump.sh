#!/bin/sh
echo 'JVM dump start.'
echo `date`

now=`date +%Y%m%d%H%M%S`
current_dir=`pwd`

# TomcatのプロセスIDを取得
java_proc_id=`jps | grep Bootstrap | awk -F" " '{ print $1 }'`
if [ "$java_proc_id" = "" ]
then
  echo 'No java process to dump.'
  exit 1
fi
echo "Java Process ID -> $java_proc_id"

# スレッドダンプを出力
echo "Java thread dump start."
jstack $java_proc_id > jstack-$now.log
echo "Java thread dump finish. -> $current_dir/jstack-$now.log created."
