#!/bin/bash
# install xcpretty
# brew tap Keithbsmiley/formulae && brew install xcpretty
if [ -z "$1" ]; then
  swift test | xcpretty --color
else
  filter_argument="$1"
  swift test --filter "$filter_argument" | xcpretty --color
fi