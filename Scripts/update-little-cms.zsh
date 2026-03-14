#!/bin/zsh

##
##  update-little-cms.zsh
##  swift-little-cms
##
##  Created by Fang Ling on 2026/3/14.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##

# This script creates a copy of Little CMS that is suitable for building with
# the Swift Package Manager.
#
# Usage:
#   Run this script in the package root. It will place a local copy of the
#   Little CMS sources in Sources/CLittleCMS.
#   Any prior contents of Sources/CLittleCMS will be deleted.
#

set -euo pipefail

CURRENT_WORKING_DIRECTORY=$(pwd)
TEMPORARY_DIRECTORY=$(mktemp -d /tmp/swift-Little-CMS-XXXXXX)
SOURCE_DIRECTORY="${TEMPORARY_DIRECTORY}/Sources/Little-CMS"
DESTINATION_DIRECTORY="Sources/CLittleCMS"
TRASH_DIRECTORY="${TEMPORARY_DIRECTORY}/Trash"
SOURCES=(
  "*.c"
  "*.h"
)

# Little CMS revision must be passed as the first argument to this script.
if [ "$#" -gt 0 ]; then
  LITTLE_CMS_REVISION="$1"
else
  echo "Usage: $0 <Little-CMS-revision>"
  exit 1
fi

echo "=============================================="
echo "TRASHING any previously-copied Little CMS code"
echo "=============================================="
mkdir -p "${TRASH_DIRECTORY}/CLittleCMS"
mv "${DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/CLittleCMS" || true

echo "===================="
echo "PREPARING Little CMS"
echo "===================="
mkdir -p "${SOURCE_DIRECTORY}"
git clone https://github.com/mm2/Little-CMS.git "${SOURCE_DIRECTORY}"
cd "${SOURCE_DIRECTORY}"
git checkout "${LITTLE_CMS_REVISION}"
cd "${CURRENT_WORKING_DIRECTORY}"

echo "=================="
echo "COPYING Little CMS"
echo "=================="
mkdir -p "${DESTINATION_DIRECTORY}/Little-CMS"
for SOURCE in "${SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/src/"${~SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${DESTINATION_DIRECTORY}/Little-CMS${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
mv \
  "${DESTINATION_DIRECTORY}/Little-CMS/src/"* \
  "${DESTINATION_DIRECTORY}/Little-CMS"
rmdir "${DESTINATION_DIRECTORY}/Little-CMS/src"
mkdir -p "${DESTINATION_DIRECTORY}/include"
cp "${SOURCE_DIRECTORY}/include/"*.h "${DESTINATION_DIRECTORY}/include"
cp "${SOURCE_DIRECTORY}/LICENSE" "${DESTINATION_DIRECTORY}/LICENSE.txt"

echo "============================="
echo "RECORDING Little CMS revision"
echo "============================="
cat << EOF > "${DESTINATION_DIRECTORY}/revision.txt"
This directory is derived from Little CMS
  cloned from https://github.com/mm2/Little-CMS.git
EOF
echo -n "at revision" >> "${DESTINATION_DIRECTORY}/revision.txt"
echo " ${LITTLE_CMS_REVISION}" >> "${DESTINATION_DIRECTORY}/revision.txt"

echo "============================"
echo "CLEANING temporary directory"
echo "============================"
rm -rf "${TEMPORARY_DIRECTORY}"
