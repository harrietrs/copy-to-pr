# Action pull request copy to another repo
This GitHub Action copies files from the current repository to a branch in another repository and creates a pull request.

This was developed primarily to assist developers restricted to approval before publishing private repository branches.

It heavily borrows from [github-action-push-to-another-repository](https://github.com/cpina/github-action-push-to-another-repository) and [action-pull-request-another-repo](https://github.com/paygoc6/action-pull-request-another-repo) but allows the user to copy over the entire contents of one repo, without copying over GitHub workflow files.

## Workflow 

The user has two repositories in mind:

1. Source repository: where files originate.
2. Destination repository: where the files will be copied and raised as a pull request.

On a push to a specified branch of repository 1, the files from a directory of the reposiotry are copied to a new branch of repository 2, and a pull request is raised.

### Arguments

#### `API_TOKEN_GITHUB`
This GitHub action needs credentials in order to push to the destination repository.

You will need to generate a personal API token:

* Go to [GitHub Personal Access Tokens](https://github.com/settings/tokens)
* Generate a new token, selecting "Repo" as the scope. 
* Copy the token.

For this GitHub Action, you will need to make the token available to the source repository:

* Go to the GitHub page for the source repository. Click on "Settings"
* On the left-hand pane click on "Secrets" then "Actions"
* Click on "New repository secret", giving the name `API_TOKEN_GITHUB` and the value of the token you copied in the steps above.

#### `source-directory` 
The location of the files in the source repository that you want to include in the pull request. Leave this as `./` to include all files (with exceptions listed via the `files-to-remove-path` argument).

#### `destination-github-username` 
The username you want to attach to the pull request.

#### `destination-repository-name` 
The name of the destination repository, including the owner name e.g. owner-name/repository-name. 

#### `destination_directory` 
Destination directory to push the origin directory.

#### `user-email` 
The email used for the commit & pull request.

#### `user-name` 
The name that will be used for the commit and pull request.

#### `destination_head_branch_prefix` 
The prefix for the branch to create to push the changes. The branch name is made from this prefix and a time stamp.

#### `destination_base_branch` 
The branch into which you want your code merged.

#### `files-to-remove-path` 
Relative file path including list of files to not include in PR. Optional and defaults to include all files.

#### `commit-message` 
The commit message to be used in the output repository. Optional and defaults to "Publishing to destination repo".



## Example Workflow
```yml
name: Create PR

name: CI

on:
    push:
        branches: [ main ]

jobs:
  pull-request:
    runs-on: ubuntu-latest
    container: pandoc/latex
    name: A job to create a PR in a separate repo
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Repo PR step
        uses: ./ 
        env:
          API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
        with:
            source_directory: ./ 
            destination_repo: 'user-name/repository-name'
            destination_base_branch: private-branch-name
            destination_head_branch: publish-branch-name
            user_email: user-name@email.com
            user_name: user-name
            files_to_remove_path: filesToRemove.txt
```
