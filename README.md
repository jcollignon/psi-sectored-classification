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


THE EXPTRACTION COMPONENT:

Once you have a set of weights saved, make sure the model implementation is loaded before continuing.


