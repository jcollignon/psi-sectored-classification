function selected_color = color_picker_2(object_type)

exponential_weight = 0.03;
sigma = 1/3;

% COLOR_PICKER assigns all colors to be plotted in a synthetic image.
% Each object should have a representative color, a distribution, or
% alternative data to support color selection.

if strcmp(object_type, "table_background") % Representative color for the background pixels outside fo the plate (the table on which the plate rests)
    expected_color = [54 54 68]/255;
    
elseif strcmp(object_type, "plate_background") % Representative color for the background pixels taht are part of the plate
    expected_color = [137 155 160]/255;
    
elseif strcmp(object_type, "border") % This is to generate the ring around the edge of the plate.  This also obscures the circularity of colonies at the edge.
    expected_color = [105 107 152]/255;
    
elseif strcmp(object_type, "colony_white") % Representative white color
    expected_color = [221 217 199]/255;
    
elseif strcmp(object_type, "colony_red") % Representative red color
    expected_color = [148 36 23]/255;
    
else
    error("Object not recognized.  Please select from 'table_background', 'plate_background', 'border', 'colony_white', or 'colony_red'.")
    
end

% Generate a distribution using the expected color as a parameter
% Start with a nomral distribution (has infinite domain)
normal_dist_r = makedist('Normal', 'mu', expected_color(1), 'sigma', sigma);
normal_dist_g = makedist('Normal', 'mu', expected_color(2), 'sigma', sigma);
normal_dist_b = makedist('Normal', 'mu', expected_color(3), 'sigma', sigma);

% Truncate the distributions to be between 0 and 1 (the space of each
% color)
truncated_normal_dist_r = truncate(normal_dist_r, 0, 1);
truncated_normal_dist_g = truncate(normal_dist_g, 0, 1);
truncated_normal_dist_b = truncate(normal_dist_b, 0, 1);

% Sample from these distributions.
% Get a sample within the acceptable range.
accepted_sample = false;
while accepted_sample == false
    sample_r = random(truncated_normal_dist_r); 
    sample_g = random(truncated_normal_dist_g); 
    sample_b = random(truncated_normal_dist_b); 

    diff_vec = [(sample_r - expected_color(1)), (sample_g - expected_color(2)), (sample_b - expected_color(3))];
    
    % Get the probability of acceptance using Boltzmann's acceptance
    % function.
    random_prob = exp(-norm(diff_vec)/exponential_weight);
    draw_random = datasample([true, false], 1, 'Weights', [random_prob, 1-random_prob]);
    
    if draw_random
        accepted_sample = true;
        selected_color = [sample_r, sample_g, sample_b];
    end

end

end