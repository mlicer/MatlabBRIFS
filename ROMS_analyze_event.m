% This script reads specified ROMS netCDF or matfile from a past rissaga event (see plotting flags below)
% and plots many different things...

% read netCDF:
iRead = true;

%% set plotting flags:
% plot map of mallorca along with station locations and bathymetry:
iPlotMap = false
% plot map of sqrt(gH) on ROMS parent domain:
iPlotgH=false;
% plot time_iter snapshots of SSH on ROMS parent domain:
iPlotParentSSH=false;
% plot time_iter snapshots of SSH and UV vector field on ROMS parent domain:
iPlotParentUV=false;
% plot station elevations along the southern shelf into Ciutadella:
iPlotStationElevs = true;
% plot time_iter snapshots of SSH on ROMS child domain:
iPlotChild = false;


% operational mode: 'oper' or 'hind'
operMode = 'hind'
% folder with ROMS netCDFs:
romsdir = '/home/rissaga/new_setup/Archive/Outputs/ROMS/'
% date:
strdate = '20060614';
% folder with ROMS mat files, extracted by this code:
roms_matdir = '/home/mlicer/BRIFSverif/plots/ROMS/';
% output directory for plots and matfiles:
outputdir ='/media/mlicer/LOCALDATA/BRIFSverif/Rissaga20060615/';

filename_parent = [romsdir 'roms_BRIFS_parent_' strdate '_' operMode '_his.nc'];
filename_child = strrep(filename_parent,'parent','child');

if iRead
    
    
    disp(['   Reading parent model file ' filename_parent  ' ...']);
    lon_parent=nc_varget(filename_parent,'lon_rho');
    lat_parent=nc_varget(filename_parent,'lat_rho');
    
    time_parent=nc_varget(filename_parent,'ocean_time')/(3600*24)+datenum(1968,5,23);
    nt_parent=length(time_parent);
    
    zeta_parent=nc_varget(filename_parent,'zeta');
    bathy_parent=nc_varget(filename_parent,'h');
    
    lon_u_parent=nc_varget(filename_parent,'lon_u');
    lat_u_parent=nc_varget(filename_parent,'lat_u');
    lon_v_parent=nc_varget(filename_parent,'lon_v');
    lat_v_parent=nc_varget(filename_parent,'lat_v');
    
    ubar_parent=nc_varget(filename_parent,'ubar');
    vbar_parent=nc_varget(filename_parent,'vbar');
    
    disp(['   Reading child model file ' filename_child  ' ...']);
    lon_child=nc_varget(filename_child,'lon_rho');
    lat_child=nc_varget(filename_child,'lat_rho');
    time_child=nc_varget(filename_child,'ocean_time')/(3600*24)+datenum(1968,5,23);
    nt_child=length(time_child);
    zeta_child=nc_varget(filename_child,'zeta');
    
    %% set stations for extraction:
    stations.names = {'SaRapita','CapSalinas','CalaFiguera','PtColom','PtCristo',...
        'Capdepera','SWChannel','NEChannel','OffCiutadella','Ciutadella',...
        'Channel1','Channel2','Channel3','Channel4','Channel5',...
        'Pollenca','CalaStVincent','PuntaBeca','SaCalobra','PtSoller',...
        'PtValldemossa','Banyalbufar','Dragonera','NWChannel'}
    stations.lats = [39.2837,39.2157,39.314477,39.3969,39.5099,...
        39.6603,39.7503,39.975,39.990648,39.999960,...
        39.709045, 39.809337, 39.870496, 39.922122, 39.974762, ...
        39.9151,39.9675,39.9376,39.8927,39.8478,...
        39.7653,39.727847,39.5926,39.8852]
    stations.lons = [2.8838,3.1084,3.216872,3.4111,3.4795,...
        3.5967,3.6455,3.6455,3.815416,3.831503,...
        3.544684,3.585882,3.661413,3.708105, 3.768530, ...
        3.2646,3.1084,2.9521,2.787121,2.675357,...
        2.575955,2.498876,2.284622, 3.408365]
    
    
    % read elevations at location points:
    points_zeta = extractROMSnumExp(bathy_parent,bathy_child,zeta_parent,zeta_child,...
        lon_parent,lat_parent,lon_child,lat_child,...
        stations.names,stations.lons,stations.lats);
    save([outputdir 'event_' strdate '.mat'],'bathy_parent','bathy_child','lon_parent','lat_parent',...
        'params','points_zeta','stations')
