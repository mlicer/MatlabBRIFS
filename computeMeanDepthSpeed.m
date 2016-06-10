function  [meanDepthAlongContour, meanShallowWaterSpeedAlongContour] = computeMeanDepthSpeed(maxTrajectory)
% compute mean depth along the maximum contour:
%     distance(lat1,lon1,lat2,lon2)
    Rearth = 6371000;
    distancesAlongContour = [];
    depthsAlongContour = [];
    for i = 1:numel(maxTrajectory(:,1))-1
       distancesAlongContour = [distancesAlongContour; distance([maxTrajectory(i,2),maxTrajectory(i,1)],[maxTrajectory(i+1,2),maxTrajectory(i+1,1)],'gc')];
       depthsAlongContour = [depthsAlongContour; maxTrajectory(i,3)];
    end
    
    % mean depth along contour = \int H(l) dl / \int dl:
    
    meanDepthAlongContour = dot(distancesAlongContour,depthsAlongContour) / sum(distancesAlongContour);
    
    meanShallowWaterSpeedAlongContour = sqrt(9.81 * meanDepthAlongContour)
    
end