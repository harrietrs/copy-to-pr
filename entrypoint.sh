#!/bin/sh

set -e
set -x

TIME_ID=$(date +%s)

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

DESTINATION_HEAD_BRANCH=$INPUT_DESTINATION_HEAD_BRANCH_PREFIX$TIME_ID

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

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
               -H $DESTINATION_HEAD_BRANCH \
                  $PULL_REQUEST_REVIEWERS
else
  echo "No changes detected"
fi
