function plot_border(inner_circle, outer_circle, num_cuts, random_color_border)

for this_cut = 1:(num_cuts - 1)
    x_bounds = [inner_circle(this_cut,1) outer_circle(this_cut,1) outer_circle(this_cut+1,1) inner_circle(this_cut+1,1)];
    y_bounds = [inner_circle(this_cut,2) outer_circle(this_cut,2) outer_circle(this_cut+1,2) inner_circle(this_cut+1,2)];
    
    patch(x_bounds, y_bounds, random_color_border, 'LineStyle', 'none')
    
end

end