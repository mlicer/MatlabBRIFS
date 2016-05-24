function [I,J] = find_latlon_point_index(lon0,lat0,lon2d,lat2d)
% find indices of the closest grid point from 2D-grid lon2d,lat2d 
% to the single input point (lon0,lat0):
dist2 = sum(bsxfun(@minus, cat(3,lat0,lon0), cat(3,lat2d,lon2d)).^2,3);
[I,J] = find(dist2==min(dist2(:)));