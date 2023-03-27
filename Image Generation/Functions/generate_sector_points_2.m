function [sector_endpoints, num_sectors] = generate_sector_points_2(sector_vector, num_sector_weights, min_sector_spacing, have_min_sector_spacing)

num_sectors = datasample(sector_vector, 1, 'Replace', true, 'Weights', num_sector_weights);
sector_endpoints = zeros(2*num_sectors, 1);
num_endpoints = length(sector_endpoints);

if num_endpoints == 0
    return
end

pick_sector_points = true;

while pick_sector_points
    for this_point = 1:num_endpoints
        sector_endpoints(this_point) = 2*pi*rand;
    end
    
    sector_endpoints = sort(sector_endpoints);
    
    diff_dist_points = zeros(2*num_sectors,1);
    
    % A sector can also be on the principle axis.  Have a quick process
    % for this.
    
    if rand >= 0.5 && ~isempty(sector_endpoints)
        sector_endpoints = circshift(sector_endpoints, -1);
        sector_endpoints(end) = sector_endpoints(end) + 2*pi;
    end
    
    for this_endpoint = 1:(num_endpoints-1)
        diff_dist_points(this_endpoint) = sector_endpoints(this_endpoint+1) - sector_endpoints(this_endpoint);
    end
    diff_dist_points(end) = abs((2*pi + sector_endpoints(1)) - sector_endpoints(end));
    
    if any(diff_dist_points <= (min_sector_spacing*have_min_sector_spacing))
        continue
    else
        pick_sector_points = false;
    end
    
end


end