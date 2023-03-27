function plot_light_streak(circle_center, circle_radius, prop_above_center, theta)

x_length = circle_radius*sqrt(1-prop_above_center^2);

x_ellipse = circle_center(1) + (x_length)*cos(theta);
y_ellipse = (circle_center(2) + circle_radius*prop_above_center) + (circle_radius/50)*sin(theta);
%plot(x_ellipse, y_ellipse)
fill(x_ellipse,y_ellipse,[255 255 255]/255,'LineStyle','none', 'FaceAlpha',0.5)