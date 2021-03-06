
% IF IT DOESN'T EXIST, this ROMS_OBS_stations_YYYYMMDD.mat file is generated by
% plot_sealevel_ROMS_BRIFS_OBS('20060615','worstfit','/home/rissaga/new_setup/Archive/Outputs/ROMS/','/home/mlicer/BRIFSverif/plots/ROMS/')

iRead = true;
if iRead
    clc;clear
    strdate = '20060615';
    roms_matdir = '/home/mlicer/BRIFSverif/plots/ROMS/';
    matfile=[roms_matdir 'ROMS_OBS_stations_' strdate '.mat'];
    if exist(matfile,'file')
        load(matfile)
    else
        plot_sealevel_ROMS_BRIFS_OBS(strdate,'worstfit','/home/rissaga/new_setup/Archive/Outputs/ROMS/','/home/mlicer/BRIFSverif/plots/ROMS/')
        load(matfile)
    end
end


iPlotgH=true;
iPlotParentSSH=false;
iPlotParentUV=false;
iPlotChild = false;

if iPlotgH
lonmin = min(min(lon_parent));
lonmax = max(max(lon_parent));
latmin = min(min(lat_parent));
latmax = max(max(lat_parent));    
    g = 9.81;
    figure(4);clf;hold on
    % add coastline:
    width=1;
    bathymetry = bathy_parent;
    bathymetry(bathy_parent==min(min(bathy_parent)))=NaN;
    cf = sqrt(g * squeeze(bathymetry));
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    
    cvec = [25,27,35];
%     fcvec = [0,25,50,75,150,300,600,1200, 1800, 2400, 3000];
    pcolor(lon_parent,lat_parent,cf);shading flat
    colormap(othercolor('Spectral5'))
    caxis([0 160])
    colorbar
    
    contour(lon_parent,lat_parent,squeeze(cf),cvec,'Color',[0.1 0.1 0.1]);

    
    title('Shallow water wave velocity [m/s]: c_f^2 = gH')

        xlim([lonmin lonmax])
        ylim([latmin latmax])    
    grid on 
    box on
    set(gca,'layer','top')
        pngname=[roms_matdir 'shallowWaterSpeed.png'];
        print(pngname,'-dpng','-r300')    
end


startdate = datenum('2006061517','yyyymmddHH');
enddate = datenum('2006061603','yyyymmddHH');


lonmin = min(min(lon_parent));
lonmax = max(max(lon_parent));
latmin = min(min(lat_parent));
latmax = max(max(lat_parent));
[~,idx_start] = min(abs(startdate - time_parent));
[~,idx_end] = min(abs(enddate - time_parent));
datestr(time_parent(idx_start),'yyyy mmm dd HH:MM');
datestr(time_parent(idx_end),'yyyy mmm dd HH:MM');

ssh_hf = removeROMSLowFrequencies(zeta_parent);
u_hf = removeROMSLowFrequencies(ubar_parent);
v_hf = removeROMSLowFrequencies(vbar_parent);


t_lowres =1:30:length(time_parent);
t_hires = idx_start:idx_end;

if iPlotParentSSH
    
    
    
    %     ssh_hf = zeta_parent;
    
    % return
    close all
    
    
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
        caxis([-.1 .1])
        
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




if iPlotParentUV
    figure(3);clf;hold on
    % add coastline:
    width=1;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    
    cvec = -[0,25,50,75,150,300,600,1200, 1800, 2400, 3000];
%     contourf(lon_parent,lat_parent,squeeze(-bathy_parent),cvec);
    contour(lon_parent,lat_parent,squeeze(-bathy_parent),cvec,'Color',[0.8 0.8 0.8]);
    colormap(flipud(othercolor('Blues9')))
    colorbar
    qstep =3;
    
    
    for k = t_hires
        k
        datestr(time_parent(k),'yyyy-mm-dd HH:MM')
        
        vtmp = squeeze(v_hf(k,:,:));
        F = TriScatteredInterp(lon_v_parent(:),lat_v_parent(:),vtmp(:));
        v_at_u = F(lon_u_parent,lat_u_parent);
        %         vel_hf = sqrt(squeeze(u_hf(k,:,:)).^2 + v_at_u.^2);
        
        try
            delete(h1)
        catch
        end
        
        %         contourf(lon_u_parent,lat_u_parent,squeeze(vel_hf));
        
        %         caxis([-1e-2, 1e-2])
        h1=quiver(lon_u_parent(1:qstep:end,1:qstep:end),lat_u_parent(1:qstep:end,1:qstep:end),...
            squeeze(u_hf(k,1:qstep:end,1:qstep:end)),squeeze(v_at_u(1:qstep:end,1:qstep:end)),3,'k');shading flat
        pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat;alpha(0.0)
        
        pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat
        
        
        colorbar
        colormap(othercolor('BuDRd_18'))
        caxis([-0.1 0.1])
        contour(lon_parent,lat_parent,squeeze(-bathy_parent),cvec,'Color',[0.8 0.8 0.8]);
        
        geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
        
        title(['ROMS HF currents and elevations [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        
        
        %     colorbar
        %     colormap(othercolor('BuDRd_18'))
        %     caxis([-.1 .1])
        
        %     set(gca,'xtick',ceil(lonmin):0.5:floor(lonmax))
        %     set(gca,'ytick',ceil(latmin):0.5:floor(latmax))
        set(gca,'fontsize',18)
        
        grid on
        set(gca,'Layer','top')
        box on
        set(gca,'Layer','top')
        
        
        pngname=[roms_matdir 'ROMS_UVSSH_HF_' datestr(time_parent(k),'yyyymmddHHMM') '.png'];
        print(pngname,'-dpng','-r300')
        
        
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