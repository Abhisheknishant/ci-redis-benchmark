#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]] ; then
    ./linux_install.sh
elif [[ "$TRAVIS_OS_NAME" == "osx" ]] ; then
    ./macos_install.sh
fi
