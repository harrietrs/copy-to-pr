#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_DIRECTORY" ]
then
  echo "Source directory must be defined"
  return -1
fi

echo "Setting git variables"
CLONE_DIR=$(mktemp -d)
TIME_ID=$(date +%s)
DESTINATION_HEAD_BRANCH=$INPUT_DESTINATION_HEAD_BRANCH_PREFIX$TIME_ID

export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Copying contents to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_DIRECTORY/
cp -a $INPUT_SOURCE_DIRECTORY "$CLONE_DIR/"
cd "$CLONE_DIR"
git config --global --add safe.directory "$CLONE_DIR"
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
  git commit --message "$INPUT_COMMIT_MESSAGE"
  
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
