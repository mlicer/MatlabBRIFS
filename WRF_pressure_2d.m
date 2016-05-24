
iRead=false;

if iRead
    clear
    strdate = '20060615';
    wrf_matdir='/home/mlicer/BRIFSverif/plots/WRF/';
    matfile = [wrf_matdir 'WRF_MSLP2D_' strdate '.mat'];
    
    if exist(matfile)
        load(matfile)
        disp('filtering....')
        Phf = removeWRFLowFrequencies(MSLP);
    else
        [time,lon_wrf,lat_wrf,MSLP] = readWRFnc(strdate,['/home/rissaga/new_setup/Archive/Outputs/WRF/' strdate '/'],'/home/mlicer/BRIFSverif/plots/WRF/');
        Phf = removeWRFLowFrequencies(MSLP);
    end
    
end

lonmin = min(min(lon_wrf));
lonmax = max(max(lon_wrf));
latmin = min(min(lat_wrf));
latmax = max(max(lat_wrf));

startdate = datenum('2006061421','yyyymmddHH');
enddate = datenum('2006061613','yyyymmddHH');
[~,idx_start] = min(abs(startdate - time));
[~,idx_end] = min(abs(enddate - time));
datestr(time(idx_start),'yyyy mmm dd HH:MM');
datestr(time(idx_end),'yyyy mmm dd HH:MM');

% return
close all
t_lowres =1:30:length(time);
t_hires = idx_start:idx_end;

figure(1);hold on
    % add coastline:
    width=1;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    

    
for k =t_hires
    %     meanP = mean(mean(squeeze(MSLP(k,:,:))));
    %     demeanP = squeeze(MSLP(k,:,:)-meanP)
    % pcolor(lon_wrf,lat_wrf,demeanP);shading flat
    datestr(time(k),'yyyy mm dd HH:MM')
    
    try
        delete(h1)
    catch
    end    
    h1=pcolor(lon_wrf,lat_wrf,squeeze(Phf(k,:,:)));shading flat
    title(['WRF MSL pressure anomaly HF component [hPa] on ' datestr(time(k),'yyyy mm dd HH:MM')],'fontsize',18)
    xlim([lonmin lonmax])
    ylim([latmin latmax])
    
    % add coastline:
%     width=1;
%     S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
%     geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
    
    colorbar
    colormap(othercolor('BuDRd_18'))
    caxis([-.6 .6])
    
    set(gca,'xtick',ceil(lonmin):1:floor(lonmax))
    set(gca,'ytick',ceil(latmin):1:floor(latmax))
    set(gca,'fontsize',18)
    
%     grid on
%     box on
    
    pngname=[wrf_matdir 'WRF_HFp_anomaly_' datestr(time(k),'yyyymmddHHMM') '.png'];
    print(pngname,'-dpng','-r72')
%     pause(0.01)
end
