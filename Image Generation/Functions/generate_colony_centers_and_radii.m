function [circle_centers, circle_radii] = generate_colony_centers_and_radii(num_circles, circle_size, circle_size_var, padding, inner_plate_radius, outer_plate_radius, min_border_distance)

circle_centers = zeros(num_circles, 2);
circle_radii = zeros(num_circles, 1);
pick_center = 1;

while pick_center <= num_circles
    pick_r = sqrt(rand);
    pick_theta = 2*pi*rand;
    circle_center_temp = inner_plate_radius*pick_r*[cos(pick_theta) sin(pick_theta)]; % pick the [x y], and extend radius by a factor of 30 which is the radius of the plate
    circle_radii_temp = circle_size + circle_size_var*(2*(rand - 0.5));
    
    % Check if this circle is far enough away from another circle
    
    if pick_center > 1
        center_dist = sqrt((circle_centers(1:pick_center-1,1) - circle_center_temp(1)).^2 + (circle_centers(1:pick_center-1,2) - circle_center_temp(2)).^2);
        if any(center_dist < (padding + circle_radii_temp + circle_radii(1:pick_center-1)))
            %pick_center = pick_center - 1; % bad colony, count back
            continue;
        end
        border_dist = outer_plate_radius - sqrt((circle_center_temp(1)).^2 + (circle_center_temp(2)).^2);
        if border_dist < circle_radii_temp + min_border_distance % if the colony is too close to the border, it could stick out of the plate.  That can't happen.
            continue;
        end
        
    end
    
    circle_centers(pick_center,:) = circle_center_temp;
    circle_radii(pick_center,:) = circle_radii_temp;
    pick_center = pick_center + 1; % move forward
end

end