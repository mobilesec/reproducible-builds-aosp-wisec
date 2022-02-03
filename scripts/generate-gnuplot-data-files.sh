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

generateDataFiles() {
    local -a METRIC_DIFF_SCORE_IDENTIFIERS=( \
        "metric.diff-score" \
        "metric.major-diff-score" \
    )
    local -a METRIC_WEIGHT_SCORE_IDENTIFIERS=( \
        "metric.weight-score" \
        "metric.major-weight-score" \
    )

    for ((i = 0; i < "${#METRIC_DIFF_SCORE_IDENTIFIERS[@]}"; i++)); do
        local DATA_FILE="${DATA_DIRECTORY}/summary-${IDENTIFIER}.${METRIC_DIFF_SCORE_IDENTIFIERS[$i]}.dat"
        rm -f "$DATA_FILE"

        for ARTIFACT in "${ARTIFACTS[@]}"; do
            local HEADER_LINE AOSP_TAG_OR_BUILD_ID BUILD_DATE REPORT_DIR
            local SUMMARY_FILEPATH DIFF_SCORE

            local NON_ZERO_DIFF_SCORE=false
            for ((j = 0; j < "${#REPORT_DIRS[@]}"; j++)); do
                REPORT_DIR="${REPORT_DIRS[$j]}"

                SUMMARY_FILEPATH="${DIFF_DIR}/${REPORT_DIR}/summary.${METRIC_DIFF_SCORE_IDENTIFIERS[$i]}.csv"
                if cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT},"; then
                    DIFF_SCORE="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=2")"
                    if [[ "$DIFF_SCORE" != "0" ]]; then
                        NON_ZERO_DIFF_SCORE=true
                        break
                    fi
                fi
            done

            if [[ "$NON_ZERO_DIFF_SCORE" == true ]]; then
                HEADER_LINE="\"BUILD\" \"DATE\" \"${ARTIFACT}\""
                echo "${HEADER_LINE}" >> "$DATA_FILE"
                for ((j = 0; j < "${#REPORT_DIRS[@]}"; j++)); do
                    AOSP_TAG_OR_BUILD_ID="${AOSP_TAG_OR_BUILD_IDS[$j]}"
                    BUILD_DATE="${BUILD_DATES[$j]}"
                    REPORT_DIR="${REPORT_DIRS[$j]}"

                    SUMMARY_FILEPATH="${DIFF_DIR}/${REPORT_DIR}/summary.${METRIC_DIFF_SCORE_IDENTIFIERS[$i]}.csv"
                    if cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT},"; then
                        DIFF_SCORE="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=2")"
                        if [[ "$DIFF_SCORE" != "0" ]]; then
                            echo "\"${AOSP_TAG_OR_BUILD_ID}\" \"${BUILD_DATE}\" ${DIFF_SCORE}" >> "$DATA_FILE"
                        else
                            # 0.5 as magic value, special plotting logic to visualize on log scale, see gnuplot scripts
                            echo "\"${AOSP_TAG_OR_BUILD_ID}\" \"${BUILD_DATE}\" 0.5" >> "$DATA_FILE"
                        fi
                    else
                        echo "\"${AOSP_TAG_OR_BUILD_ID}\" \"${BUILD_DATE}\" NA" >> "$DATA_FILE"
                    fi
                done

                echo "" >> "$DATA_FILE"
                echo "" >> "$DATA_FILE"
            fi
        done
    done

    for ((i = 0; i < "${#METRIC_WEIGHT_SCORE_IDENTIFIERS[@]}"; i++)); do
        local DATA_FILE="${DATA_DIRECTORY}/summary-${IDENTIFIER}.${METRIC_WEIGHT_SCORE_IDENTIFIERS[$i]}.dat"
        rm -f "$DATA_FILE"

        for ARTIFACT in "${ARTIFACTS[@]}"; do
            local HEADER_LINE AOSP_TAG_OR_BUILD_ID BUILD_DATE REPORT_DIR
            local SUMMARY_FILEPATH SIZE_ALL SIZE_CHANGED WEIGHT_SCORE

            local NON_ZERO_WEIGHT_SCORE=false
            for ((j = 0; j < "${#REPORT_DIRS[@]}"; j++)); do
                REPORT_DIR="${REPORT_DIRS[$j]}"

                SUMMARY_FILEPATH="${DIFF_DIR}/${REPORT_DIR}/summary.${METRIC_WEIGHT_SCORE_IDENTIFIERS[$i]}.csv"
                if cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT},"; then
                    WEIGHT_SCORE="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=4")"
                    if [[ "$WEIGHT_SCORE" != "0" ]]; then
                        NON_ZERO_WEIGHT_SCORE=true
                        break
                    fi
                fi
            done

            if [[ "$NON_ZERO_WEIGHT_SCORE" == true ]]; then
                HEADER_LINE="\"BUILD\" \"DATE\" \"SIZE_ALL\" \"SIZE_CHANGED\" \"${ARTIFACT}\""
                echo "${HEADER_LINE}" >> "$DATA_FILE"
                for ((j = 0; j < "${#REPORT_DIRS[@]}"; j++)); do
                    AOSP_TAG_OR_BUILD_ID="${AOSP_TAG_OR_BUILD_IDS[$j]}"
                    BUILD_DATE="${BUILD_DATES[$j]}"
                    REPORT_DIR="${REPORT_DIRS[$j]}"

                    SUMMARY_FILEPATH="${DIFF_DIR}/${REPORT_DIR}/summary.${METRIC_WEIGHT_SCORE_IDENTIFIERS[$i]}.csv"
                    if cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT},"; then
                        SIZE_ALL="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=2")"
                        SIZE_CHANGED="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=3")"
                        WEIGHT_SCORE="$( cat ${SUMMARY_FILEPATH} | grep "./${ARTIFACT}," | cut "--delimiter=," "--fields=4")"
                        echo "\"${AOSP_TAG_OR_BUILD_ID}\" \"${BUILD_DATE}\" ${SIZE_ALL} ${SIZE_CHANGED} ${WEIGHT_SCORE}" >> "$DATA_FILE"
                    else
                        echo "\"${AOSP_TAG_OR_BUILD_ID}\" \"${BUILD_DATE}\" NA NA NA" >> "$DATA_FILE"
                    fi
                done

                echo "" >> "$DATA_FILE"
                echo "" >> "$DATA_FILE"
            fi
        done
    done
}

