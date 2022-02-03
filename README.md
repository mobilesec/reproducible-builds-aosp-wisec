
# `Automating the Quantitative Analysis of Reproducibility for Build Artifacts derived from the Android Open Source Project` - Recreating the Quantitative Analysis

This repository accompanies the following scientific publication:
- Manuel Pöll and Michael Roland. 2022. Automating the Quantitative Analysis of Reproducibility for Build Artifacts derived from the Android Open Source Project. In WiSec ’22: 15th ACM Conference on Security and Privacy in Wireless and Mobile Networks, May 16–19, 2022, San Antonio, Texas, USA. ACM, New York, NY, USA, 13 pages. https://doi.org/10.1145/xxxxxxx.xxxxxxx

The [Simple Opinionated AOSP builds by an external Party (SOAP)](https://github.com/mobilesec/reproducible-builds-aosp) project is a framework to build AOSP according to the documented instructions and compare built artifacts against reference images by Google, resulting in SOAP difference reports about uncovered quantitative differences. See the linked main project and publication for more details.

In our publication we present a quantitative analysis for a selection of specific AOSP builds. The `run-soap-wisec-2022.sh` master script in this repository automates the usage of our SOAP project to perform the same builds and analysis operations as we did.

## Manual Setup

The following are the baseline requirements that users need to ensure manually by themselves before running the master script:

1. Start with a Linux distribution with Docker support.
2. Ensure there is at least 400GB of free storage (according to the [current recommendation for AOSP builds by Google](https://source.android.com/setup/build/requirements\#hardware-requirements)).
3. Install Docker (see [here](https://docs.docker.com/engine/install/)).
4. The user account used to run our scripts must be able to execute Docker commands without superuser privileges (see [here](https://docs.docker.com/engine/install/linux-postinstall/\#manage-docker-as-a-non-root-user)).
5. Install gnuplot, which we use to generate the figures summarizing the quantitative data.
6. Install git.
7. Checkout [this Git repository](https://github.com/mobilesec/reproducible-builds-aosp-wisec) and switch to that folder.
8. Optionally, create an empty working directory and provide the absolute path via the environment variable `RB_AOSP_BASE`. This directory must exist and be empty. If the variable is unset, our framework defaults to `${HOME}/aosp` (which is created automatically if it does not exist).

## Execution

Once these manual setup steps are complete, one can simply execute the entrypoint script via

```shell
./run-wisec-2022.sh
```

## Details

In this section we briefly describe the steps taken by the master automation script of this repository.

1. As a safeguard, all of the above preconditions are verified and further execution is refused if any of them is not met.
2. Our [framework repository](https://github.com/mobilesec/reproducible-builds-aosp) is cloned and the version used for this paper is checked out.
3. The Docker images are built. This is done to customize the image with the same, non-root, user.
4. Then, the build and analysis pipelines (Docker containers) are run, parameterized with each of the 28 GSI builds and 15 device builds analyzed in this paper. Note that this takes quite some time, even on powerful hardware.
5. Finally, the metrics are aggregated from the summary reports into a time series. These are then processed by gnuplot into the figures presented in this paper.
