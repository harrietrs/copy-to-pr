#!/bin/sh

set -e
set -x
set -o pipefail

TIME_ID=$(date +%s)

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

if [ -z "$INPUT_DESTINATION_REPO" ]; then
    echo "Destination repo must be defined"
    exit 1
fi

if [ -z "$INPUT_DESTINATION_OWNER" ]; then
    echo "Destination owner must be defined"
    exit 1
fi

DESTINATION_REPO="${INPUT_DESTINATION_OWNER}/${INPUT_DESTINATION_REPO}"
DESTINATION_HEAD_BRANCH="publish_${TIME_ID}"
DESTINATION_FOLDER="${INPUT_DESTINATION_FOLDER:-${INPUT_SOURCE_FOLDER}}"

BASE_PATH=$(pwd)
USERNAME="${INPUT_USER_NAME:-${GITHUB_ACTOR}}"
EMAIL="${INPUT_USER_EMAIL:-${GITHUB_ACTOR}@users.noreply.github.com}"

DESTINATION_BASE_BRANCH="${DST_BRANCH:-main}"

SOURCE_REPO="${GITHUB_REPOSITORY}"
SRC_REPO_NAME="${GITHUB_REPOSITORY#*}"

echo $SRC_REPO_NAME

git config --global user.name "${USERNAME}"
git config --global user.email "${EMAIL}"

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
git config --global user.email "$EMAIL"
git config --global user.name "$USERNAME"

echo "Cloning destination git repository"
git clone "https://$GH_TOKEN@github.com/$DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cp -r $INPUT_SOURCE_FOLDER "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"
cd "$CLONE_DIR"
git checkout -b "$DESTINATION_HEAD_BRANCH"

echo "Adding git commit"
git add .

if [ -z "$INPUT_FILES_TO_REMOVE_PATH" ]
then
  echo "Including all files in PR"
else
  cat $INPUT_FILES_TO_REMOVE_PATH | xargs git rm -rf --cached
fi

if git status | grep -q "Changes to be committed"
then
  git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
  echo "Pushing git commit"
  git push -u origin HEAD:$DESTINATION_HEAD_BRANCH
  echo "Creating a pull request"
  gh pr create -t $DESTINATION_HEAD_BRANCH \
               -b $DESTINATION_HEAD_BRANCH \
               -B $INPUT_DESTINATION_BASE_BRANCH \
               -H $DESTINATION_HEAD_BRANCH 
else
  echo "No changes detected"
fi
