#!/bin/bash

# https://www.shellcheck.net/
# https://itisgood.ru/2024/03/13/chto-takoe-ifs-v-skriptakh-na-bash/

set -e

git config --global user.name "breakcorn"
git config --global user.email "breakcorny@gmail.com"

IFS='.' read -r -a array <<< "$(cat version)"

if git diff-index --quiet HEAD --; then
  echo "There are NO changes to the working directory."
  VERSION="${array[0]}.${array[1]}.${array[2]}"
  echo "Current version $VERSION. Remains unchanged."
  # exit 0
  if [ -n "$(git log origin/$(git branch --show-current)..HEAD)" ]; then
    echo "There are unsent commits."
    git status
  else
    echo "There are NO uncommitted commits."
    git status
    exit 0
  fi
else
  echo "There are changes in the working directory."
  VERSION="${array[0]}.${array[1]}.$((array[2] + 1))"
  echo "The current version has been changed to $VERSION."
  # exit 0
  echo $VERSION > ./version
  git add .
  git status
  git commit -m "${VERSION}"
fi

git branch -M main
git push -u origin main
