#!/bin/bash
set -eu

GIT_USER_NAME=${1}
GIT_USER_EMAIL=${2}
PACKAGE_MANAGER=${3}
VERSION_TYPE=${4}
BASE_BRANCH=${5}
BRANCH=${6}
PR_DESCRIPTION=${7}
PUSH_OPTIONS=${8}

if [ "${PACKAGE_MANAGER}" == 'npm' ]; then
  npm version --no-git-tag-version ${VERSION_TYPE}
elif [ "${PACKAGE_MANAGER}" == 'yarn' ]; then
  yarn version --no-git-tag-version "--${VERSION_TYPE}"
fi

if [ -n "${PR_DESCRIPTION}" ]; then
  DESCRIPTION=${PR_DESCRIPTION}
else 
  DESCRIPTION="chore: bump ${VERSION_TYPE} version ($(date -I))"
fi

if [ -n "${BRANCH}" ]; then
  PR_BRANCH=${BRANCH}
else 
  PR_BRANCH=chore/version-$(date +%s)
fi

if [ -z "${BASE_BRANCH}" ]; then
  BASE_BRANCH="master"
fi

git config user.name ${GIT_USER_NAME}
git config user.email ${GIT_USER_EMAIL}
git checkout -b ${PR_BRANCH}
git commit -am "${DESCRIPTION}"
git push ${PUSH_OPTIONS} origin ${PR_BRANCH}

curl -fsSL https://github.com/github/hub/raw/master/script/get | bash -s 2.14.1
bin/hub pull-request -m "${DESCRIPTION}" -b "${BASE_BRANCH}"
