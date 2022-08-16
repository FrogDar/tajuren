#!/usr/bin/env bash

# Copyright 2022 Charlie Chiang.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

PREVIOUS_SHA_FILE="sha256sum.txt"

# find public -type f -exec sha256sum {} \; > public/sha256sum.txt

FILE_LIST=($(cat "${PREVIOUS_SHA_FILE}" | awk -F '  ' '{ print $2 }'))
SHA_LIST=($(cat "${PREVIOUS_SHA_FILE}" | awk -F '  ' '{ print $1 }'))

for (( i=0; i<${#FILE_LIST[@]}; i++ ));
do
    CURRENT_FILE="${FILE_LIST[$i]}"
    CURRENT_SHA="${SHA_LIST[$i]}"
    ACTUAL_SHA=$(sha256sum "${CURRENT_FILE}" |  awk -F '  ' '{ print $1 }')
    if [[ "${ACTUAL_SHA}" == "${CURRENT_SHA}" ]]; then
        echo "${CURRENT_FILE} hasn't changed since last update, will not be uploaded."
        rm -f "${CURRENT_FILE}"
    fi
done
