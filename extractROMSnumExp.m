function zetaAtROMSpoints = extractROMSnumExp(zeta_parent,zeta_child,lon2_parent,lat2_parent,lon2_child,lat2_child,stationNames,pointLons,pointLats)

for k = 1:length(pointLons)   
    if strcmp(stationNames(k),'Ciutadella')
        [i,j] = find_latlon_point_index(pointLons(k),pointLats(k),lon2_child,lat2_child);
        zetaAtROMSpoints(k).child = squeeze(zeta_child(i,j,:));
         zetaAtROMSpoints(k).parent = [];
    else
        [i,j] = find_latlon_point_index(pointLons(k),pointLats(k),lon2_parent,lat2_parent);
        zetaAtROMSpoints(k).parent = squeeze(zeta_parent(i,j,:));
        zetaAtROMSpoints(k).child = [];
    end
end