else
    load([outputdir 'event_' strdate '.mat'])
end



%% plot gH:
% just a plot of sqrt(gH) on ROMS parent domain:

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


%% plot Point elevations:
if iPlotStationElevs
    shortnames = {'SRP','CPS','CLF','PTCl','PTCr',...
        'CPD','SWC','NEC','OffCIUT','CIUT',...
        'C1','C2','C3','C4','C5',...
        'PLL','CSV','PTB','SCL','PTS',...
        'PVDM','BNYB','DGN','NW'}
    maxAnomalies = zeros([numel(stations.names),1]);
    pointDepths = zeros([numel(stations.names),1]);
    
    for k = 1:numel(stations.names)
        if ~isempty(points_zeta(k).parent)
            maximum = max(abs(points_zeta(k).parent));
        else
            maximum = abs(max(points_zeta(k).child));
        end
        pointDepths(k) = points_zeta(k).depth;
        maxAnomalies(k) = maximum;
    end
    
    locindex = [2,3,4,5,6,11,12,13,14,15,9,10];
    
    figure(fignum);clf;hold on
    fignum=fignum+1;
    
    fntsize = 12;
    plot(stations.lats(locindex),maxAnomalies(locindex),'-o','linewidth',2)
    text(stations.lats(locindex(1:end-1)),maxAnomalies(locindex(1:end-1)),...
        shortnames(locindex(1:end-1)),'Color','r','fontsize',6,'fontsize',fntsize)
    text(stations.lats(locindex(end)),maxAnomalies(locindex(end)),...
        shortnames(locindex(end)),'Color','r','fontsize',6,'fontsize',fntsize)
    
    text(stations.lats(locindex(1:end-1)),maxAnomalies(locindex(1:end-1))-0.045,...
        num2str(ceil(pointDepths(locindex(1:end-1)))),'Color','r','fontsize',fntsize)
    text(stations.lats(locindex(end)),maxAnomalies(locindex(end))-0.045,...
        sprintf('%.f',pointDepths(locindex(end))),'Color','r','fontsize',fntsize)
    
    
    set(gca,'fontsize',18)
    
    grid on
    box on
    
    epsname =[outputdir 'stations_depths_maxAnomalies_' strdate '.png']
    print(epsname,'-dpng','-r300')
    
end

%% plot SSH:
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



%% plot currents:
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

%% plot CIUTADELLA INLET elevations
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

%%
if iPlotMap
    
    bathymetry = bathy_parent;
    bathymetry(bathymetry==min(min(bathymetry)))=0;
    figure(11);clf;hold on
    pcolor(lon_parent,lat_parent,-bathy_parent); shading flat
    contour(lon_parent,lat_parent,bathy_parent,[20,20],'r')
    contour(lon_parent,lat_parent,bathy_parent,[75,75],'w')
    contour(lon_parent,lat_parent,bathy_parent,[77,77],':w')
    contour(lon_parent,lat_parent,bathy_parent,[80,80],'y')
    contour(lon_parent,lat_parent,bathy_parent,[105,105],'m')
    
    scatter(stations.lons,stations.lats,'ob','filled','markeredgecolor','w')
    %     text(stations.lons,stations.lats,num2str(ceil(pointDepths)))
    for k = 1:numel(maxAnomalies)
        
        cvec = othercolor('StepSeq_25',numel(maxAnomalies));
        
        if k==10;continue;end
        
        text(stations.lons(k),stations.lats(k)-0.02,sprintf('%.f m : %.2f m',...
            pointDepths(k), maxAnomalies(k)),'fontsize',6,'Color',cvec(k,:),'fontweight','bold')
    end
    title('Station locations and max SSH anomalies [m] at their locations')
    colormap(othercolor('RdGy11',100))
    colorbar
    grid on
    box on
    set(gca,'layer','top')
    %     colormap(othercolor('Spectral5',100))
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperOrientation', 'portrait');
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperType', 'A4');
    set(gcf, 'PaperPosition', [0 0 29.7 21]);
    
    
    
    
    epsname =[outputdir 'map_Mallorca_75m_isobath_stations.png']
    print(epsname,'-dpng','-r300')
    
    
end