function [l, r, t, b] = ellipse2bb(minor_axis, major_axis, angle, center_x, center_y) 

% minor_axis = 5
% major_axis = 10
% angle = deg2rad(10);
sin_angle = sin(angle);
cos_angle = cos(angle);
% center_x = 0;
% center_y = 0;

% We assume that the major axis is almost vertical (a face) and
% the minor axis is almost horizontal (a face).
t0 = atan2(-major_axis*tan(angle), minor_axis);
t1 = t0 - pi;
x0 = center_x + minor_axis * cos(t0) * cos_angle - major_axis * sin(t0) * sin_angle;
x1 = center_x + minor_axis * cos(t1) * cos_angle - major_axis * sin(t1) * sin_angle;
l = min(x0, x1);
r = max(x0, x1);

t0 = atan2(major_axis*cos_angle, (sin_angle*minor_axis));
t1 = t0 - pi;
y0 = center_y + minor_axis * cos(t0) * sin_angle + major_axis * sin(t0) * cos_angle;
y1 = center_y + minor_axis * cos(t1) * sin_angle + major_axis * sin(t1) * cos_angle;
t = min(y0, y1);
b = max(y0, y1);