FROM pytorch/pytorch:2.2.2-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root/
ENV FLYWHEEL="/flywheel/v0"

# -----------------------------
# System dependencies (rarely change)
# -----------------------------
RUN apt-get update && \
    apt-get install -y wget curl git bc jq build-essential libbz2-dev liblzma-dev\
    zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev \
    lsb-release gnupg && \
    apt-get clean

# -----------------------------
# System dependencies (rarely change)
# -----------------------------
RUN python -m pip install --upgrade pip && \
    pip install flywheel-gear-toolkit flywheel-sdk nibabel && \
    pip install --no-cache-dir nnunetv2 && \
    conda clean --all -y

RUN sed -i 's/from torch import GradScaler/from torch.cuda.amp import GradScaler/' \
/opt/conda/lib/python3.10/site-packages/nnunetv2/training/nnUNetTrainer/nnUNetTrainer.py

# -----------------------------
# Environment variables
# -----------------------------
# FSL (add additional dep here)
# RUN /opt/conda/bin/conda install -n base -c $FSL_CONDA_CHANNEL fsl-base fsl-utils fsl-avwutils -c conda-forge
# set FSLDIR so FSL tools can use it, in this minimal case, the FSLDIR will be the root conda directory
ENV PATH="/opt/conda/bin:${PATH}"
ENV FSLDIR="/opt/conda"
# activate FSL
#RUN $FSLDIR/etc/fslconf/fsl.sh

ENV nnUNet_raw="/flywheel/v0/app/nnUNet/nnUNet_raw"
ENV nnUNet_results="/flywheel/v0/app/nnUNet/nnUNet_results"
ENV nnUNet_preprocessed="/flywheel/v0/app/nnUNet/nnUNet_preprocessed"

# -----------------------------
# App directory
# -----------------------------
WORKDIR $FLYWHEEL

# -----------------------------
# Copy model 
# -----------------------------
COPY app/ app/

# -----------------------------
# Copy scripts (change often)
# -----------------------------
COPY run.py .
COPY Deface.sh .

# Configure entrypoint
# Configure entrypoint
RUN bash -c 'chmod +rx $FLYWHEEL/run.py' && \
    bash -c 'chmod +rx $FLYWHEEL/Deface.sh'

ENTRYPOINT ["python", "/flywheel/v0/run.py"]

