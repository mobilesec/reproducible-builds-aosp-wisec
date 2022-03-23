#!/usr/bin/env bash

# Copyright 2022 Manuel Pöll
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

set -o errexit -o nounset -o pipefail -o xtrace

main() {
    # Argument sanity check
    if [[ "$#" -ne 3 ]]; then
        echo "Usage: $0 <REPORT_DIR> <APEX_TABLE_TEMPLATE> <APEX_TABLE_DIR>"
        echo "REPORT_DIR: SOAP report directory as input"
        echo "APEX_TABLE_TEMPLATE: Template for APEX table tex code"
        echo "APEX_TABLE_DIR: APEX table tex code as output directory"
        exit 1
    fi
    local -r REPORT_DIR="$1"
    local -r APEX_TABLE_TEMPLATE="$2"
    local -r APEX_TABLE_DIR="$3"

    # Declare output tex file and clear old one
    local -r OUTPUT_TEX_FILE="${APEX_TABLE_DIR}/table-1.tex"
    cp "$APEX_TABLE_TEMPLATE" "$OUTPUT_TEX_FILE"

    local -r SUMMARY_DS_BASENAME="summary.metric.diff-score.csv"
    local -r SUMMARY_WS_BASENAME="summary.metric.weight-score.csv"

    local -r WEIGHT_SCORE_SCALE="3"

    # Retrieve metric values
    if [[ "$( grep './system.img.apexes' "${REPORT_DIR}/${SUMMARY_DS_BASENAME}" | wc --lines )" != "22" ]]; then
        echo "Report directory diff score summary file does not have the expected number of entries for APEX files"
        exit 2
    fi
    local -a DIFF_SCORES
    mapfile -t DIFF_SCORES < <( grep './system.img.apexes' "${REPORT_DIR}/${SUMMARY_DS_BASENAME}" \
        | cut --delimiter=, --fields=2 \
    )
    declare -r DIFF_SCORES

    if [[ "$( grep './system.img.apexes' "${REPORT_DIR}/${SUMMARY_WS_BASENAME}" | wc --lines )" != "22" ]]; then
        echo "Report directory diff score summary file does not have the expected number of entries for APEX files"
        exit 2
    fi
    local -a WEIGHT_SCORES
    mapfile -t WEIGHT_SCORES < <( grep './system.img.apexes' "${REPORT_DIR}/${SUMMARY_WS_BASENAME}" \
        | cut --delimiter=, --fields=4 \
    )
    declare -r WEIGHT_SCORES

    for ((i = 0; i < "${#DIFF_SCORES[@]}"; i++)); do
        DIFF_SCORE="${DIFF_SCORES[$i]}"
        WEIGHT_SCORE="${WEIGHT_SCORES[$i]}"

        local IDX_FORMATTED="$( printf "%02d" $(( i + 1 )) )"
        local DIFF_SCORE_FORMATTED="$( printf "%6d" $DIFF_SCORE )"
        local WEIGHT_SCORE_FORMATTED="$( LC_NUMERIC="en_US.UTF-8" && printf "%.3f" $WEIGHT_SCORE )"

        sed --in-place "s/#DS_${IDX_FORMATTED}/${DIFF_SCORE_FORMATTED}/" "$OUTPUT_TEX_FILE"
        sed --in-place "s/#WS_${IDX_FORMATTED}/${WEIGHT_SCORE_FORMATTED}/" "$OUTPUT_TEX_FILE"
    done
}

main "$@"
