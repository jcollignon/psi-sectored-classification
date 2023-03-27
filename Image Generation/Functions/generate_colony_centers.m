function [circle_centers] = generate_colony_centers(num_circles, padding)

    circle_centers = zeros(num_circles, 2);
    pick_center = 1;
    
    while pick_center <= num_circles
        pick_r = rand;
        pick_theta = 2*pi*rand;
        circle_centers(pick_center, 1) = pick_r*cos(pick_theta); % pick the x
        circle_centers(pick_center, 2) = pick_r*sin(pick_theta); % pick the y
        circle_centers(pick_center, :) = 30*circle_centers(pick_center, :); % extend radius by a factor of 30
        
        % Check if this circle is far enough away from another circle
        
        if pick_center > 1
            center_dist = sqrt((circle_centers(1:pick_center-1,1) - circle_centers(pick_center,1)).^2 + (circle_centers(1:pick_center-1,2) - circle_centers(pick_center,2)).^2);
            if any(center_dist < (2 + padding))
                pick_center = pick_center - 1; % bad colony, count back
            end
        end
        pick_center = pick_center + 1; % move forward
    end
    
end