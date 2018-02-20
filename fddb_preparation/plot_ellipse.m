function plot_ellipse(minor_axis, major_axis, angle, center_x, center_y) 

cos_angle = cos(angle);
sin_angle = sin(angle);

k = linspace(0,2*pi);
x = center_x + minor_axis .* cos(k) .* cos_angle - major_axis .* sin(k) .* sin_angle;
y = center_y + minor_axis .* cos(k) .* sin_angle + major_axis .* sin(k) .* cos_angle;
plot(x, y, 'b', 'LineWidth', 2);
