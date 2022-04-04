# Automating the Quantitative Analysis of Reproducibility for Build Artifacts derived from the Android Open Source Project -- Recreating the Quantitative Analysis

This repository aims at replicating the results presented in:
- [Manuel Pöll and Michael Roland: *"Automating the Quantitative Analysis of Reproducibility for Build Artifacts derived from the Android Open Source Project"*, in WiSec '22: 15th ACM Conference on Security and Privacy in Wireless and Mobile Networks, San Antonio, TX, USA, ACM, 2022](https://www.digidow.eu/publications/2022-poell-wisec/Poell_2022_WiSec2022_ReproducibilityAOSP.pdf). DOI [10.1145/3507657.3528537](https://doi.org/10.1145/3507657.3528537) (*accepted for publication*)

The [Simple Opinionated AOSP builds by an external Party (SOAP)](https://github.com/mobilesec/reproducible-builds-aosp) project provides a modular automation toolchain to analyze current state and over-time changes of reproducibility of build artifacts derived from the Android Open Source Project (AOSP).
See the linked main project and publication for more details.

In our publication we present a quantitative analysis for a selection of specific AOSP builds.
The `run-wisec-2022.sh` master script in this repository automates the usage of our SOAP project to perform the same builds and analysis operations as we did.


## Manual Setup

The following are the baseline requirements that users need to ensure manually by themselves before running the master script:

1. Start with a Linux distribution with Docker support.
2. Ensure there is at least 750GB of overall storage (in addition to the AOSP storage requirements we need some additional space to store the build and analysis artifacts for the 43 builds).
3. Install Docker (see [here](https://docs.docker.com/engine/install/)).
4. The user account used to run our scripts must be able to execute Docker commands without superuser privileges (see [here](https://docs.docker.com/engine/install/linux-postinstall#manage-docker-as-a-non-root-user)).
5. Install gnuplot, which we use to generate the figures summarizing the quantitative data.
6. Install git.
7. Checkout [this Git repository](https://github.com/mobilesec/reproducible-builds-aosp-wisec) and switch to that folder.
8. Optionally, create a working directory and provide the absolute path via the environment variable `RB_AOSP_BASE`. This directory must exist. If the variable is unset, our framework defaults to `${HOME}/aosp` (which is created automatically if it does not exist).

See [Common Issues](https://github.com/mobilesec/reproducible-builds-aosp#common-issues) in the main repository additional problems that may arise and for solutions to them.


## Execution

Once these manual setup steps are complete, one can simply execute the entrypoint script via

```shell
./run-wisec-2022.sh
```


## Details

In this section we briefly describe the steps taken by the master automation script of this repository.

1. As a safeguard, all of the above preconditions are verified and further execution is refused if any of them is not met.
2. Our [framework repository](https://github.com/mobilesec/reproducible-builds-aosp) is cloned and the version used for this paper is checked out.
3. The Docker images are built. This is done to customize the image with the current, non-root, user.
4. Then, the build and analysis pipelines (Docker containers) are run, parameterized with each of the 28 GSI builds and 15 device builds analyzed in this paper. Note that this takes quite some time, even on powerful hardware.
5. Finally, the metrics are processed into the following output artifacts (located in sub-directories of `RB_AOSP_BASE`):
   - The diff score and weight score metrics for APEX files from the `android-12.0.0_r4` device build are filled into a table, creating Table 1 for our paper.
   - Metrics are aggregated from the summary reports into a time series. These are then processed by gnuplot into the figures presented in our paper. Note that in the paper, only the non-major versions are discussed and shown. The `summary-over-time-device.metric.*.pdf` files correspond to Figure 2 in our paper, `summary-over-time-generic.metric.*.pdf` files correspond to Figure 3.


## Acknowledgements

This work has been carried out within the scope of Digidow, the Christian Doppler Laboratory for Private Digital Authentication in the Physical World and has partially been supported by ONCE (FFG grant FO999887054 in the program ``IKT der Zukunft'') and the LIT Secure and Correct Systems Lab.
We gratefully acknowledge financial support by the Austrian Federal Ministry for Digital and Economic Affairs (BMDW), the Austrian Federal Ministry for Climate Action, Environment, Energy, Mobility, Innovation and Technology (BMK), the National Foundation for Research, Technology and Development, the Christian Doppler Research Association, 3 Banken IT GmbH, ekey biometric systems GmbH, Kepler Universitätsklinikum GmbH, NXP Semiconductors Austria GmbH & Co KG, Österreichische Staatsdruckerei GmbH, and the State of Upper Austria.


## License

Copyright (C) 2022 Johannes Kepler University Linz, Institute of Networks and Security
Copyright (C) 2022 Manuel Pöll

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
