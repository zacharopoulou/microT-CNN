# microT-CNN
microT-CNN is the latest version of the DIANA-microT-CDS model. An avant-garde next-generation Deep Convolutional Neural Network framework designed to address the complexity of miRNA targeting and to provide the whole spectrum of the miRNA interactome. By leveraging a multi-layered CNN design and incorporating data from over 60,000 miRNA binding sites from direct AGO-CLIP-seq experiments, chimeric miRNA-target fragments, and more than 70 tissue-matched miRNA perturbation experiments, microT-CNN accurately identifies (non-)canonical miRNA binding events, within the 3’ UTR and CDS regions. The multi-agent CNN framework learns hidden miRNA binding patterns within the MRE regions, the miRNA-binding structure, as well as accessibility and conservation footprints of the miRNA-targeted region. This approach facilitates the extraction of informative, hidden patterns separately in 3’ UTR and CDS regions and detects both canonical and non-canonical miRNA binding events, including previously neglected 3’ compensatory miRNA pairings, capturing the whole spectrum of interactions. miRNA binding sites from 3’ UTR and CDS regions are aggregated in a GBM meta-learner, trained on miRNA targets derived from miRNA transfection experiments to predict functional targets. 

The tool is freely available under the MIT license. If you use microT-CNN in your research, please cite:
""

microT-CNN was funded by:
"HERE"

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
```

#### Main Function of the Algorithm

To run the main function of the algorithm, execute the following command inside the Docker container:

```bash
@:R/: Rscript main.R /microt_temp/config.yml
```

#### Configuration Parameters Explanation (config.yml)

These parameters collectively configure the microT-CNN algorithm and define the paths to the necessary input files and directories required for its execution. Users should adjust these paths and settings according to their specific setup and requirements.
``` yaml
src_dir : "/R/" # This parameter specifies the directory containing the source code files needed for the algorithm to run. In this case, it's set to /R/
exon_file : "/microt_temp/ensembl100.CDS.UTRS.apris.principal.tarnscripts.tab"  # This parameter specifies the path to the file containing exon's coordinates information. It's expected that the user provides this file under the microt_temp folder, which connects with the Docker image.
transcript_file_fasta : "/microt_temp/1_transcript.fa"  # This parameter specifies the path to the FASTA file containing transcript sequences. Similarly to the exon_file, the user should provide this file under the microt_temp folder.
miRNA.fa : "/microt_temp/1_mirna.fa"  # This parameter specifies the path to the FASTA file containing miRNA sequences. As with the previous files, the user should provide this file under the microt_temp folder.
mrescan_dir : "/R/bin/MREscan"  # This parameter specifies the directory containing the BBMap binary files.
bbmap_dir : "/R/bin/MREscan/bbmap"  # same here
path_RNAduplex : "/R/bin/ViennaRNA/20.04"  # This parameter specifies the directory containing the ViennaRNA package, particularly the RNAduplex executable.
wigFixDir : "/hg38/"  # This parameter specifies the directory containing the wigFix tool. It contains the genome alignment data.
path_contrafold : "/R/bin/contrafold/"  # This parameter specifies the directory containing the Contrafold binary files.
path_model : "/R/bin/model/"  # This parameter specifies the directory containing the model files used by microT-CNN.
resultdir : "/microt_temp/Results"  # This parameter specifies the directory where the output of the algorithm will be saved. A folder will be created with this name, containing the algorithm's output, ready for the user to access and review. In this case, it's set to /microt_temp/Results.
outputPrefix : "microTCNN_output"  # This parameter specifies the prefix for the output files generated by the algorithm.
threads : 2  # This parameter specifies the number of threads the algorithm should utilize for parallel processing. In this case, it's set to 2, meaning the algorithm will use two threads.
mre_score: 0.5 # This parameter specifies the threshold for an interaction on MRE level.
gene_score: 0.7 # This parameter specifies the threshold for an interaction on gene level.
```

Parameters exon_file, transcript_file_fasta, miRNA.fa, and threads can be adjusted to suit your specific needs.

#### A guide for Generating Transcript Exon Coordinates and Sequences

- For coordinates of exons and sequences of transcripts in a FASTA format, you can employ the fix_exons_fasta_files.R script. This script requires a file containing transcript names (refer to transcript_id_list.txt for the format). It will generate two files that can be used as inputs for microT-CNN: a tab-separated file containing the coordinates of exons for each transcript, and a FASTA file containing their sequences.

#### MicroT-CNN Performance Analysis with Varied Inputs

The `estimations` file provides a comprehensive analysis of the MicroT-CNN algorithm, exploring its performance under diverse input conditions. It includes a detailed examination of CPU and RAM consumption, as well as execution time, across a range of experimental setups.


