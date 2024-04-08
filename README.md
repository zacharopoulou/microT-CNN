# microT-CNN
microT-CNN is the latest version of the DIANA-microT-CDS model. It is a next-generation, Deep Convolutional Neural Network (DCNN) framework that addresses the multifaceted miRNA-targeting problem. It provides functional (non-)canonical miRNA binding events, leveraging high-accuracy AGO-CLIP tissue-specific miRNA-binding data and miRNA-target functionality from gene expression experiments. Additionally, the multi-layer sequence-based design enables the prediction of both host and viral-encoded miRNA interactions, providing for the first time up to 67%  of direct genuine EBV- and KSHV-derived miRNA target pairs corresponding to 1 out of 4 viral encoded miRNA binding events.

The tool is freely available under the MIT license. If you use microT-CNN in your research, please cite:
""

microT-CNN was funded by “ELIXIR-GR: ... " !!!!

![Figure2](https://github.com/zacharopoulou/microT-CNN/assets/44471936/a863ba3f-2d1c-49c4-8534-da6edbd8913f)

## Installation

### Docker

microT-CNN is available as a Docker image in the public repository of Docker Hub under the name `penny0lane/microt_cnn`. Inside the image, all the scripts are available under the `/R/` directory. The `/hg38/` directory contains phastCons files. Finally, under `/microt_temp/`, there are 4 test sample sets allowing for a test run upon loading the image into a container. This is the recommended way of running this tool as there is no need for complex dependency installations.

You can use `microt_temp` as a volume for connection between the Docker image and your local machine. Place the necessary files for the algorithm to run in `microt_temp`, and the results will be saved there as well.

#### Installation Steps:

1. Follow the [installation instructions](https://docs.docker.com/get-docker/) on the Docker website to install Docker on your machine.
   - If you do not have root access (e.g., on an HPC or cluster), ask the IT administrator to install Docker for you and follow [this guide](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) to allow your user to run Docker commands without needing root access or sudo.
2. Start a container using the microT-CNN image from Docker Hub and run the container with the volume mounted for `microt_temp`.
```bash
docker run -v /path/to/local/microt_temp:/microt_temp penny0lane/microt_cnn

### Main Function of the Algorithm

To run the main function of the algorithm, execute the following command inside the Docker container:

```bash
@:R/: Rscript main.R /microt_temp/config.yml


