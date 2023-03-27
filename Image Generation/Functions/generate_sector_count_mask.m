function sector_count_mask = generate_sector_count_mask(circle_centers, num_sectors_per_colony, outres, scaling_factor)

sector_mask = zeros(outres,outres);
num_circles = size(circle_centers, 1);

for this_circle = 1:num_circles
    
    scaled_circle_center = scaling_factor*circle_centers(this_circle,:);
    translated_circle_center = ceil(scaled_circle_center + (outres + 1)/2);
    translated_circle_center(1) = min([translated_circle_center(1) outres]);
    translated_circle_center(2) = min([translated_circle_center(2) outres]);
    
    sector_mask((translated_circle_center(2)-floor(scaling_factor/2)):(translated_circle_center(2)+floor(scaling_factor/2)), (translated_circle_center(1)-floor(scaling_factor/2)):(translated_circle_center(1)+floor(scaling_factor/2))) = num_sectors_per_colony(this_circle)+1;
    
end

sector_count_mask = uint8(sector_mask);
sector_count_mask = flipud(sector_count_mask);

end