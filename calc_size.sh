#!/bin/sh
TARGET_DIR=$1

for file in `ls $TARGET_DIR`
do
  du -sh $TARGET_DIR/$file
done
