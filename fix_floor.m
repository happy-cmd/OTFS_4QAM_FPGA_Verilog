function [y] = fix_floor(x, q1, q2)
% y = x;
% format:      [S][q1].[q2]
x_r = real(x);
Signed = sign(x_r);
x_r = abs(x_r);
location = find(x_r > (2^(q1+q2)-1)*2^(-q2));
x_r(location) = (2^(q1+q2)-1)* 2^(-q2);
y_r = floor((x_r.*Signed)*2^q2) * 2^(-q2);

x_i = imag(x);
Signed = sign(x_i);
x_i = abs(x_i);
location = find(x_i > (2^(q1+q2)-1)*2^(-q2));
x_i(location) = (2^(q1+q2)-1)* 2^(-q2);
y_i = floor((x_i.*Signed)*2^q2) * 2^(-q2);

y = y_r + 1j*y_i;