function [k,phi0] = computeGeoLine(lon1,lat1,lon2,lat2)

k = (lat2-lat1)/(lon2-lon1);
phi0 = lat2 - k * lon2;