# psi-sectored-classification
 This is a pipeline for doing colony segmetation and classification of Saccharomyces cerevisiae colonies exhbiting $[PSI^+]$ and $[psi^-]$ phenotypes.

This code base is designed for implementation on Google Colaboratory.  You will first need to clone this repository, then upload the entire repository folder to a nice location on your Google Drive.  Make sure that the Google account you are using allows access to Google Colaboratory.

## Synthetic image generation:

This will be done in the Image Generation subfolder of the repository.  If you have MATLAB installed, this will be much easier.  The main script here is `config_and_run.m`, which will be the only script you need to edit and run this part of the process.  This script will first create the folders and initialize the variables neeed for the image generation process, then will call the `Image_Generator.m` script which performs the synthetic image generation step.  Functions which are called for creating the images are stored in the "Functions" subfolder.

## Training, Segmentation, and Classification:

This will be done in the Pipeline subfolder of the repository.  The main script is titled `Pipeline_Code.ipynb` and can be open using Google Colaboratory.  There are a few lines that must be changed in order for this to run within your particular drive account.

1. The second cell will attempt to install Octave on the runtime.  Two additional packgates names "image" and "dataframe" will need ot be installed before continuing.  You can install the packges directly from sourceforge, or if you have the .zip files included, you will need to change the file paths in this cell so that they lead to the location of these two .zip files.
2. The fourth cell whose heading is "Directory Configuration" will need two lines changed indicating the location of the repository on your Google Drive as well as its parent directory.  Google Drive typically places anything involving the use of Colab into a directory called "Colab Notebooks", but the repository can be placed into any location of your choosing.  You just need to remember where you placed the repository.

A Google Drive directory path usually starts with `"/content/gdrive/My Drive/Colab\ Notebooks/`, so if the respository is the following: `"/content/gdrive/My Drive/Colab\ Notebooks/this_repo`, then you should change this path so that it leads to the directory where you added the repostory.

## The Segmentation Step:

How to use this section will depend on whether the code has been run once before, whether the weights you want to use have been saved already, and whether you simply would like to start from scratch.

**Training a new model**:

In the third cell, there are a set of variables and parameters to change.  Make sure `train_model` is set to True.  If you want to train the U-Net implementation used in that paper, set `use_test_network` to `False`.  Otherwise, if you want to use a small network for checking that each section runs okay, then set this variable to `True`.

Make sure to go into the "Directory Configuration" cell and change the variable `weights_file`.  This is a string which will be the name of the file containing the saved weights from training.

Note: If you are trianing a new model, make sure the weights file has a different name than those already in your folder.  If a new model is being trained, any older weights file with the same name will be overwritten.

**Starting with an already trained model**:

In the third cell, there are a set of variables and paramters to change.  Make sure `train_model` is set to `False` if you arleady have an existing set of weights you want to use for segmentation.  The weights file being used for this study is `2021_07_01.h5`, so the value for `weights file` in this case is `2021_07_01`.
*Note: This will be dependent on whether the weights file you are using comes from the test model or the implementated model.*

## The Colony Extraction Step:

This section utilizes the `oct2py` package to run Octave functions on Google Colab.  Once you have a set of weights saved, make sure the model implementation is loaded before continuing.  The `image` and `dataframe` Octave packages must be loaded before this section is executed.  

The notebok will iterate through each plate and predict a class for each pixel using a trained U-Net with a given `weights_file`.  The resulting predictions are a mask containing three colors to signifcy whether each pixel is in the background, is a red colony pixel, or is a white colony pixel.  Next, a binarized copy of the mask differentiating colony pixels in general from the background is created.  We then call `get_circular_data.m` which runs Octaves `imfindcircles` function on the binary mask in order to detected circular objects (the colonies).  The locations and sizes of the objects detected are recorded and saved in a csv file.  An image with the overlayed detected circular objects is also saved.

## The Classification Step:

The notebook will iterate through each colony extracted and attempt to classify each colony based on the number of red and white regions preseing in its segmentation.  The steps performed on each colony are as follows:
- Information on the location and size of the colony is referenced from the orignal image and its corresponding segmentation and extracted from both.
- The segemntation is partitined into its interior and boudnary components.
- The interior and boundary components are further partitioned into their corresponding red and white regions
- The number of connected components of red and white pixels on the boundary are counted.  These are the initial predictions for the number of red and white regions respectively.
- Regions of the colony are proposed.  The boundary of each region is drawn using Bresenham's line algorithm by connecting the center of the colony with the endpoints of a connected component on the colony boundary.  The interior of the region is defined as the pixels enclosed within the corresponding boundary region.  Finally, the color assigned to a region is the same as the color of the connected component of pixels on the colony boundary.
- Check that each region satisfies the purity condition.  Purity of a red/white region is defined as the number of red/white colony pixels in a region with the same color as that region, divided by the number of colony pixels in that region.  More specifically, it is the proportion of colony pixels assigned the color of the region.
- For regions where the purity condition is not satisfied, the color of the boundary pixels for such regions are replaced with the opposing color.  The steps for partitioning the regions of the colony are repeated.
- Once all regions satisfy the purity constraint, the number of red and white regions remaining are predicted as the 'corrected' counts.
- Colonies are classified based on the number of red and white regions.  Colonies are classified as 'sectored' if they have a red and white region present.  If there is no red region, the colony is classified as $[PSI^+]$.  Similarly, if there is no white region, the colony is classified as $[psi^-]$.

## Plotting Data:

The notebook script `Make_Plots.ipynb` is used solely for data visualization and plot generation following the conclusion of colony classification.  The script loads in the shpreadsheet inside the "Pub Data" folder that contains the curated data from both images sets used in this study and creates a series of plots for visually analysing the performance of $[PSI]$-CIC.  Additionally, there is a spreadsheet titld `excluded_colonies.csv` containing a column of the same length indicating the 30 colonies that were exlcuded for having ill-defined regions.
