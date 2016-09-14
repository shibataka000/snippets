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

# for git-remote-https
cd /lib/x86_64-linux-gnu/
zip $ZIP_FILE libpcre.so.3
zip $ZIP_FILE libz.so.1
zip $ZIP_FILE libresolv.so.2
zip $ZIP_FILE libpthread.so.0
zip $ZIP_FILE libc.so.6
zip $ZIP_FILE libgcrypt.so.11
zip $ZIP_FILE libgpg-error.so.0
zip $ZIP_FILE libcom_err.so.2
zip $ZIP_FILE libdl.so.2
zip $ZIP_FILE libkeyutils.so.1
zip $ZIP_FILE libcrypt.so.1

cd /usr/lib/x86_64-linux-gnu/
zip $ZIP_FILE libcurl-gnutls.so.4
zip $ZIP_FILE libidn.so.11
zip $ZIP_FILE librtmp.so.0
zip $ZIP_FILE libgnutls.so.26
zip $ZIP_FILE libgssapi_krb5.so.2
zip $ZIP_FILE liblber-2.4.so.2
zip $ZIP_FILE libldap_r-2.4.so.2
zip $ZIP_FILE libtasn1.so.6
zip $ZIP_FILE libp11-kit.so.0
zip $ZIP_FILE libkrb5.so.3
zip $ZIP_FILE libk5crypto.so.3
zip $ZIP_FILE libkrb5support.so.0
zip $ZIP_FILE libsasl2.so.2
zip $ZIP_FILE libgssapi.so.3
zip $ZIP_FILE libffi.so.6
zip $ZIP_FILE libheimntlm.so.0
zip $ZIP_FILE libkrb5.so.26
zip $ZIP_FILE libasn1.so.8
zip $ZIP_FILE libhcrypto.so.4
zip $ZIP_FILE libroken.so.18
zip $ZIP_FILE libwind.so.0
zip $ZIP_FILE libheimbase.so.1
zip $ZIP_FILE libhx509.so.5
zip $ZIP_FILE libsqlite3.so.0
