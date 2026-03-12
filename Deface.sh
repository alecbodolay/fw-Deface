#!/bin/bash
#
# Run script for flywheel/Deface Gear.
# Author: Alec Bodolay
#
##############################################################################

# Set base paths
FLYWHEEL_BASE=/flywheel/v0
NNUNET_BASE=$FLYWHEEL_BASE/app/nnUNet

INPUT_DIR=$FLYWHEEL_BASE/input
work=$FLYWHEEL_BASE/work
ANTSPATH='/opt/ants/bin/'
OUTPUT_DIR=$FLYWHEEL_BASE/output

# Set nnUNet paths (use local inside container)
export nnUNet_raw="$NNUNET_BASE/nnUNet_raw"
export nnUNet_preprocessed="$NNUNET_BASE/nnUNet_preprocessed"
export nnUNet_results="$NNUNET_BASE/nnUNet_results"

# Create required directories
mkdir -p ${work}
mkdir -p ${INPUT_DIR}
mkdir -p ${OUTPUT_DIR}

##############################################################################

# Check for required files
# Parse configuration
function parse_config {

  CONFIG_FILE=$FLYWHEEL_BASE/config.json
  MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json

  if [[ -f $CONFIG_FILE ]]; then
    echo "$(cat $CONFIG_FILE | jq -r '.config.'$1)"
  else
    CONFIG_FILE=$MANIFEST_FILE
    echo "$(cat $MANIFEST_FILE | jq -r '.config.'$1'.default')"
  fi
}
 
# define app options
imageDimension="$(parse_config 'imageDimension')" 
Iteration="$(parse_config 'Iteration')" 
transformationModel="$(parse_config 'transformationModel')"   
similarityMetric="$(parse_config 'similarityMetric')"  
target_template="$(parse_config 'target_template')"    
prefix="$(parse_config 'prefix')" 
phantom="$(parse_config 'phantom')" 

FSLDIR=/opt/conda
export FSLDIR

# Log the current shell and environment
echo "Current shell: $SHELL"
echo "Current interpreter: $(readlink -f /proc/$$/exe)"
echo "FSLDIR set to: $FSLDIR"

# Add FSL to PATH if needed
export PATH=$FSLDIR/bin:$PATH

# Optional: Source FSL configuration
if [ -f "${FSLDIR}/etc/fslconf/fsl.sh" ]; then
    source "${FSLDIR}/etc/fslconf/fsl.sh"
fi

##############################################################################
# Find input
infile=$(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.nii.gz" | head -n 1)
cp "$infile" "${nnUNet_raw}/Dataset400_HFdefacing/imagesTs/"

echo "\nPrinting input folder contents:"
echo "$(ls -l ${nnUNet_raw}/Dataset400_HFdefacing/imagesTs/)"

nnUNetv2_predict \
-i ${nnUNet_raw}/Dataset400_HFdefacing/imagesTs/ \
-o $OUTPUT_DIR \
-c 3d_fullres \
-d 400 \
-tr nnUNetTrainerNoMirroring 

echo "Printing output folder contents:"
echo "$(ls -l $OUTPUT_DIR)"