function this_color = color_picker(object_type)

% COLOR_PICKER assigns all colors to be plotted in a synthetic image.
% Each object should have a representative color, a distribution, or
% alternative data to support color selection.

if strcmp(object_type, "table_background")
    this_color = [54 54 68]/255;
    
elseif strcmp(object_type, "plate_background")
    this_color = [137 155 160]/255;
    
elseif strcmp(object_type, "border") % This is to generate the ring around the edge of the plate.  This also obscures the circularity of colonies at the edge.
    this_color = [105 107 152]/255;
    
elseif strcmp(object_type, "colony_white")
    this_color = [221 217 199]/255;
    
elseif strcmp(object_type, "colony_red")
    this_color = [148 36 23]/255;
    
else
    error("Object not recognized.  Please select from 'table_background', 'plate_background', 'border', 'colony_white', or 'colony_red'.")
    
end

end