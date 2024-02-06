%% This is the script that generates the sectored colony images

%% Steps for each training image

% 1. Create background of the table color
% 2. Create inner circle
% 3. Color inner circle with the plate with the same color as the plate
% 4. Plot colonies whose centers are in the inner circle and match the
% color of the colonies in the real images.
% 5. Create outer circle close to 1 colony radius larger than the inner
% circle, whose center is the same as the inner circle.
% 6. Fill the space between the outer and inner circle.  Use a color found
% on the edge of the plate.
% 7. Save result as image.  This is colony only.
% 8. Create corresponding binary mask for colonies.  This is done thorugh
% thresholding the color.
% 9. Using the centers of the white colonies, generate sectors of red
% phenotype onto the colonies.  Repeat steps 5 and 6 when done.
% 10. Save result as image.  These are the colonies with sectors.
% 11. Create corresponding mask for white portions of colonies.  This is
% done using the same thresholding parameters in step 8.  To get red
% colonies only, subtract mask of this step with mask from step 8.
% 12. Create corresponding mask for red portions of colonies.  This is done
% by subtracting the mask from step 8 from the mask of step 11.
% 13. Create mask containing the number of sectiors per colony.  Each
% colony will be given a square centered at the same pladce as the colony
% and whose intensity is greater when the number of sectors in that colony
% is greater. Background pixels will have 0 intensity.
% 14. Add Poisson noise to image.  Leave masks unchanged

%% Initialization of global information

colony_counts = zeros(num_images,1);

%% Initialization of figure window

figure(1)
hold on

% Function to create figure window and define initial background
initial_background([54 54 68]/255,[105 107 152]/255, outres, image_dpi);

%% Start creating images

