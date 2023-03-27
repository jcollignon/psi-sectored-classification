function selected_color = color_picker_3(object_type, data_dir)

% COLOR_PICKER_3 assigns all colors to be plotted in a synthetic image.
% Each object should have a representative color, a distribution, or
% alternative data to support color selection.
% In this version, color are randomly selected from croppings in a random
% image of yeast colonies on plates.  The cropping are manually selected

ridx = randi(numel(data_dir));

if strcmp(object_type, "table_background") % Representative color for the background pixels outside fo the plate (the table on which the plate rests)
    chosen_file = imread(['Color_Samples/Background/' data_dir(ridx).name]);
    row = randi(size(chosen_file, 1));
    col = randi(size(chosen_file, 2));
    selected_color = double(chosen_file(row, col,:))/255;
    selected_color = squeeze(selected_color)';
    %expected_color = [54 54 68]/255;
    
elseif strcmp(object_type, "plate_background") % Representative color for the background pixels that are part of the plate
    chosen_file = imread(['Color_Samples/Background/' data_dir(ridx).name]);
    row = randi(size(chosen_file, 1));  %select 100 row coordinates at random
    col = randi(size(chosen_file, 2));  %and 100 columns to go with it
    selected_color = double(chosen_file(row, col,:))/255;
    selected_color = squeeze(selected_color)';
    %expected_color = [137 155 160]/255;
    
elseif strcmp(object_type, "border") % This is to generate the ring around the edge of the plate.  This also obscures the circularity of colonies at the edge.
    chosen_file = imread(['Color_Samples/Background/' data_dir(ridx).name]);
    row = randi(size(chosen_file, 1));  %select 100 row coordinates at random
    col = randi(size(chosen_file, 2));  %and 100 columns to go with it
    selected_color = double(chosen_file(row, col,:))/255;
    selected_color = squeeze(selected_color)';
    %expected_color = [105 107 152]/255;
    
elseif strcmp(object_type, "colony_white") % Representative white color
    chosen_file = imread(['Color_Samples/White/' data_dir(ridx).name]);
    row = randi(size(chosen_file, 1));  %select 100 row coordinates at random
    col = randi(size(chosen_file, 2));  %and 100 columns to go with it
    selected_color = double(chosen_file(row, col,:))/255;
    selected_color = squeeze(selected_color)';
    %expected_color = [221 217 199]/255;
    
elseif strcmp(object_type, "colony_red") % Representative red color
    chosen_file = imread(['Color_Samples/Red/' data_dir(ridx).name]);
    row = randi(size(chosen_file, 1));  %select 100 row coordinates at random
    col = randi(size(chosen_file, 2));  %and 100 columns to go with it
    selected_color = double(chosen_file(row, col,:))/255;
    selected_color = squeeze(selected_color)';
    %expected_color = [148 36 23]/255;
    
else
    error("Object not recognized.  Please select from 'table_background', 'plate_background', 'border', 'colony_white', or 'colony_red'.")
    
end

end