clear variables
close all

%% Ensure you stay in the directory of this script as it's running (leave as is)

current_file_name = matlab.desktop.editor.getActiveFilename;
pathstr = fileparts(current_file_name);
cd(pathstr)

% Ensure you can access functions related to the image generator
addpath(pwd)
addpath([pwd '/Functions'])

%% Put all parameters for configuration here (you can change these at any time)

% Number of images and how they are split between train and val
num_images = 5; % how many images in total
num_training_images = 3; % how many images are used for training

% Colony settings
avg_circles = 100; % how many colonies?  100 is the default
circle_num_var = 0; % maximum deviation from average number of colonies?
circle_size = 1; % how big are the colonies?  1 is the default
circle_size_var = 0; % maximum deviation from the average circle size (This should be small, definitely less than 1)

% Sector settings
max_num_sectors = 1; % how many sectors can possible be on a single colony
sector_vector = [1]; % all possible number of sectors for each colony (shoud be no more than the number above)
sector_vector = int8(sector_vector); % ensure the number of sectors is an integer
num_sector_weights = repelem(1/length(sector_vector), length(sector_vector)); % make the uniform probability vector for number of sectors
%sector_weights = []; % what is the probability for generating a certain number of sectors?
have_min_sector_spacing = 1; % do we want a minimum sector size and space between sectors? 1 = yes, 0 = no
min_sector_spacing = 10*pi/180; % how much spacing in terms of theta is minimal between sector endpoints?

% Plate and background settings
inner_plate_radius = 30; % the distance between the plate's center and the inner part of the border (in other words, the distance between the center and the wall)
outer_plate_radius = 31; % the distance between the plate's center and the outer part of the border (in other words, the distance btween the center and where we are no longer anywhere on the plate)
% 30 and 31 were used for the inner and outer plate radii respectively when
% this was being used.

% Spacing between colonies and the border
padding = 0.25; % minimum distance between the boundaries of any two colonies
% If > 0 or maybe > 0.25, colonies cannot touch at all (keep < 1)
% If 0: colonny boundaries can 'touch'
% If < 0, colonies can overlap
% If -1, overlapping colonies can at most overlap with a colony center
% Must be at least -2, where colonies completely overlap
min_border_distance = 1; % minimum distance between colony boundaries and the outer border of the plate

% Resolution and dimensions of output images
outres = 1024; % how many pixels per dimension?
image_dpi = 150;
% Note: This script was orignially run on a version of Matlab where 150
% dpi was the default resolution for exported images.
% If this is not true, then replace the value of image_dpi above with 
% your own dpi.

% Other variables
theta = linspace(0, 2*pi, 101); % how fine should the circles be?

% Other things that have yet to be added:
% VARIATION IN THE COLOR OF RED AND WHITE REGIONS
% VARIATION IN THE COLOR OF THE BORDER AND BACKGROUND REGIONS
% The above will require a modification of the color_picker script, which
% may also need input color data to be reliable.

%% Leave these alone
inner_circle = inner_plate_radius.*[cos(theta)' sin(theta)'];
inner_circle(end,2) = inner_circle(1,2);
outer_circle = inner_circle.*(outer_plate_radius/inner_plate_radius);
num_cuts = length(inner_circle(:,1));
circle_diameter = 2*outer_plate_radius; % needed to help scale the image appropriately
scaling_factor = outres/circle_diameter; % needed to rasterize the representation of the obects in the image
max_sectors = max(sector_vector);
min_sectors = min(sector_vector);

%% Do checks to verify that paramter sets are defined enough to not cause any major problems

% Check that the number of sectors in th sector vector is bounded properly
if max_sectors > max_num_sectors
    error('Invalid sector vector.  At least one eleemnt is greater than the number of sectors allowed.')
elseif min_sectors < 0
    error('Invalid sector vector.  At least one element is negative.')
end

% Check that minimal sector space is achieved
if (2*max_sectors*min_sector_spacing*have_min_sector_spacing) >= (2*pi)
    error('Conditions on sector spacing are impossible to meet.  Decrease the minimal distance between endpoints of sectors.')
end

% Check that the number of training images <= number of images
if num_training_images >= num_images
    error('Number of training images exceeds total image count.  Make sure that num_training_images <= num_images')
end

% Check that the radii of the outer circle is not smaller than the radii of
% the inner circle.
if outer_plate_radius < inner_plate_radius
    error('The border of the plate is not well defined.  Check to ensure that the inner and outer parts of the border are consistent.')
end

%% Check that the image generation script is in the same directory as this script (leave this alone)

if ~isfile('Image_Generator.m')
    error("The image generator code was not found.  Make sure it's in the same directory as this script.")
end

%% Create relevant directories here (leave this alone unless there are more directories to be added)

if ~exist([pwd '/Synthetic_Images'], 'dir')
    mkdir('Synthetic_Images')
else
    rmdir('Synthetic_Images', 's') % removes everything in the image directory, and I mean everything.
    mkdir('Synthetic_Images')
    mkdir('Synthetic_Images/train')
    mkdir('Synthetic_Images/val')
    mkdir('Synthetic_Images/train/images')
    mkdir('Synthetic_Images/train/images_noiseless')
    mkdir('Synthetic_Images/train/images_white')
    mkdir('Synthetic_Images/train/masks')
    mkdir('Synthetic_Images/train/masks_white')
    mkdir('Synthetic_Images/train/masks_red')
    mkdir('Synthetic_Images/train/masks_bw')
    mkdir('Synthetic_Images/train/masks_sector_counts')
    mkdir('Synthetic_Images/val/images')
    mkdir('Synthetic_Images/val/images_noiseless')
    mkdir('Synthetic_Images/val/images_white')
    mkdir('Synthetic_Images/val/masks')
    mkdir('Synthetic_Images/val/masks_white')
    mkdir('Synthetic_Images/val/masks_red')
    mkdir('Synthetic_Images/val/masks_bw')
    mkdir('Synthetic_Images/val/masks_sector_counts')
end

%% Finally, run the image generation script

Image_Generator