main() {
	# Argument sanity check
	if [[ "$#" -ne 2 ]]; then
		echo "Usage: $0 <DIFF_DIR>"
		echo "DIFF_DIR: SOAP report directory as input"
        echo "DATA_DIRECTORY: Gnuplot data files as output directory"
		exit 1
	fi
	local -r DIFF_DIR="$1"
    local -r DATA_DIRECTORY="$2"

	# Declare data file and clear old one
	rm -f "${DATA_DIRECTORY}/summary.metric"*

	# Device
    local IDENTIFIER="device"
    local -a AOSP_TAG_OR_BUILD_IDS=( \
        "...-5.0.0\_r3.0.1" \
        "...-5.1.1\_r26" \
        "...-6.0.0\_r1" \
        "...-6.0.1\_r79" \
        "...-7.1.0\_r4" \
        "...-7.1.2\_r33" \
        "...-8.0.0\_r21" \
        "...-8.1.0\_r40" \
        "...-9.0.0\_r11" \
        "...-9.0.0\_r46" \
        "...-10.0.0\_r7" \
        "...-10.0.0\_r41" \
        "...-11.0.0\_r7" \
        "...-11.0.0\_r46" \
        "...-12.0.0\_r4" \
    )
	local -a BUILD_DATES=( \
        "2014-11-07" \
        "2015-10-22" \
        "2015-09-16" \
        "2017-01-25" \
        "2016-10-05" \
        "2017-06-29" \
        "2017-09-01" \
        "2018-06-11" \
        "2018-08-23" \
        "2019-06-18" \
        "2019-08-27" \
        "2020-06-11" \
        "2020-08-26" \
        "2021-08-14" \
        "2021-09-02" \
    )
	local -a REPORT_DIRS=( \
        "android-5.0.0_r3.0.1_shamu-user_Google__android-5.0.0_r3.0.1_aosp_shamu-user_docker-Ubuntu14.04" \
        "android-5.1.1_r26_shamu-user_Google__android-5.1.1_r26_aosp_shamu-user_docker-Ubuntu14.04" \
        "android-6.0.0_r1_shamu-user_Google__android-6.0.0_r1_aosp_shamu-user_docker-Ubuntu14.04" \
        "android-6.0.1_r79_shamu-user_Google__android-6.0.1_r79_aosp_shamu-user_docker-Ubuntu14.04" \
        "android-7.1.0_r4_marlin-user_Google__android-7.1.0_r4_aosp_marlin-user_docker-Ubuntu18.04" \
        "android-7.1.2_r33_marlin-user_Google__android-7.1.2_r33_aosp_marlin-user_docker-Ubuntu18.04" \
        "android-8.0.0_r21_taimen-user_Google__android-8.0.0_r21_aosp_taimen-user_docker-Ubuntu18.04" \
        "android-8.1.0_r40_taimen-user_Google__android-8.1.0_r40_aosp_taimen-user_docker-Ubuntu18.04" \
        "android-9.0.0_r11_crosshatch-user_Google__android-9.0.0_r11_aosp_crosshatch-user_docker-Ubuntu18.04" \
        "android-9.0.0_r46_crosshatch-user_Google__android-9.0.0_r46_aosp_crosshatch-user_docker-Ubuntu18.04" \
        "android-10.0.0_r7_coral-user_Google__android-10.0.0_r7_aosp_coral-user_docker-Ubuntu18.04" \
        "android-10.0.0_r41_coral-user_Google__android-10.0.0_r41_aosp_coral-user_docker-Ubuntu18.04" \
        "android-11.0.0_r7_redfin-user_Google__android-11.0.0_r7_aosp_redfin-user_docker-Ubuntu18.04" \
        "android-11.0.0_r46_redfin-user_Google__android-11.0.0_r46_aosp_redfin-user_docker-Ubuntu18.04" \
        "android-12.0.0_r4_raven-user_Google__android-12.0.0_r4_aosp_raven-user_docker-Ubuntu18.04" \
    )
    local -a ARTIFACTS=( \
        "android-info.txt" \
        "boot.img.ramdisk.img" \
        "dtbo.img" \
        "product.img" \
        "recovery.img.ramdisk.img" \
        "super_empty.img" \
        "system.img" \
        "system_ext.img" \
        "system_other.img" \
        "vbmeta.img" \
        "vendor.img" \
    )

    generateDataFiles

	# Generic
    local IDENTIFIER="generic"
    # TDDO: Add 7963114
    local -a AOSP_TAG_OR_BUILD_IDS=( \
        "5854032" \
        "5910108" \
        "5981720" \
        "6047694" \
        "6107085" \
        "6174356" \
        "6254317" \
        "6367754" \
        "6462063" \
        "6585897" \
        "6659766" \
        "6730436" \
        "6804618" \
        "6883303" \
        "6946958" \
        "7003136" \
        "7063984" \
        "7116047" \
        "7177191" \
        "7263945" \
        "7334670" \
        "7416931" \
        "7530437" \
        "7617587" \
        "7697410" \
        "7850077" \
        "7882077" \
        "7963114" \
    )
	local -a BUILD_DATES=( \
        "2019-09-05" \
        "2019-10-01" \
        "2019-11-01" \
        "2019-12-04" \
        "2020-01-02" \
        "2020-02-01" \
        "2020-03-02" \
        "2020-04-06" \
        "2020-05-05" \
        "2020-06-12" \
        "2020-07-02" \
        "2020-08-03" \
        "2020-09-01" \
        "2020-10-05" \
        "2020-11-02" \
        "2020-12-01" \
        "2021-01-05" \
        "2021-02-01" \
        "2021-03-01" \
        "2021-04-07" \
        "2021-05-04" \
        "2021-06-02" \
        "2021-07-08" \
        "2021-08-06" \
        "2021-09-02" \
        "2021-10-24" \
        "2021-11-04" \
        "2021-12-02" \
    )
	local -a REPORT_DIRS=( \
        "5854032_aosp_x86_64-userdebug_Google__5854032_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "5910108_aosp_x86_64-userdebug_Google__5910108_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "5981720_aosp_x86_64-userdebug_Google__5981720_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6047694_aosp_x86_64-userdebug_Google__6047694_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6107085_aosp_x86_64-userdebug_Google__6107085_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6174356_aosp_x86_64-userdebug_Google__6174356_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6254317_aosp_x86_64-userdebug_Google__6254317_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6367754_aosp_x86_64-userdebug_Google__6367754_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6462063_aosp_x86_64-userdebug_Google__6462063_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6585897_aosp_x86_64-userdebug_Google__6585897_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6659766_aosp_x86_64-userdebug_Google__6659766_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6730436_aosp_x86_64-userdebug_Google__6730436_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6804618_aosp_x86_64-userdebug_Google__6804618_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6883303_aosp_x86_64-userdebug_Google__6883303_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "6946958_aosp_x86_64-userdebug_Google__6946958_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7003136_aosp_x86_64-userdebug_Google__7003136_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7063984_aosp_x86_64-userdebug_Google__7063984_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7116047_aosp_x86_64-userdebug_Google__7116047_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7177191_aosp_x86_64-userdebug_Google__7177191_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7263945_aosp_x86_64-userdebug_Google__7263945_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7334670_aosp_x86_64-userdebug_Google__7334670_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7416931_aosp_x86_64-userdebug_Google__7416931_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7530437_aosp_x86_64-userdebug_Google__7530437_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7617587_aosp_x86_64-userdebug_Google__7617587_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7697410_aosp_x86_64-userdebug_Google__7697410_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7850077_aosp_x86_64-userdebug_Google__7850077_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7882077_aosp_x86_64-userdebug_Google__7882077_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
        "7963114_aosp_x86_64-userdebug_Google__7963114_aosp_x86_64-userdebug_docker-Ubuntu18.04" \
    )
    local -a ARTIFACTS=( \
        "android-info.txt" \
        "cache.img" \
        "ramdisk-debug.img" \
        "ramdisk.img" \
        "super_empty.img" \
        "system.img" \
        "userdata.img" \
        "vbmeta.img" \
        "vendor.img" \
        "VerifiedBootParams.textproto" \
    )

    generateDataFiles
}

main "$@"
