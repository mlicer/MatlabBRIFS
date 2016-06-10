%   Example (Gaussian bar plot):
    M = 50; % grid resolution
    x = linspace(-3,3,M); % x-grid
    y = linspace(-3,3,M); % y-grid
    C = [0.3 -0.2; -0.2 0.6]; % covariance
    [X,Y] = meshgrid(x,y);
    XY = [X(:) Y(:)]; % grid pairs
    Z = 1/sqrt(det(2*pi*C))*exp(-1/2*sum((XY/C).*XY,2));
    Z = reshape(Z,[M,M]);
    close all
    figure(1);
    bar3c(Z,x,y,[],jet(50))