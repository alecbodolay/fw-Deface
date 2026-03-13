# Defacing based on nnUNetv2

Container for automated MRI defacing using a trained nnUNet model. <br>
It is designed to run inference on *High-Field* NIfTI volumes (`.nii`,`.nii.gz`) and produce defaced outputs. It is also structured to be implemented as FlyWheel Gear

### Container structure (basic)
```
/flywheel/v0/
│
├── app/
│   └── nnUNet
│       ├── nnUNet_raw/
|       ├── nnUNet_preprocessing/
│       └── nnUNet_results/
|
├── manifest.json
├── Dockerfile
├── run.py
└── Deface.sh
```

### Container requirements
GPU (Recommended) <br>
For best performance, a system with an NVIDIA GPU and the NVIDIA Container Toolkit installed is required. <br>
Other components are provided in the container.


|           | GPU hardware | Python | PyTorch | nnUNetv2 |
|---------- |--------|--------|--------|------------------|
| Provided by | host machine | container | container | container |
| Details | NVIDIA | latest | 2.2.2 | 2.6.4 |

### Container build
**Step 1**: Build the docker
```
docker build -t deface:0.0.1 .
```

**Step 2**: Run the container
```
docker run \
--rm -it --gpus all \
-v <local input folder path>:/flywheel/v0/input \
-v <local output folder path>:/flywheel/v0/output \
deface:0.0.1
```

**(optional) Step 3**: debug
```
docker run --rm -it --gpus all \
-v <local input folder path:/flywheel/v0/input \
-v <local output folder path>:/flywheel/v0/output \
--entrypoint /bin/bash deface:0.0.1
```
