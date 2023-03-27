function plot_sectors(this_center, circle_rad, sector_endpoints, random_color_red_colony, theta)

num_sectors = length(sector_endpoints)/2;
sector_points = zeros(length(theta) + 2,2);
sector_points(1,:) = this_center;
sector_points(end,:) = this_center;

for this_sector = 1:num_sectors
    
    sector_arc = linspace(sector_endpoints(2*this_sector - 1), sector_endpoints(2*this_sector), length(sector_points)-2);
    %sector_points(2:end-1,:) = this_center + [circle_rad*cos((sector_rand(this_sector).*theta) + sector_trans_rand(this_sector))' circle_rad*sin((sector_rand(this_sector).*theta) + sector_trans_rand(this_sector))'];
    sector_points(2:end-1,:) = this_center + [circle_rad*cos(sector_arc)' circle_rad*sin(sector_arc)'];
    
    %figure(1)
    fill(sector_points(:,1),sector_points(:,2), random_color_red_colony, 'LineStyle','none')
    
end

end