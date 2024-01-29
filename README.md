# psi-sectored-classification
 This is a pipeline for doing colony segmetation and classification of Saccharomyces cerevisiae colonies exhbiting [PSI+] and [psi-] phenotypes.

This code base is designed for implementation on Google Colaboratory.  You will first need to clone this repository, then upload the entire repository folder to a nice location on your Google Drive.  Make sure that the Google account you are using allows access to Google Colaboratory.

Synthetic image generation:

This will be done in the Image Generation subfolder of the repository.  If you have MATLAB installed, this will be much easier.  The main script here is "config_and_run.m", which will be the only script you need to edit and run this part of the process.

Training, Segmentation, and Classification

This will be done in the Pipeline subfolder of the repository.  The main script is titled _2023_03_01.ipynb and can be open using Google Colaboratory.  There are  afew lines that must be changed in order for this to run within your particular drive account.

1. The second cell will attempt to install Octave on the runtime.  Two additional packgates names "image" and "dataframe" will need ot be installed before continuing.  You can install the packges directly from sourceforge, or if you have the .zip files included, you will need to change the file paths in this cell so that they lead to the location of these two .zip files.
2. The fourth cell whose heading is "Directory Configuration" will need two lines changed indicating the location of the repository on your Google Drive as well as its parent directory.  Google Drive typically places anything involving the use of Colab into a directory called "Colab Notebooks", but the repository can be placed into any location of your choosing.  You just need to remember where you placed the repository.

A Google Drive directory path usually starts with `"/content/gdrive/My Drive/Colab\ Notebooks/`, so if the respository is the following: `"/content/gdrive/My Drive/Colab\ Notebooks/this_repo`

THE SEGMENTATION COMPONENT:

How to use this section will depend on whether the code has been run once before, whether the weights you want to use have been saved already, and whether you simply would like to start from scratch.

**Training a new model**:

In the third cell, there are a set of variables and paramters to change.  Make sure "train_model" is set to True.  If you want to train the U-Net implementation used in that paper, set "use_test_network" to False.  Otherwise, if you want to use a small network for checking that each section runs okay, then set this variable to True.

Make sure to go into the "Directory Configuration" cell and change the variable `weights_file`.  This is a string which will be the name of the file containing the saved weights from training.

**Starting with an already trained model**:

In the third cell, there are a set of variables and paramters to change.  Make sure `train_model` is set to `False` if you arleady have an existing set of weights you want to use for segmentation.  If you want to train the U-Net implementation used in our paper, set `use_test_network` to False.  Otherwise, if you want to use a small network for checking that each section runs okay, then set this variable to True.  *Note: This will be dependent on whether the weights file you are using comes from the test model or the implementated model.*

**Re-run everything**

Do the same thing as in the case where you would like to train a new model, but change the value of `weights_file` so that you don't overwrite another existing one.


THE EXTRACTION COMPONENT:

Once you have a set of weights saved, make sure the model implementation is loaded before continuing.

THE CLASSIFICATION COMPONENT:

The notebook will iterate through each colony extracted and attempt to classify each colony based on the number of red and white regions preseing in its segmentation.  The steps performed on each colony are as follows:
- Partition the segmnetation into its interior and boudnary pixels.
- Further partition the interior and boundary regions into their correspinding red and white regions
- Count the number of connected components of red and white pixels on the boundary.  These are the initial predictions for the number of red and white regions respectively.
- Define the color of the region to be the color of the pixels on the outer boundary of the region.
- Check that each region satisfies the purity condition.  Purity of a red/white region is defined as the number of red/white colony pixels in a region with the same color as that region, divided by the number of colony pixels in that region.  More specifically, it is the proportion of colony pixels assigned the color of the region.
- For regions where the purity condition is not satisfied, the color of the boundary pixels for such regions are replaced with the opposing color.  The steps for partitioning the regions of the colony are repeated.
- Once all regions satisfy the purity constraint, the number of red and white regions remaining are predicted as the 'corrected' counts.
- Colonies are classified based on the number of red and white regions.  Colonies are classified as 'sectored' if they have a red and white region present.  If there is no red region, the colony is classified as $[PSI^+]$.  Similarly, if there is no white region, the colony is classified as $[psi^-]$.

