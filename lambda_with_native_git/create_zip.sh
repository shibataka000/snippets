#!/bin/sh
ROOT=`pwd`
ZIP_FILE_NAME="lambda_with_git.zip"
ZIP_FILE=$ROOT/$ZIP_FILE_NAME

cd $ROOT
zip $ZIP_FILE *.py
zip $ZIP_FILE gitconfig
zip $ZIP_FILE git-credentials

# for git
cd /
zip $ZIP_FILE /usr/bin/git
zip $ZIP_FILE /usr/share/git-core -r

cd $ROOT
mkdir usr/libexec -p
cp /usr/libexec/git-core usr/libexec -r
cd usr/libexec/git-core
for f in `ls`
do
    if [ -f $f -a ! $f = "git" ]; then
	diff "git" "$f"
	if [ $? = 0 ]; then
	    echo "ln -sf git $f"
	    rm $f
	    ln -sf git $f
	fi
    fi
done
cd $ROOT
zip $ZIP_FILE usr/libexec/git-core -r --symlinks
rm -r usr

# for git-remote-https
cd /usr/lib64/
zip $ZIP_FILE libcurl.so.4
zip $ZIP_FILE libssh2.so.1
zip $ZIP_FILE libpsl.so.0
zip $ZIP_FILE libcom_err.so.2
zip $ZIP_FILE libssl.so.10
zip $ZIP_FILE libicuuc.so.50
zip $ZIP_FILE libsasl2.so.2
zip $ZIP_FILE libicudata.so.50
zip $ZIP_FILE libstdc++.so.6
zip $ZIP_FILE libselinux.so.1
zip $ZIP_FILE libssl3.so
zip $ZIP_FILE libsmime3.so
zip $ZIP_FILE libnss3.so
zip $ZIP_FILE libnssutil3.so

cd /lib64
zip $ZIP_FILE libexpat.so.1
zip $ZIP_FILE libpcre.so.0
zip $ZIP_FILE libz.so.1
zip $ZIP_FILE libpthread.so.0
zip $ZIP_FILE librt.so.1
zip $ZIP_FILE libc.so.6
zip $ZIP_FILE libidn.so.11
zip $ZIP_FILE libplds4.so
zip $ZIP_FILE libplc4.so
zip $ZIP_FILE libnspr4.so
zip $ZIP_FILE libdl.so.2
zip $ZIP_FILE libgssapi_krb5.so.2
zip $ZIP_FILE libkrb5.so.3
zip $ZIP_FILE libk5crypto.so.3
zip $ZIP_FILE liblber-2.4.so.2
zip $ZIP_FILE libldap-2.4.so.2
zip $ZIP_FILE libcrypto.so.10
zip $ZIP_FILE libkrb5support.so.0
zip $ZIP_FILE libkeyutils.so.1
zip $ZIP_FILE libresolv.so.2
zip $ZIP_FILE libm.so.6
zip $ZIP_FILE libgcc_s.so.1
zip $ZIP_FILE libcrypt.so.1
zip $ZIP_FILE libfreebl3.so
