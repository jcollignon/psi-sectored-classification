# psi-sectored-classification
 This is a pipeline for doing colony segmetation and classification of Saccharomyces cerevisiae colonies exhbiting [PSI+] and [psi-] phenotypes.

This code base is designed for implementation on Google Colaboratory.  You will first need to clone this repository, then upload the entire repository folder to a nice location on your Google Drive.  Make sure that the Google account you are using allows access to Google Colaboratory.

Synthetic image generation:

This will be done in the Image Generation subfolder of the repository.  If you have MATLAB installed, this will be much easier.  The main script here is "config_and_run.m", which will be the only script you need to edit and run this part of the process.

Training, Segmentation, and CLassification

This will be done in the Pipeline subfolder of the repository.  The main script is titled _2023_03_01.ipynb and can be open using Google Colaboratory.  There are  afew lines that must be changed in order for this to run within your particular drive.

1. The second cell will attempt to install Octave on the runtime.  Two additional packgates names "image" and "dataframe" will need ot be installed before continuing.  You can install the packges directly from sourceforge, or if you have the .zip files included, you will need to change the file paths in this cell so that they lead to the location of these two .zip files.
2. The fourth cell whose heading is "Directory Configuration will need two lines changed indicating the location of the repository on your Google Drive as well as its parent directory.
