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
	if [[ "$#" -ne 0 ]]; then
		echo "Usage: $0"
		exit 1
	fi
    # Reproducible base directory
    if [[ -z "${RB_AOSP_BASE+x}" ]]; then
        # Use default location
        export RB_AOSP_BASE="${HOME}/aosp"
        mkdir -p "${RB_AOSP_BASE}"
    fi
    
    # Guard checks
    if [[ ! -d "$RB_AOSP_BASE" ]]; then
        echo "RB_AOSP_BASE at ${RB_AOSP_BASE} does not exist, not proceeding"
        exit 2
	fi
    local -ri FREE_BYTES="$(df --block-size=1 "${RB_AOSP_BASE}" | awk '$3 ~ /[0-9]+/ { print $4 }')"
    local -ri MIN_BYTES=$(( 900*1000*1000*1000 ))
    if (( FREE_BYTES < MIN_BYTES )); then
        echo "RB_AOSP_BASE at ${RB_AOSP_BASE} has less than ${MIN_BYTES} available, see https://source.android.com/setup/build/requirements#hardware-requirements"
        exit 3
	fi
    if [[ ! -f "${HOME}/.gitconfig" ]]; then
        echo "No git configuration for the logged in user, placing a dummy version into your home directory."
        cp "./gitconfig" "${HOME}/.gitconfig"
    fi
    if ! docker -v; then
        echo "Docker not installed, refer to the official install instructions at https://docs.docker.com/engine/install/ for guidance."
        exit 5
    fi
    if ! id -Gn | grep 'docker'; then
        echo "User is not member of docker group, required for automated docker builds/runs, see https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user ."
        exit 6
    fi
    if ! gnuplot --version; then
        echo "Gnuplot is not installed, required for figure generation."
        exit 7
    fi
    local -r KERNEL_IMAGE="/boot/vmlinuz-$(uname -r)"
    if [[ ! -r "$KERNEL_IMAGE" ]]; then
        echo "Current kernel image at $KERNEL_IMAGE is not world-readable, see \"guestfs can not mount images\" subsection in main repository."
        exit 8
    fi

    # Check out
    declare -r RB_PROJECT="${HOME}/reproducible-builds-aosp"
    declare -r RB_PROJECT_REF="v2.5.1"
    if [[ ! -d "$RB_PROJECT" ]]; then
        git clone "git@github.com:mobilesec/reproducible-builds-aosp.git" "$RB_PROJECT"
    fi

    # Run all subsequent commands in the RB_PROJECT working directory
    (
        cd "$RB_PROJECT"

        git checkout "$RB_PROJECT_REF"

        # Build all docker images locally
        "./docker/build/build-docker-image.sh"
        "./docker/build-legacy/build-docker-image.sh"
        "./docker/analysis/build-docker-image.sh"

        echo "Finished docker image creation"

        # build and analyse generic images
        "./run-generic_fixed.sh" "5854032" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "5910108" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "5981720" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6047694" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6107085" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6174356" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6254317" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6367754" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6462063" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6585897" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6659766" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6730436" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6804618" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6883303" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "6946958" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7003136" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7063984" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7116047" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7177191" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7263945" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7334670" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7416931" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7530437" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7617587" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7697410" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7850077" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7882077" "aosp_x86_64-userdebug"
        "./run-generic_fixed.sh" "7963114" "aosp_x86_64-userdebug"

        echo "Finished build and analysis of generic images"

        # build and analyse device legay images
        "./run_device-legacy_fixed.sh" "android-5.0.0_r3.0.1" "LRX21O" "shamu" "shamu" "shamu-user" "aosp_shamu-user"
        "./run_device-legacy_fixed.sh" "android-5.1.1_r26" "LMY48Y" "shamu" "shamu" "shamu-user" "aosp_shamu-user"
        "./run_device-legacy_fixed.sh" "android-6.0.0_r1" "MRA58K" "shamu" "shamu" "shamu-user" "aosp_shamu-user"
        "./run_device-legacy_fixed.sh" "android-6.0.1_r79" "MOB31T" "shamu" "shamu" "shamu-user" "aosp_shamu-user"
        # build and analyse device images
        "./run_device_fixed.sh" "android-7.1.0_r4" "NDE63P" "marlin" "marlin-user" "aosp_marlin-user"
        "./run_device_fixed.sh" "android-7.1.2_r33" "NZH54D" "marlin" "marlin-user" "aosp_marlin-user"
        "./run_device_fixed.sh" "android-8.0.0_r21" "OPD1.170816.010" "taimen" "taimen-user" "aosp_taimen-user"
        "./run_device_fixed.sh" "android-8.1.0_r40" "OPM4.171019.021.R1" "taimen" "taimen-user" "aosp_taimen-user"
        "./run_device_fixed.sh" "android-9.0.0_r11" "PD1A.180720.030" "crosshatch" "crosshatch-user" "aosp_crosshatch-user"
        "./run_device_fixed.sh" "android-9.0.0_r46" "PQ3A.190801.002" "crosshatch" "crosshatch-user" "aosp_crosshatch-user"
        "./run_device_fixed.sh" "android-10.0.0_r7" "QD1A.190821.007" "coral" "coral-user" "aosp_coral-user"
        "./run_device_fixed.sh" "android-10.0.0_r41" "QQ3A.200805.001" "coral" "coral-user" "aosp_coral-user"
        "./run_device_fixed.sh" "android-11.0.0_r7" "RD1A.200810.020" "redfin" "redfin-user" "aosp_redfin-user"
        "./run_device_fixed.sh" "android-11.0.0_r46" "RQ3A.211001.001" "redfin" "redfin-user" "aosp_redfin-user"
        "./run_device_fixed.sh" "android-12.0.0_r4" "SD1A.210817.015.A4" "raven" "raven-user" "aosp_raven-user"

        echo "Finished build and analysis of device images"
    )

    if cmp --silent "./gitconfig" "${HOME}/.gitconfig"; then
        echo "Removing gitconfig from you home directory again since we placed it there."
        rm "${HOME}/.gitconfig"
    fi

    # Collect metric values for the APEX comparison table
    local -r REPORT_DIR="${RB_AOSP_BASE}/diff/android-12.0.0_r4_raven-user_Google__android-12.0.0_r4_aosp_raven-user_docker-Ubuntu18.04"
    local -r APEX_TABLE_TEMPLATE="./template/table-1_partial.tex"
    local -r APEX_TABLE_DIR="${RB_AOSP_BASE}/apex-table"
    mkdir -p "$APEX_TABLE_DIR"
    "./scripts/generate-apex-table.sh" "$REPORT_DIR" "$APEX_TABLE_TEMPLATE" "$APEX_TABLE_DIR"

    echo "Completed generation of APEX table"

    # Collect metric values from individual builds
    local -r GNUPLOT_DATA_DIR="${RB_AOSP_BASE}/gnuplot-data"
    mkdir -p "$GNUPLOT_DATA_DIR"
    "./scripts/generate-gnuplot-data-files.sh" "${RB_AOSP_BASE}/diff" "$GNUPLOT_DATA_DIR"

    echo "Completed metrics collection from individual builds"

    # Generate figures via gnuplot
    local -r FIGURE_DIR="${RB_AOSP_BASE}/figure"
    mkdir -p "$FIGURE_DIR"
    gnuplot -e "data_folder='${GNUPLOT_DATA_DIR}'" -e "figure_folder='${FIGURE_DIR}'" \
        "./scripts/plot-summary-over-time-device.gnuplot"
    gnuplot -e "data_folder='${GNUPLOT_DATA_DIR}'" -e "figure_folder='${FIGURE_DIR}'" \
        "./scripts/plot-summary-over-time-generic.gnuplot"

    echo "Generated figures via gnuplot"

    echo "All done, see ${RB_AOSP_BASE}/figure for output"
}

main "$@"
