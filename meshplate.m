function [plate,rho,theta] = meshplate(Img)
plate = Img;
[rows, cols] = size(Img);
x = -1 + (1/cols) : (2/cols) : 1 - (1/cols);
y = 1 - (1/rows) : -(2/rows) : -1 + (1/rows);
[X, Y] = meshgrid(x, y);
[t, r] = cart2pol(X,Y);
logic = t<0;
theta = zeros(rows,cols);
theta(logic) = t(logic) + 2*pi;
theta(~logic) = t(~logic);
logic = r>1;
rho = zeros(rows,cols);
rho(logic) = 0.5;
rho(~logic) = r(~logic);
plate(logic) = 0;
end
