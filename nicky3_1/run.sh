#!/bin/bash
rm -rf /tmp/processing
mkdir /tmp/processing
/Users/martin/processing-java --output=/tmp/processing/ --force --sketch=$1 --run
