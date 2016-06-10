function zetaAtROMSpoints = extractROMSnumExp(bathy_parent,bathy_child,zeta_parent,zeta_child,lon2_parent,lat2_parent,lon2_child,lat2_child,stationNames,pointLons,pointLats)

% loop over stations and extract elevations at station location:
for k = 1:length(pointLons)
    
    if strcmp(stationNames(k),'Ciutadella')
        k
        stationNames(k)
        
        % find station location index in ROMS grid:        
        [i,j] = find_latlon_point_index(pointLons(k),pointLats(k),lon2_child,lat2_child)
        
        % for some reason some files have time as the first dimension, and
        % some as last (???)
        [~,timeCol]=max(size(zeta_child));
        
        if timeCol==1
            zetaAtROMSpoints(k).child = squeeze(zeta_child(:,i,j))
        elseif timeCol==3
            zetaAtROMSpoints(k).child = squeeze(zeta_child(i,j,:))
        else
            error('extractROMSnumExp: COULD NOT FIND TIME DIMENSION!')
        end
        zetaAtROMSpoints(k).parent = [];
        zetaAtROMSpoints(k).depth =bathy_child(i,j);
    else
        
        % find station location index in ROMS grid:
        [i,j] = find_latlon_point_index(pointLons(k),pointLats(k),lon2_parent,lat2_parent);
        
        zetaAtROMSpoints(k).depth = bathy_parent(i,j);
        
        % for some reason some files have time as the first dimension, and
        % some as last (???)
        [~,timeCol]=max(size(zeta_parent));        
        if timeCol==1
            zetaAtROMSpoints(k).parent = squeeze(zeta_parent(:,i,j));
        elseif timeCol==3
            zetaAtROMSpoints(k).parent = squeeze(zeta_parent(i,j,:));
        else
            error('extractROMSnumExp: COULD NOT FIND TIME DIMENSION!')
        end
        zetaAtROMSpoints(k).child = [];
    end
end

