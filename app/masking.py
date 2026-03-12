import nibabel as nib
import numpy as np
import os
import difflib

# Define the input directories and output directory

images_dir = '/flywheel/v0/input/'#'./background_images/'
labels_dir = '/flywheel/v0/output/'#'./nnunet_inferences/'
masked_images_dir = '/flywheel/v0/output/mask/'#'./masked_images/'


# Ensure the output directory exists
os.makedirs(masked_images_dir, exist_ok=True)

# List all NIfTI files in the images and labels directories
image_files = [f for f in os.listdir(images_dir) if f.endswith('.nii.gz')]
label_files = [f for f in os.listdir(labels_dir) if f.endswith('.nii.gz')]

# Iterate over all image files
for image_file in image_files:
    # Remove '_0000' from the image filename to find the closest label filename
    base_name = image_file.replace('_0000.nii.gz', '')  # Remove only '_0000' part

    # Find the closest matching label file
    closest_label = difflib.get_close_matches(base_name, label_files, n=1)
    
    if closest_label:  # Proceed only if a match is found
        label_file = closest_label[0]

        try:
            # Load the image and label NIfTI files
            image_path = os.path.join(images_dir, image_file)
            label_path = os.path.join(labels_dir, label_file)

            image_nii = nib.load(image_path)
            label_nii = nib.load(label_path)

            # Get the image and label data as numpy arrays
            image_data = image_nii.get_fdata()
            label_data = label_nii.get_fdata()

            # Complement the label data (assuming binary masks)
            complemented_label_data = np.logical_not(label_data).astype(np.uint8)

            # Apply the complemented label to the image to create a masked image
            masked_image_data = image_data * complemented_label_data

            # Save the masked image as a new NIfTI file
            masked_image_nii = nib.Nifti1Image(masked_image_data, image_nii.affine)
            masked_image_filename = os.path.join(masked_images_dir, f"masked_{image_file}")
            nib.save(masked_image_nii, masked_image_filename)

            print(f"Processed and saved masked image for {image_file}")
        except Exception as e:
            print(f"Error processing {image_file} with label {label_file}: {e}")
    else:
        print(f"No close match found for image {image_file}")