for this_image = 1:num_images
    
    cla; % Remember to clear the figure foreground each time
    
    % Save into separate folders for training and validation
    if this_image > num_training_images
        image_type = 'val';
    else
        image_type = 'train';
    end
    
    % ------------------------------------------------------------
    % 1. Select and/or create background of the table color
    
    random_color_background = color_picker('table_background');
    %random_color_background = color_data{3}(datasample((1:total_bg_colors), 1, 'Replace', true, 'Weights', color_weights{3}),:)/255;
    set(gcf, 'Color', random_color_background)
    set(gca,'visible','off')
    set(gca,'Color', random_color_background)
    
    % ------------------------------------------------------------
    % 2. Select and/or create background pertaining to the plate
    
    random_color_border = color_picker('border');
    %random_color_border = color_data{3}(datasample((1:total_bg_colors), 1, 'Replace', true, 'Weights', color_weights{3}),:)/255;
    plot(inner_circle(:,1), inner_circle(:,2), 'Color', random_color_border)
    
    % ------------------------------------------------------------
    % 3. Color the inner circle pertaining to the plate
    
    random_color_plate = color_picker('plate_background');
    fill(inner_circle(:,1),inner_circle(:,2), random_color_plate, 'LineStyle', 'none')
    
    % ------------------------------------------------------------
    % 4. Plot colonies (circles only)
    
    num_circles = round(avg_circles + circle_num_var*(2*(rand - 0.5)));
    colony_counts(this_image) = num_circles;
    
    %[circle_centers] = generate_colony_centers(num_circles, padding);
    [circle_centers, circle_radii] = generate_colony_centers_and_radii(num_circles, circle_size, circle_size_var, padding, inner_plate_radius, outer_plate_radius, min_border_distance);
    
    % Plot each circle in the image
    plot_colonies(circle_centers, circle_radii, theta)
    
    % ------------------------------------------------------------
    % 5. Create outer circle (exterior of plate border)
    
    plot(outer_circle(:,1), outer_circle(:,2), 'Color', random_color_border)
    
    % ------------------------------------------------------------
    % 6. Fill the space between the inner and outer circles with the border
    % color
    
    plot_border(inner_circle, outer_circle, num_cuts, random_color_border)
    
    % ------------------------------------------------------------
    % 7. Save image of colonies
    
    saveas(gcf, ['Synthetic_Images/' image_type '/images_white/' num2str(this_image) '.png'])
    
    % ------------------------------------------------------------
    % 8. Create mask of colonies from the image and rewrap plate
    
    I = imread(['Synthetic_Images/' image_type '/images_white/' num2str(this_image) '.png']);
    I_gray = im2gray(I);
    %Ib = im2bw(I,0.75);
    Ib = imbinarize(I_gray,0.75);
    imwrite(Ib, ['Synthetic_Images/' image_type '/masks_bw/' num2str(this_image) '.png'])
    
    % ------------------------------------------------------------
    % 9. Make the sectors (overlayed on the circles)
    
    num_sectors_per_colony = zeros(num_circles, 1);
    
    for this_circle = 1:num_circles
        
        this_center = circle_centers(this_circle, :);
        %circle_rad = 1.5*rand;
        circle_rad = circle_radii(this_circle);
        
        % get the endpoints of all sectors in the colony create sector in the current colony
        %[sector_endpoints, num_sectors] = generate_sector_points; % for generating one sector anywhere on the colony
        %sector_endpoints = generate_sector_points(this_center, circle_rad, theta); % for generating one sector
        [sector_endpoints, num_sectors] = generate_sector_points_2(sector_vector, num_sector_weights, min_sector_spacing, have_min_sector_spacing);
        %num_sector_weights, min_sector_spacing, have_min_sector_spacing);
        % for geenrating arbitrary number of sectors per colony specified
        % by sector_vector
        
        random_color_red_colony = color_picker('colony_red');
        % Generate sectors on the current colony
        plot_sectors(this_center, circle_rad, sector_endpoints, random_color_red_colony, theta)
        %fill(sector_points(:,1),sector_points(:,2), random_color_red_colony,'LineStyle','none')
        
        num_sectors_per_colony(this_circle) = num_sectors; % is 1 for now, but num_sectors in general
        
    end
    
    plot_border(inner_circle, outer_circle, num_cuts, random_color_border)
    
    % ------------------------------------------------------------
    % 10. Save image with sectors
    
    saveas(gcf, ['Synthetic_Images/' image_type '/images_noiseless/' num2str(this_image) '.png'])
    
    % ------------------------------------------------------------
    % 11. Create masks of white and red colonies
    
    I2 = imread(['Synthetic_Images/' image_type '/images_noiseless/' num2str(this_image) '.png']);
    I2_gray = im2gray(I2);
    %Ib2 = im2bw(I2,0.75);
    Ib2 = imbinarize(I2_gray,0.75);
    
    % Create white mask
    imwrite(Ib2, ['Synthetic_Images/' image_type '/masks_white/' num2str(this_image) '.png'])
    
    % Create red mask
    Ib3 = logical(double(Ib) - double(Ib2));
    imwrite(Ib3, ['Synthetic_Images/' image_type '/masks_red/' num2str(this_image) '.png'])
    
    % Create multiclass mask
    M = uint8(double(Ib3) + 2*double(Ib2)); % red + 2*white
    % 0 = background pixel
    % 1 = red colony pixel
    % 2 = white coloy pixel
    imwrite(M, ['Synthetic_Images/' image_type '/masks/' num2str(this_image) '.png'])
    
    % ------------------------------------------------------------
    % 13. Create mask for number of sectors per colony
    
    % Set 0 as background
    % set center pixel as number of sectors + 1
    
    sector_mask_simple = generate_sector_count_mask(circle_centers, num_sectors_per_colony, outres, scaling_factor);
    imwrite(sector_mask_simple, ['Synthetic_Images/' image_type '/masks_sector_counts/' num2str(this_image) '.png'])
    
    % ------------------------------------------------------------
    % 14. Add Poisson noise to original image
    
    orig_image = imread(['Synthetic_Images/' image_type '/images_noiseless/' num2str(this_image) '.png']);
    noisy_image = imnoise(orig_image, 'poisson');
    imwrite(noisy_image, ['Synthetic_Images/' image_type '/images/' num2str(this_image) '.png'])
    
end

% Save data on how many colonies there are
writematrix(colony_counts, 'colony_counts.csv')

% This is the end!
disp('Image generation completed!')