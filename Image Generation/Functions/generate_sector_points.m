function [sector_endpoints, num_sectors] = generate_sector_points

num_sectors = 1;
%sector_points = zeros(length(theta) + 2,2);
%sector_points(1,:) = this_center;
sector_rand = rand; % how large is the sector?
sector_trans_rand = 2*pi*rand; % where does the sector start?
%sector_points(2:end-1,:) = this_center + [circle_rad*cos((sector_rand.*theta) + sector_trans_rand)' circle_rad*sin((sector_rand.*theta) + sector_trans_rand)'];
%sector_points(end,:) = sector_points(1,:);

sector_endpoints = [sector_trans_rand (2*pi*sector_rand + sector_trans_rand)];

end