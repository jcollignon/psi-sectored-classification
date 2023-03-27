function [good_color_samples, good_color_dists] = mahalanobis_color_sampler(object_type, color_data, num_samples, threshold)

% This function generates randome samples from a multivaraite Gaussian
% distribution of RGB values which satify a condition on the Mahalanobis
% distance from the color distributions and are within the acceptable color
% gamut (usually [0, 255])
if ~any(strcmp({'table_background', 'plate_background', 'border', 'colony_white', 'colony_red'}, object_type))
    error("Object not recognized.  Please select from 'table_background', 'plate_background', 'border', 'colony_white', or 'colony_red'.")
end

num_points_to_sample = num_samples;
color_data_mean = mean(color_data);
color_data_cov = cov(color_data);
color_data_inv_cov = inv(color_data_cov);
critical_mahalanobis = threshold;

good_color_samples = zeros(num_points_to_sample,3);
good_color_dists = zeros(num_points_to_sample,1);

% Generate color samples which lie in the Mahalanobis volume
point_counter = 1;
while point_counter <= num_points_to_sample
    % Do rejection sampling until we have all the points

    sample_point = round(mvnrnd(color_data_mean,color_data_cov,1)); % the sampled point
    sample_dist = sample_point - color_data_mean; % euclidean distance between the point and the mean
    mahalanobis_dist = sqrt((sample_dist)*color_data_inv_cov*((sample_dist)')); % compute mahalanobis distance between the points and the distribution

    if mahalanobis_dist < critical_mahalanobis
        if ~any(sample_point < 0 | sample_point > 255)
            good_color_samples(point_counter,:) = sample_point; % store all the good points in the sample matrix
            good_color_dists(point_counter) = mahalanobis_dist;
            point_counter = point_counter + 1; % keep track of how many points were added
        end
    end

end

end