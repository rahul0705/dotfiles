# GitLab CI

`.gitlab-ci.yml` mirrors the GitHub workflows while retaining GitHub Actions.
It targets GitLab.com hosted Linux and macOS runners.

| GitHub check | GitLab equivalent |
| --- | --- |
| Ubuntu, Python 3.9 and latest 3.x | Two Ubuntu 24.04 Docker jobs, using uv-managed Python 3.9 and latest 3 |
| macOS, Python 3.9 and latest 3.x | Two `macos-26-xcode-26` jobs on `saas-macos-medium-m1` |
| Real developer-profile install | Validate, plan, and apply with isolated HOME; initialize pinned submodules |
| actionlint | Pinned actionlint container scans the GitHub workflows |
| zizmor | Pinned CLI scans the GitHub workflows offline; findings fail the job |
| Dependency Review | Remains GitHub-only; no equivalent dependency graph review is configured |
| CodeQL default setup | Remains GitHub-only; not defined in the GitHub workflow files |

Compatibility runs for merge requests targeting the default branch, pushes to
that branch, schedules on that branch, and manually started web pipelines.
Automation scans use the same MR/default-branch push events and changed-file
filter as GitHub, extended to the GitLab configuration and helper script.
All jobs share a stage and run independently; new commits cancel interruptible
jobs. Compatibility jobs retain the 30-minute timeout.

## GitLab setup

- Enable GitLab.com hosted runners. macOS hosted runners require eligible access
  through Premium, Ultimate, or the open source program. See
  [hosted macOS runners](https://docs.gitlab.com/ci/runners/hosted_runners/macos/).
- Set the GitLab default branch to `main` to match GitHub.
- Create a pipeline schedule for the default branch with `0 8 * * 6` and UTC
  timezone, matching GitHub's Saturday 08:00 UTC run. Schedules are project
  settings and cannot be created by the YAML file.
- Require successful pipelines in the GitLab merge settings if desired.

Linux jobs install the same tmux, Vim, Zsh, and VS Code prerequisites, then run
Etch as an unprivileged user with CI-only passwordless sudo. This lets VS Code
install extensions normally and lets the Starship installer use its default
location. The macOS jobs redirect casks to a temporary app directory and retain
the existing Homebrew bootstrap/evaluate/reapply sequence.

`.gitlab/ci/etch-compatibility.sh` is shared by the Linux/macOS jobs to avoid
maintaining two copies of the install sequence. It bootstraps the selected
Python with pinned uv before replacing HOME. It deletes its temporary directory
on exit. These jobs must run on disposable hosted runners: applications and
system packages installed by the profile extend beyond HOME.

GitLab cannot execute GitHub marketplace actions. The linter CLIs provide local
failure gates, but this config does not upload SARIF to GitHub or reproduce
Dependency Review, CodeQL, or Dependabot. Zizmor's offline scan cannot perform
online checks that require the GitHub API. None of those checks should be
considered replaced by a green GitLab pipeline.

## Validation

The configuration passed the official GitLab CI JSON schema, YAML parsing,
shell syntax checks, and a mocked Linux/macOS execution of the shared script.
The mocks check isolated HOME, cask app-directory handling, submodule setup,
and validate/plan/apply order. Hosted runner execution still needs a GitLab
pipeline; local Docker execution was unavailable because Docker was stopped.
