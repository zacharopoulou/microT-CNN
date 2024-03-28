# microT-CNN
microT-CNN is the latest version of the DIANA-microT-CDS model. Is a next-generation, Deep Convolutional Neural Network (DCNN) framework that fills the existing gap of the multifaceted miRNA-targeting problem by providing functional (non-)canonical previously neglected miRNA binding events, leveraging the high-yield AGO-CLIP tissue-specific miRNA-binding accuracy, and the miRNA-target functionality from gene expression experiments

The tool is free to use under MIT licence, please cite:

!!!

microT-CNN was funded by “ELIXIR-GR: ... "

![Figure2](https://github.com/zacharopoulou/microT-CNN/assets/44471936/a863ba3f-2d1c-49c4-8534-da6edbd8913f)

# Installation

## Docker

microT-CNN is available as a Docker image in the public repository of Docker Hub under the name of penny0lane/microt_cnn. Inside the image all the scripts are available under the /R/ directory. /Inputs/ directory contains phastcons .Finally, under /microt_temp there are 4 test sample sets allowing for a test run upon loading the image on a container. This is the recommended way of running this tool, as there is no need for any complex dependency installations.


- Follow the installation instructions on the docker website to install docker on your machine.

  If you are a user in an HPC or cluster and do not have root access, ask the IT administrator to install Docker for you and to follow this guide (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) in order to allow your user to run Docker commands without the need for root access or sudo.

- Start a container using the microT-CNN image from Docker Hub and run the container with the Volume.


- Main function of algorithm

  @:R/: Rscript main.R /microt_temp/config.yml

