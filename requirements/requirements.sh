#!/bin/bash

set -o errexit
set -o pipefail

venv=$(mktemp -d)

## Set mydir to the directory containing the script
## The ${var%pattern} format will remove the shortest match of
## pattern from the end of the string. Here, it will remove the
## script's name,. leaving only the directory. 
mydir="${0%/*}"

function cleanup () {
  rm -rf $venv
}

trap cleanup EXIT

pip install virtualenv
virtualenv $venv -p /usr/bin/python
${venv}/bin/pip install -r $mydir/requirements.in.txt

${venv}/bin/pip freeze --quiet > $mydir/requirements.txt