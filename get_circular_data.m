function get_circular_data(plate_image, plate_seg, data_location)

% Run circle Hough transform on inputted image

%% Parameters to change

% Isolated colony conditions (used for estimating colony sizes for a given image only)
% (getting data on exactly how large single colonies are in the images,
% with constraints so that we don't pick out"giants" or "ants"

aspect_ratio = 1.2; % make sure the region is close to square
min_area = 100; % make sure the region isn't too small
max_area = 2000; % make sure the region isn't too big
min_region_area_prop = 0.75; % make sure that the region has enough colony pixels
max_region_area_prop = 0.9; % make sure that the region isn't completely overtaken by colony pixels

% Circle detection (CHT)

min_detection_radius = 7; % set arbitrary detection radius so that CHT is still accurate.  Scale until image can detect circles of that size.
padding = 150; % number of pixels in the original sizes image between all the borders and the detection zone

%% Read the image

this_img = imread(plate_image);
this_seg = imread(plate_seg);

% Get image and seg sizes, as well as seg center
img_size = size(this_img);
seg_size = size(this_seg);
%seg_center = round([seg_size(1), seg_size(2)]/2);
scaled_padding = padding*seg_size(1)/img_size(1); % scale the padding if the image and seg sizes are different

%resized_image = imresize(this_img, [1024,1024]);

% Get all colony class pixels
this_seg_bool = this_seg > 0;
this_seg_bool = this_seg_bool(:,:,1); % because imread gives me a 3D tensor instead of 2D.  Just make it 2D yourself.

% Initialize the logical matrix for the image and colony counts
zero_bool_mat = false(seg_size(1), seg_size(2));
colony_count = 0;

% Find connected components of colony pixels
this_seg_conncomps = bwconncomp(this_seg_bool);
seg_boxes = regionprops(this_seg_conncomps, 'BoundingBox', 'Area', 'FilledArea', 'Extent');
num_components = size(seg_boxes,1);

% Initialize table that contain the locations of all colonies
%location_table = array2table(zeros(0,10), 'VariableNames', {'Colony', 'Center (x)', 'Center (y)', 'Radius', 'Top Left (x)', 'Top Left (y)', 'Width', 'Height', 'Estimated Center (x)', 'Estimated Center (y)'});
%location_table_rescaled = array2table(zeros(0,10), 'VariableNames', {'Colony', 'Center (x)', 'Center (y)', 'Radius', 'Top Left (x)', 'Top Left (y)', 'Width', 'Height', 'Estimated Center (x)', 'Estimated Center (y)'});
location_matrix = zeros(0,10);
location_matrix_rescaled = zeros(0,10);
% The Variable Names are as follows: {'Colony', 'Center (x)', 'Center (y)', 'Radius', 'Top Left (x)', 'Top Left (y)', 'Width', 'Height', 'Estimated Center (x)', 'Estimated Center (y)'}

%% Find isolated colonies

radii_data = [];
    
for this_comp = 1:num_components

    zero_bool_mat(this_seg_conncomps.PixelIdxList{this_comp}) = true;
    comp_box = seg_boxes(this_comp).BoundingBox; % get the information on the bounding box for this component
    shift_horz = comp_box(1)+0.5; % shift by 0.5 so the bound is an integer
    shift_vert = comp_box(2)+0.5;
    
    % get bounding box corresponding to pixel space
    this_seg_comp = zero_bool_mat(shift_vert:((shift_vert)+comp_box(4)-1), shift_horz:((shift_horz)+comp_box(3)-1));
    region_area = comp_box(3)*comp_box(4); % area tha the bounding box takes up
    num_colony_pixels = sum(this_seg_comp(:)); % number of colony pixels occupied within the boundidng box

    % The region must be 2 dimenisonal.  It cannot be a single
    % row/column of pixels.
    if (comp_box(4) > 1 && comp_box(3) > 1)

        % Run conditional checks

        % Check that region is close to square
        if ~(((comp_box(3) / comp_box(4)) < aspect_ratio) && ((comp_box(4) / comp_box(3)) < aspect_ratio))
            continue;
        end

        % Check that the regios is not too big nor small
        if ~((region_area > min_area) && (region_area < max_area))
            continue;
        end

        % Check that the region contains enough colony pixels
        if ~(((num_colony_pixels / region_area) > min_region_area_prop) && ((num_colony_pixels / region_area) < max_region_area_prop))
            continue;
        end

        % If all conditions are satisfied, get more info about
        % component.  In case component is not square, get minor and
        % major radii respectively, assuming the region may also be
        % elliptical.

        radii_data(end+1,:) = [min(comp_box(3:4)) ; max(comp_box(3:4))];

    end

    % Reset bool mat for next component
    zero_bool_mat(this_seg_conncomps.PixelIdxList{this_comp}) = false;

end

% Save radius data and image size as a Matlab data file
radii_data = radii_data / 2;
min_radius = min(radii_data(:));
max_radius = max(radii_data(:));
%save([radii_folder '/' this_img_name '.mat'], 'radii_data', 'min_radius', 'max_radius', 'img_size', 'seg_size')



%% Do CHT on each connected component

% Resize image if isolated colonies have a very small radius
if floor(min_radius) < min_detection_radius

    image_scaling_factor = min_detection_radius/floor(min_radius);
    %new_image_size = seg_size*image_scaling_factor;
    this_seg_rescaled = imresize(this_seg_bool, image_scaling_factor);
    seg_rescaled_size = size(this_seg_rescaled);
    this_seg_rescaled_conncomps = bwconncomp(this_seg_rescaled);
    seg_boxes_rescaled = regionprops(this_seg_rescaled_conncomps, 'BoundingBox', 'Area', 'FilledArea', 'Extent');
    scaled_padding_rescaled = scaled_padding*image_scaling_factor;
    
else
    
    image_scaling_factor = 1;
    this_seg_rescaled = this_seg_bool;
    seg_rescaled_size = size(this_seg_rescaled);
    this_seg_rescaled_conncomps = bwconncomp(this_seg_rescaled);
    seg_boxes_rescaled = seg_boxes;
    scaled_padding_rescaled = scaled_padding*image_scaling_factor;
    
end

% Scale radius range of detection for scaled image
% This is the minimum and maximum radious found in the scaled image.
% If the image has to be resized, then the minimum radius will be
% exactly the value specified by min_detection_radius.  Otherwise, if
% the image is the same size, the minimum radius will be greater than
% min_detection_radius.

image_radius_range = [floor(min_radius*image_scaling_factor) ceil(max_radius*image_scaling_factor)];
seg_center_rescaled = round([seg_rescaled_size(1), seg_rescaled_size(2)]/2);

% Did we find any colonies?  If not, make sure we can continue without issues.
if ~isempty(image_radius_range)

    if (image_radius_range(1) == image_radius_range(2)) % check if the min and max radius match.  This is true when there is only one measurement.
    
        if image_radius_range(1) > 1

            image_radius_range = [image_radius_range(1)-1 image_radius_range(1)+1] % only done if the radius bounds are the same
            
        else
            
            image_radius_range = [1 2] % only done if the radius is too small to be used.  This is unlikley to happen though.
            
        end
        
    end

else

    image_radius_range = [10 40]; % Default to be used when no colonies are found in the whole image, but at least one colony is found when considering only the regions with connected components.  Why does this happen? 

end

zero_bool_rescaled_mat = false(seg_rescaled_size(1), seg_rescaled_size(2));



%% Perform CHT on all connected components of the scaled image
    
for this_comp = 1:size(seg_boxes_rescaled,1)

    zero_bool_rescaled_mat(this_seg_rescaled_conncomps.PixelIdxList{this_comp}) = true;
    comp_box = seg_boxes_rescaled(this_comp).BoundingBox;
    shift_horz = comp_box(1)+0.5;
    shift_vert = comp_box(2)+0.5;
    this_seg_rescaled_comp = zero_bool_rescaled_mat(shift_vert:((shift_vert)+comp_box(4)-1), shift_horz:((shift_horz)+comp_box(3)-1));

    if (comp_box(4) > 1 && comp_box(3) > 1)

        % Do CHT here and obtain ceters and radii of circles in scaled image
        [centers_colony_comp, radii_colony_comp] = imfindcircles(this_seg_rescaled_comp, image_radius_range, 'Sensitivity', 0.9);

        if ~isempty(radii_colony_comp) % if a colony has been found, get info
            % Info to store:
            % Colony count (make vector here)
            % Radius (pass on)
            % Width (round center and radius to get the left and right sides)
            % Height (round center and radius to get the upper and lower sides)
            % Top Left (x) and (y) (use center and radius to estimate top left)
            % BEFORE SAVING DATA, REMEMBER TO SCALE THE VALUES DOWN TO
            % THE ORIGINAL SIZE OF THE IMAGE!
            table_colony = linspace(colony_count + 1, colony_count + length(radii_colony_comp), length(radii_colony_comp))';
            colony_count = colony_count + length(radii_colony_comp);
            table_centers_rescaled = (round(centers_colony_comp) + [shift_horz-1 shift_vert-1]);
            table_centers = round(table_centers_rescaled / image_scaling_factor);

            table_left_rescaled = table_centers_rescaled(:,1) - round(radii_colony_comp); % left side of box
            table_left_rescaled(table_left_rescaled < 1) = 1;
            table_left = round(table_left_rescaled/image_scaling_factor);
            table_left(table_left < 1) = 1;

            table_right_rescaled = table_centers_rescaled(:,1) + round(radii_colony_comp); % right side of box
            table_right_rescaled(table_right_rescaled > seg_rescaled_size(2)) = seg_rescaled_size(2);
            table_right = round(table_right_rescaled/image_scaling_factor);
            table_right(table_right > round(seg_rescaled_size(2)/image_scaling_factor)) = round(seg_rescaled_size(2)/image_scaling_factor);

            table_upper_rescaled = table_centers_rescaled(:,2) - round(radii_colony_comp); % upper side of box
            table_upper_rescaled(table_upper_rescaled < 1) = 1;
            table_upper = round(table_upper_rescaled/image_scaling_factor);
            table_upper(table_upper < 1) = 1;

            table_lower_rescaled = table_centers_rescaled(:,2) + round(radii_colony_comp); % lower side of box
            table_lower_rescaled(table_lower_rescaled > seg_rescaled_size(1)) = seg_rescaled_size(1);
            table_lower = round(table_lower_rescaled/image_scaling_factor);
            table_lower(table_lower > round(seg_rescaled_size(1)/image_scaling_factor)) = round(seg_rescaled_size(1)/image_scaling_factor);

            % Get width and height

            table_width_rescaled = table_right_rescaled - table_left_rescaled + 1;
            table_height_rescaled = table_lower_rescaled - table_upper_rescaled + 1;

            table_width = table_right - table_left + 1;
            table_height = table_lower - table_upper + 1;

            % Keep left side, upper side, width, and height

            %% Store info about component in the table
%             location_table_comp_rescaled = array2table([table_colony table_centers_rescaled radii_colony_comp table_left_rescaled table_upper_rescaled table_width_rescaled table_height_rescaled, ((centers_colony_comp) + [shift_horz-1 shift_vert-1])], 'VariableNames', {'Colony', 'Center (x)', 'Center (y)', 'Radius', 'Top Left (x)', 'Top Left (y)', 'Width', 'Height', 'Estimated Center (x)', 'Estimated Center (y)'});
%             location_table_rescaled = [location_table_rescaled; location_table_comp_rescaled];
% 
%             location_table_comp = array2table([table_colony table_centers (radii_colony_comp/image_scaling_factor) table_left table_upper table_width table_height, ((centers_colony_comp) + [shift_horz-1 shift_vert-1]) / image_scaling_factor], 'VariableNames', {'Colony', 'Center (x)', 'Center (y)', 'Radius', 'Top Left (x)', 'Top Left (y)', 'Width', 'Height', 'Estimated Center (x)', 'Estimated Center (y)'});
%             location_table = [location_table; location_table_comp];
            
            location_matrix_rescaled_component = [table_colony table_centers_rescaled radii_colony_comp table_left_rescaled table_upper_rescaled table_width_rescaled table_height_rescaled, ((centers_colony_comp) + [shift_horz-1 shift_vert-1])];
            location_matrix_rescaled = [location_matrix_rescaled; location_matrix_rescaled_component];
            
            location_matrix_component = [table_colony table_centers (radii_colony_comp/image_scaling_factor) table_left table_upper table_width table_height, ((centers_colony_comp) + [shift_horz-1 shift_vert-1]) / image_scaling_factor];
            location_matrix = [location_matrix; location_matrix_component];

        end

    end

    % Reset bool mat for next component
    zero_bool_rescaled_mat(this_seg_rescaled_conncomps.PixelIdxList{this_comp}) = false;

end

% filter out circles close to the edge of the plate
if ~isempty(location_matrix_rescaled(:,1))

    dist_colony_from_center = sqrt((location_matrix_rescaled(:,3) - seg_center_rescaled(1)).^2 + (location_matrix_rescaled(:,2) - seg_center_rescaled(2)).^2);
    is_not_on_plate = dist_colony_from_center > min(seg_center_rescaled) - scaled_padding_rescaled;
    location_matrix(is_not_on_plate,:) = [];
    location_matrix_rescaled(is_not_on_plate,:) = [];
    %centers_colony(is_not_on_plate, :) = [];
    %radii_colony(is_not_on_plate) = [];
    %location_table(:,'Colony') = array2table(linspace(1, size(location_matrix,1), size(location_matrix,1))');
    %location_table_rescaled(:,'Colony') = array2table(linspace(1, size(location_matrix_rescaled,1), size(location_matrix_rescaled,1))');
    location_matrix(:,1) = linspace(1, size(location_matrix,1), size(location_matrix,1))';
    location_matrix_rescaled(:,1) = linspace(1, size(location_matrix_rescaled,1), size(location_matrix_rescaled,1))';
    
end

bin_map = CHT_Segmenter(this_seg, location_matrix(:,[2 3]), location_matrix(:,4));
    
% Use this mapping to filter out potentially misclassified regions
table_length = length(location_matrix(:,4));
this_row = 1;

while this_row <= table_length

    this_top = location_matrix(this_row, 6);
    this_bottom = this_top + location_matrix(this_row, 8) - 1;
    this_left = location_matrix(this_row, 5);
    this_right = this_left + location_matrix(this_row, 7) - 1;

    this_comp_seg = this_seg_bool(this_top:this_bottom, this_left:this_right);
    this_detection = bin_map(this_top:this_bottom, this_left:this_right);

    this_colony_mask = this_comp_seg.*this_detection;

    this_detection_sum = sum(this_detection(:));
    this_colony_mask_sum = sum(this_colony_mask(:));

    mask_agreement = this_colony_mask_sum / this_detection_sum;

    if mask_agreement >= 0.75
        this_row = this_row + 1;
    else
        location_matrix(this_row,:) = [];
        location_matrix_rescaled(this_row,:) = [];
        table_length = table_length - 1;
    end

end

% Save table to csv file
[~,name,~] = fileparts(plate_image);
%writetable(location_matrix, [data_location '/' name '.csv'], 'Delimiter',',')
%writematrix(location_matrix, [data_location '/' name '.csv'])
csvwrite([data_location '/' name '.csv'], location_matrix, "delimiter", ",")
end

