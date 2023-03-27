function bin_map = CHT_Segmenter(my_image, centers, radii)

HT_size = size(my_image);

bin_map = false(HT_size(1), HT_size(2));
num_detections = length(radii);

for this_rad = 1:num_detections
    this_center_colony = centers(this_rad,:);
    this_radius_colony = radii(this_rad);
    
    % cover center of colony
    
    left_end = max(1,round(this_center_colony(1) - (this_radius_colony/sqrt(2))));
    right_end = min(HT_size(1),round(this_center_colony(1) + (this_radius_colony/sqrt(2))));
    up_end = max(1,round(this_center_colony(2) - (this_radius_colony/sqrt(2))));
    down_end = min(HT_size(2),round(this_center_colony(2) + (this_radius_colony/sqrt(2))));
    
    bin_map(left_end:right_end, up_end:down_end) = 1;
    
    % cover the four outer regions of colony
    
    cutting_point = round(sqrt((this_radius_colony^2 / 2)));
    
    % to the left of square
    for nn = 0:cutting_point
        left_border = max(1, round(this_center_colony(1) - sqrt(this_radius_colony^2 - nn^2)));
        bin_map(max(1,left_border):left_end, min(round(this_center_colony(2)) + nn, HT_size(2))) = 1;
        bin_map(max(1,left_border):left_end, max(1, round(this_center_colony(2)) - nn)) = 1;
        %bin_map(round(left_end - left_border):left_end, round(this_center_colony(2)) + nn) = 1;
        %bin_map(round(left_end - left_border):left_end, round(this_center_colony(2)) - nn) = 1;
    end
    
    % to the right of square
    for nn = 0:cutting_point
        right_border = min(round(this_center_colony(1) + sqrt(this_radius_colony^2 - nn^2)), HT_size(1));
        bin_map(right_end:min(right_border, HT_size(1)), min(round(this_center_colony(2)) + nn, HT_size(2))) = 1;
        bin_map(right_end:min(right_border, HT_size(1)), max(1,round(this_center_colony(2)) - nn)) = 1;
    end
    
    % above square
    for nn = 0:cutting_point
        up_border = max(1, round(this_center_colony(2) - sqrt(this_radius_colony^2 - nn^2)));
        bin_map(min(round(this_center_colony(1)) + nn, HT_size(1)), up_border:min(up_end, HT_size(2))) = 1;
        bin_map(max(1, round(this_center_colony(1)) - nn), up_border:min(up_end, HT_size(2))) = 1;
    end
    
    % below square
    for nn = 0:cutting_point
        down_border = min(round(this_center_colony(2) + sqrt(this_radius_colony^2 - nn^2)), HT_size(2));
        bin_map(min(round(this_center_colony(1)) + nn, HT_size(1)), down_end:min(down_border, HT_size(2))) = 1;
        bin_map(max(1, round(this_center_colony(1)) - nn), down_end:min(down_border, HT_size(2))) = 1;
    end
    
    % Plot the binary map
    %figure(20)
    %imshow(bin_map','Border', 'Tight')
    
end

bin_map = bin_map';
% Plot the binary map
%figure
%imshow(bin_map,'Border', 'Tight')

end