


startdate = datenum('2015061123','yyyymmddHH');
enddate = datenum('2015061217','yyyymmddHH');

iPlotParent=false;
iPlotChild = true;

if iPlotParent
    lonmin = min(min(lon_parent));
    lonmax = max(max(lon_parent));
    latmin = min(min(lat_parent));
    latmax = max(max(lat_parent));
    [~,idx_start] = min(abs(startdate - time_parent));
    [~,idx_end] = min(abs(enddate - time_parent));
    datestr(time_parent(idx_start),'yyyy mmm dd HH:MM');
    datestr(time_parent(idx_end),'yyyy mmm dd HH:MM');
    
    ssh_hf = removeROMSLowFrequencies(zeta_parent);
    
    % return
    close all
    t_lowres =1:30:length(time_parent);
    t_hires = idx_start:idx_end;
    
    figure(1);hold on
    % add coastline:
    width=1;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    
    
    for k = t_hires
        datestr(time_parent(k),'yyyy-mm-dd HH:MM')
        
        try
            delete(h1)
        catch
        end
        
        h1=pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat
        title(['ROMS SSH anomaly HF component [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        
        
        colorbar
        colormap(othercolor('BuDRd_18'))
        caxis([-.02 .02])
        
        %     set(gca,'xtick',ceil(lonmin):0.5:floor(lonmax))
        %     set(gca,'ytick',ceil(latmin):0.5:floor(latmax))
        set(gca,'fontsize',18)
        
        grid on
        set(gca,'Layer','top')
        box on
        set(gca,'Layer','top')
        
        pngname=[roms_matdir 'ROMS_SSH_HF_anomaly_' datestr(time_parent(k),'yyyymmddHHMM') '.png'];
        print(pngname,'-dpng','-r72')
    end
end

if iPlotChild
    
    lonmin = min(min(lon_child));
    lonmax = max(max(lon_child));
    latmin = min(min(lat_child));
    latmax = max(max(lat_child));
    
    [~,idx_start] = min(abs(startdate - time_child));
    [~,idx_end] = min(abs(enddate - time_child));
    datestr(time_child(idx_start),'yyyy mmm dd HH:MM');
    datestr(time_child(idx_end),'yyyy mmm dd HH:MM');
    
    ssh_hf = removeROMSLowFrequencies(zeta_child);
    
    % return
    close all
    t_lowres =1:30:length(time_child);
    t_hires = idx_start:idx_end;
    
    figure(2);hold on
    % add coastline:
    width=1;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    
    
    for k = t_lowres
        datestr(time_child(k),'yyyy-mm-dd HH:MM')
        
        try
            delete(h1)
        catch
        end
        
        h1=pcolor(lon_child,lat_child,squeeze(ssh_hf(k,:,:)));shading flat
        title(['ROMS SSH anomaly HF component [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        
        
        colorbar
        colormap(othercolor('BuDRd_18'))
        caxis([-.1 .1])
        
        %     set(gca,'xtick',ceil(lonmin):0.5:floor(lonmax))
        %     set(gca,'ytick',ceil(latmin):0.5:floor(latmax))
        set(gca,'fontsize',18)
        
        grid on
        set(gca,'Layer','top')
        box on
        set(gca,'Layer','top')
        
        pngname=[roms_matdir 'ROMS_SSH_HF_CIUT_anomaly_' datestr(time_parent(k),'yyyymmddHHMM') '.png'];
        print(pngname,'-dpng','-r72')
    end
end