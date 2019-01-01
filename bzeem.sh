#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

error() {
  echo "$@"
  exit 1
}

usage() {
  echo "USAGE:"
  echo "	$0 [-h|--help] [--main=<article>] <zim file>"
  echo ""
  echo "  -h|--help   - displays help"
  exit 2
}

if [ "$(getopt --test >/dev/null 2>&1; echo $?)" -ne "4" ]; then
  error "getopt enchanced required, 'getopt --test' should have exit code 4"
fi

LONG_OPT="help:"
SHORT_OPT="h"
PARSED_OPTS=$(getopt -n "$0" -o "$SHORT_OPT" -l "$LONG_OPT" -- "$@") || usage

eval set -- "$PARSED_OPTS"

# defaults
MAIN=index.htm

while true; do
  case "$1" in
    -h|--help)
      usage;;
    --)
      shift;
      break;;
  esac
done

[ -f "$1" ] || { echo "Missing ZIM file"; usage ; }

# Didn't really consider running this script outside the repo - stuff will be
# written to the $PWD so better check this. You can tell from the quality of
# script that I'm not a fan of shell scripting :)
([ -f ./bzeem.sh ] || [ -d .git ] || [ -f Makefile ]) || error "Must run from checkout! You've been warned."

ZIM_FILE="$(realpath "$1")"

# You never know..
read -p "About to extract $ZIM_FILE and upload it to swarm, good to go (y/n)? " CONT
echo

[ "$CONT" == "y" ] || error "Then don't."

SUM=$(sha256sum "$1" | cut -d ' ' -f1)

# Build extract_zim if needed
[ -f bin/extract_zim ] || make
[ -f bin/extract_zim ] || error "Couldn't build extract_zim"

rm -rf out

# Start by extracting the .zim file

echo Extracting...
MAIN=$(bin/extract_zim "$ZIM_FILE" | grep "Main page" | sed -rn 's/Main page is (.*)/\1/p' | xargs)

echo Done, main page: $MAIN

# extract_zim will write to `out`
cd out

# Zim files store the HTML content in a folder `A` - throw in a default redirect
# page that will take the user there, based on a simple template.
# See
cp ../extras/index.html .

# Redirect to whatever was passed to the script
sed -i "s|MAIN_PAGE|$MAIN|g" index.html

# Zim files contain a full-text search that we're not using, wipe it:
[ -d Z ] && rm -r Z

# Insert an origin declaration - could probably do something nicer in the future...
echo Adding footer...
SHORT_ZIM_FILE=$(basename "$ZIM_FILE")
find -name "*.htm*" -type f -exec sed -i "s|</body>|<p style=\"text-align:center;font-size:10\"><a href=\"https://github.com/arnetheduck/bzeem\">bzeem</a> turned $SHORT_ZIM_FILE (sha256: $SUM) into what you're seeing</p></body>|" {} +

# Now, a bit of a hack - swarm includes date in metadata, but zim does not. Try
# to fetch it from filename instead:
DATE=${ZIM_FILE: -11:7}-01

if date -d $DATE > /dev/null; then
  echo Setting file modification date to: $DATE
  TZ=UTC find . -type f -exec touch -d "$DATE" {} +
else
  echo "Can't parse date from filename: $DATE"
fi

# The only output the swarm version I'm using gives is the hash that points to
# the manifest of the uploaded data. Let's print something more handy..
HASH=$(swarm --recursive --defaultpath "index.html" up .)

cd ..

echo "Done!"
echo "Content hash: $HASH"
echo "Access locally: http://localhost:8500/bzz:/$HASH"
echo "Public gateway: http://swarm-gateways.net/bzz:/$HASH"
