# Action pull request copy to another repo

This GitHub Action copies files from the current repository to a branch in another repository and creates a pull request.

This was developed primarily to assist developers who cannot develop in the open on public repositories. Once private content has been approved for publication, it is otherwise a manual task to copy files over to an existing public repository.

This action heavily borrows from [push-to-another-repository](https://github.com/marketplace/actions/push-directory-to-another-repository), [action-pull-request-another-repo](https://github.com/paygoc6/action-pull-request-another-repo) and [copycat-action](https://github.com/marketplace/actions/copycat-action).

It is different in that it allows the user to easily copy over the entire contents of one repo and raise a pull request on another repo, without copying over GitHub workflow files (or any other files you want to exclude).

## Workflow

The user has two repositories in mind:

1. Source repository: where files originate.
2. Destination repository: where the files will be copied and raised as a pull request.

On a push to a specified branch of repository 1, the files from a directory of the repository are copied to a new branch of repository 2, and a pull request is raised. Any files that you do **not** want to copy can be listed in `.github/workflows/ci_ignore.txt`.

### Arguments

#### `API_TOKEN_GITHUB`

This GitHub action needs credentials in order to push to the destination repository.

You will need to generate a personal API token:

* Go to [GitHub Personal Access Tokens](https://github.com/settings/tokens)
* Generate a new token, selecting "Repo" as the scope.
* Copy the token.

For this GitHub Action, you will need to make the token available to the source repository:

* Go to the GitHub page for the source repository. Click on "Settings"
* On the left_hand pane click on "Secrets" then "Actions"
* Click on "New repository secret", giving the name `API_TOKEN_GITHUB` and the value of the token you copied in the steps above.

#### `destination_repository_name`

The name of the destination repository.

#### `destination_owner`

The owner name e.g. owner_name/repository_name, of the destination repository.

#### `source_directory`

_(Optional)_ The location of the files in the source repository that you want to include in the pull request. Defaults to `/.`, which includes all files (with exceptions listed via the [`files_to_remove_path`](#files_to_remove_path) argument).

#### `destination_directory`

_(Optional)_ Directory where the source directory is copied to. Defaults to "[`{source_directory}`](#source_directory)".

#### `destination_base_branch`

_(Optional)_ The branch into which you want your code merged. Defaults to "main".

#### `user_email`

_(Optional)_ The email used for the commit & pull request. Defaults to "[`{user_name}`](#user_name)@users.noreply.github.com".

#### `user_name`

_(Optional)_ The name that will be used for the commit and pull request. Defaults to the user triggering the action.

#### `files_to_remove_path`

_(Optional)_ Relative file path including list of files to not include in PR. Recommended to use .github/workflows/ci_ignore.txt.

## Example Workflow

```yml
name: Create PR

name: copy-to-pr

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
          GH_TOKEN: ${{ secrets.API_TOKEN_GITHUB }}
        with:
            source_directory: ./ 
            destination_repo: 'repository_name'
            destination_owner: 'user_name'
            destination_base_branch: final_branch_name
```
