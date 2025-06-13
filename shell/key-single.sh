#!/bin/bash
# Generate Cloudfront Key
# exit 0 -> Failed, exit 1 -> Success
# Private key upload to your backend server Cloudfront will use this key to sign all the urls before servering images to users
# Public key upload to cloudfront key section. Cloudfront will use this key to verify that the image is not expired and authorized to view
# https://www.youtube.com/watch?v=EIYrhbBk7do
environment="dev"
appName="doggys"
folder="../private/cloudfront_keys"

# How to install openssl
# brew install openssl


# create_Keys arg1 arg2
create_Keys() {
  if [ -z "$1" ] || [ -z "$2" ];
  then
    echo "Arg is empty"
    exit 1
  fi

  fileNamePrivate="$folder/$1-$2-private-key.pem"
  fileNamePublic="$folder/$1-$2-public-key.pem"
  # How to generate cloudfron key
  if [ -e "$fileNamePrivate" ] || [ -e "$fileNamePublic" ]
  then
    echo "File already exist. Please delete it to continue"
  else
    echo "About to create $1 private key"
    sleep 1
    # Don't add the 2048 at the end creates weird bug with cloudfront
    openssl genrsa -out "$fileNamePrivate"

    echo "About to create $1 public key from private key"
    sleep 1
    openssl rsa -pubout -in "$fileNamePrivate" -out "$fileNamePublic"
  fi
}


create_Keys "$appName" "$environment"