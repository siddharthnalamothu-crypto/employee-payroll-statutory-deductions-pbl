#!/usr/bin/env bash
set -euo pipefail

# Run this script from inside this project folder on the Mac where `gh auth status`
# shows the Siddharth account. It refuses to publish under any other identity.
expected_owner="siddharthnalamothu-crypto"
repo_name="employee-payroll-statutory-deductions-pbl"
full_repo="${expected_owner}/${repo_name}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it, then run: gh auth login" >&2
  exit 1
fi

actual_owner="$(gh api user --jq .login)"
if [[ "${actual_owner}" != "${expected_owner}" ]]; then
  echo "Refusing to publish: expected ${expected_owner}, but gh is logged in as ${actual_owner}." >&2
  exit 1
fi

if [[ -e .git ]]; then
  echo "Refusing to initialize over existing .git metadata. Review this folder first." >&2
  exit 1
fi

if gh repo view "${full_repo}" >/dev/null 2>&1; then
  echo "Refusing to overwrite existing repository: https://github.com/${full_repo}" >&2
  exit 1
fi

account_id="$(gh api user --jq .id)"
git init --initial-branch=main
git config --local user.name "${actual_owner}"
git config --local user.email "${account_id}+${actual_owner}@users.noreply.github.com"
git add -A
git commit -m "Initial employee payroll PBL project"
gh repo create "${full_repo}" --public --source=. --remote=origin --push

visibility="$(gh repo view "${full_repo}" --json visibility --jq .visibility)"
remote_branch="$(git ls-remote --heads origin main)"
if [[ "${visibility}" != "PUBLIC" || -z "${remote_branch}" ]]; then
  echo "Repository creation/push could not be verified. Check https://github.com/${full_repo}" >&2
  exit 1
fi
echo "Verified public repository and main branch: https://github.com/${full_repo}"
