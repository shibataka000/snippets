#!/bin/sh
ZIP_FILE_NAME="lambda_with_git.zip"

ROOT=`pwd`
ZIP_FILE=$ROOT/$ZIP_FILE_NAME

cd $ROOT
zip $ZIP_FILE * -r

# for git
cd /
zip $ZIP_FILE /usr/bin/git
zip $ZIP_FILE /usr/share/git-core -r
zip $ZIP_FILE /usr/lib/git-core -r --symlinks

cd /lib/x86_64-linux-gnu/
zip $ZIP_FILE libpcre.so.3
zip $ZIP_FILE libz.so.1
zip $ZIP_FILE libresolv.so.2
zip $ZIP_FILE libpthread.so.0
zip $ZIP_FILE librt.so.1
zip $ZIP_FILE libc.so.6

cd /lib64
zip $ZIP_FILE ld-linux-x86-64.so.2
