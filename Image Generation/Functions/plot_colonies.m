function plot_colonies(circle_centers, circle_radii, theta, random_color_white_colony)

num_circles = length(circle_radii);

for this_circle = 1:num_circles
    
    this_center = circle_centers(this_circle, :);
    this_radii = circle_radii(this_circle);
    circle_points = this_center + this_radii*[cos(theta)' sin(theta)'];
    circle_points(end,2) = circle_points(1,2);
    
    %random_color_white_colony = color_picker('colony_white');
    
    fill(circle_points(:,1),circle_points(:,2), random_color_white_colony, 'LineStyle','none')
    
end

end