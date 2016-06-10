% This script reads specified ROMS netCDF or matfile from a numerical experiment (see plotting flags below)
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
% track maximum in the shelf region of ROMS parent domain:
iTrackMaximum = false;

% operational mode: 'oper' or 'hind'
operMode = 'hind'
% folder with ROMS netCDFs:
romsdir = '/home/rissaga/new_setup/ROMS_numExp/Outputs/croppedMovedNumExp/'
% date:
strdate = '20150611';
% folder with ROMS mat files, extracted by this code:
roms_matdir = '/home/mlicer/BRIFSverif/plots/ROMS/';

filename_parent = [romsdir 'BRIFS_parent_c32_a3_t50_w05_his.nc']
filename_child = strrep(filename_parent,'parent','child')

% lateral width of the pressure wave: set by hand for file and figure naming
latwidth = '1'

% extract parameters from filename:
i0 = strfind(filename_parent,'_c');
i1 = strfind(filename_parent,'_his');
params = filename_parent(i0:i1-1)

% output directory for plots and matfiles:
outputdir = ['/media/mlicer/LOCALDATA/BRIFSverif/numExp/' params(2:end) '/']
output_matfile = [outputdir 'numexp_' params '.mat'];
system(['mkdir -p ' outputdir])

% width of coastline contour:
mapLineWidth=1;
% timewindow for plotting hi-resolution in time snapshots (see time_iter = t_hires/t_lowres):
startdate = datenum('201506110456','yyyymmddHHMM');
enddate = datenum('201506110514','yyyymmddHHMM');

% initialize figure number:
fignum=1;

if iRead
    % read netCDF
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
    bathy_child=nc_varget(filename_child,'h');
    
    % set domain boundaries:
    lonmin = min(min(lon_parent));
    lonmax = max(max(lon_parent));
    latmin = min(min(lat_parent));
    latmax = max(max(lat_parent));
    
    % set timewindow:
    [~,idx_start] = min(abs(startdate - time_parent));
    [~,idx_end] = min(abs(enddate - time_parent));
    datestr(time_parent(idx_start),'yyyy mmm dd HH:MM');
    datestr(time_parent(idx_end),'yyyy mmm dd HH:MM');
    
    t_lowres =1:30:length(time_parent);
    t_hires = idx_start:idx_end;
    
    % set time loop vector:
    time_iter = t_lowres;
    
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
    
    
    % extract elevations at location points from netCDFs:
    points_zeta = extractROMSnumExp(bathy_parent,bathy_child,zeta_parent,zeta_child,...
        lon_parent,lat_parent,lon_child,lat_child,...
        stations.names,stations.lons,stations.lats);
else
    load(output_matfile)
end





if iTrackMaximum
    % channel domain:
    clonmin = 3.5; clonmax = 3.9;
    clatmin = 39.5; clatmax = 40.05;
    
    % mid channel line (for cropping maximum tracking if neccessary):
    lonC = 3.824231;
    latC = 39.947595;
    midChannelLine = @(x) 0.1931*(x-lonC) + latC;
    
    % find which dimension is time dimension: for some reason it is NOT always
    % the same (??):
    [~,timeCol]=max(size(zeta_parent));
    
    maxTrajectory = [];
    % loop over times:
    for t = time_iter
        % extract elevations depending on which dimension is time:
        if timeCol==1
            elevSnapshot = squeeze(zeta_parent(t,:,:));
        elseif timeCol==3
            elevSnapshot = squeeze(zeta_parent(:,:,t));
        else
            error(['zeta_parent has weird dimensions: ' size(zeta_parent)])
        end
        % crop to channel (we don't care about maximums elsewhere):
        imin = min(find(lon_parent(1,:)>=clonmin));
        imax = max(find(lon_parent(1,:)<=clonmax));
        jmin = min(find(lat_parent(:,1)>=clatmin));
        jmax = max(find(lat_parent(:,1)<=clatmax));
        
        elevSnapshot = elevSnapshot(jmin:jmax,imin:imax);
        lonChannel = lon_parent(jmin:jmax,imin:imax);
        latChannel = lat_parent(jmin:jmax,imin:imax);
        batChannel = bathy_parent(jmin:jmax,imin:imax);
        
        % further limit to the SOUTHERN part of the channel (to prevent 
        % alternation between north and south arms of SSH anomaly):
        for j = 1:size(elevSnapshot,1)
            for i = 1:size(elevSnapshot,2)
                if i<=2 | latChannel(j,i) > midChannelLine(lonChannel(j,i))
                    elevSnapshot(j,i)=NaN;
                end
            end
        end
        
        % find maximum ANOMALY (not maximum ELEVATION):
        [row,col,val] = find(abs(elevSnapshot) == max(max(abs(elevSnapshot))))

        % cut away boundary points: 
        offset=0.01;
        if batChannel(round(row),round(col)) < 20.2 | max(max(abs(elevSnapshot)))==0 | ...
                abs(lonChannel(round(row),round(col))-clonmin)<offset | ...
                abs(lonChannel(round(row),round(col))-clonmax)<offset
            continue
        else
            % append maximum within the domain:
            maxTrajectory = [maxTrajectory; [lonChannel(round(row),round(col)),...
                latChannel(round(row),round(col)),...
                batChannel(round(row),round(col)),...
                abs(elevSnapshot(row,col))]];
            
        end
    end

    % compute mean depth along the maximum contour:
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
    
    % plot maximum trajectory:
    figure(fignum);clf;hold on
    fignum = fignum+1;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    for i = 1:numel(maxTrajectory(:,1))-1
        plot([maxTrajectory(i,1),maxTrajectory(i+1,1)],...
            [maxTrajectory(i,2),maxTrajectory(i+1,2)],'-ob',...
            'linewidth',1)
    end
    %     scatter(maximumLocation(:,1),maximumLocation(:,2),20,maximumLocation(:,3),'filled')
    contour(lon_parent, lat_parent,bathy_parent,[0,25,50,75,100,125,150,200,300,400,500,1000,1500,1750,2000,2500],'linecolor',[.8 .8 .8])
    title({['Trajectory of the maximum SSH anomaly for params: ' strrep(params, '_',' ')];...
        ['Mean depth along the maximum contour <H> = \int H(l)dl / \int dl = ' num2str(meanDepthAlongContour) ' m'];...
        ['Shallow water velocity (g <H>)^{0.5} = ' num2str(meanShallowWaterSpeedAlongContour) ' m/s']})
    xlim([lonmin,lonmax])
    ylim([latmin,latmax])
    grid on
    box on
    
    % add coastline:
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
    
    % save:
    pngname=[outputdir 'maxTrajectory' params '.png'];
    print(pngname,'-dpng','-r300')
end

%% plot gH:
if iPlotgH
    % just a plot of sqrt(gH) on ROMS parent domain:
    lonmin = min(min(lon_parent));
    lonmax = max(max(lon_parent));
    latmin = min(min(lat_parent));
    latmax = max(max(lat_parent));
    g = 9.81;
    figure(fignum);clf;hold on
    fignum=fignum+1;
    % add coastline:
    width=1;
    bathymetry = bathy_parent;
    bathymetry(bathy_parent==min(min(bathy_parent)))=NaN;
    cf = sqrt(g * squeeze(bathymetry));
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
    
    % add contours:
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
    pngname=[outputdir 'shallowWaterSpeed.png'];
    print(pngname,'-dpng','-r300')
end

%% plot Point elevations:
if iPlotStationElevs
    % plot time_iter snapshots of SSH on ROMS child domain:
    shortnames = {'SRP','CPS','CLF','PTCl','PTCr',...
        'CPD','SWC','NEC','OffCIUT','CIUT',...
        'C1','C2','C3','C4','C5',...
        'PLL','CSV','PTB','SCL','PTS',...
        'PVDM','BNYB','DGN','NW'}
    
    % initialize max anomalies at station points:
    maxAnomalies = zeros([numel(stations.names),1]);
    % initialize ocean depths at station points:
    pointDepths = zeros([numel(stations.names),1]);
    
    % loop over stations:
    for k = 1:numel(stations.names)
        % read child or parent:
        if ~isempty(points_zeta(k).parent)
            maximum = max(abs(points_zeta(k).parent));
        else
            maximum = abs(max(points_zeta(k).child));
        end
        % append child or parent:
        pointDepths(k) = points_zeta(k).depth;
        maxAnomalies(k) = maximum;
    end
    
    % which locations do you want to plot. (Last point should be CIUTADELLA! See below.) 
%         stations.names = {'SaRapita','CapSalinas','CalaFiguera','PtColom','PtCristo',...
%         'Capdepera','SWChannel','NEChannel','OffCiutadella','Ciutadella',...
%         'Channel1','Channel2','Channel3','Channel4','Channel5',...
%         'Pollenca','CalaStVincent','PuntaBeca','SaCalobra','PtSoller',...
%         'PtValldemossa','Banyalbufar','Dragonera','NWChannel'}
    locindex = [2,3,4,5,6,11,12,13,14,15,9,10];
    
    figure(fignum);clf;hold on
    fignum=fignum+1;
    
    fntsize = 12;
    % plot SSH anomalies at stations location:
    plot(stations.lats(locindex),maxAnomalies(locindex),'-o','linewidth',2)
    % add shortname of location:
    text(stations.lats(locindex(1:end-1)),maxAnomalies(locindex(1:end-1)),...
        shortnames(locindex(1:end-1)),'Color','r','fontsize',6,'fontsize',fntsize)
    % add last point CIUTADELLA (see above!) as a separate line to avoid
    % overlap with OFF CIUTADELLA point:
    text(stations.lats(locindex(end)),maxAnomalies(locindex(end)),...
        shortnames(locindex(end)),'Color','r','fontsize',6,'fontsize',fntsize)
    % add ocean depth at station location (again, CIUTADELLA is added in a separate line):
    text(stations.lats(locindex(1:end-1)),maxAnomalies(locindex(1:end-1))-0.045,...
        num2str(ceil(pointDepths(locindex(1:end-1)))),'Color','r','fontsize',fntsize)
    text(stations.lats(locindex(end)),maxAnomalies(locindex(end))-0.045,...
        sprintf('%.f',pointDepths(locindex(end))),'Color','r','fontsize',fntsize)
    
    
    set(gca,'fontsize',18)
    
    grid on
    box on
    
    epsname =[outputdir 'stations_depths_maxAnomalies_w' latwidth params '.png']
    print(epsname,'-dpng','-r300')
    
end

%% plot SSH:

% remove low frequencies from SSH:
ssh_hf = removeROMSLowFrequencies(zeta_parent);


if iPlotParentSSH

    close all

    figure(fignum);clf;hold on
    fignum=fignum+1;    
    
    % add coastline:
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
    
    
    for k = time_iter
        datestr(time_parent(k),'yyyy-mm-dd HH:MM')
        
        try
            delete(h1)
        catch
        end
        
        h1=pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat
        title(['Width=' latwidth '^o ROMS SSH anomaly HF component [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
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
        
        pngname=[outputdir 'ROMS_SSH_HF_anomaly_' datestr(time_parent(k),'yyyymmddHHMM') '_w' latwidth params '.png'];
        print(pngname,'-dpng','-r72')
    end
end



%% plot currents:
if iPlotParentUV
    u_hf = removeROMSLowFrequencies(ubar_parent);
    v_hf = removeROMSLowFrequencies(vbar_parent);
    
    figure(fignum);clf;hold on
    fignum=fignum+1;
    % add coastline:
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
    
    cvec = -[0,25,50,75,150,300,600,1200, 1800, 2400, 3000];
    %     contourf(lon_parent,lat_parent,squeeze(-bathy_parent),cvec);
    contour(lon_parent,lat_parent,squeeze(-bathy_parent),cvec,'Color',[0.8 0.8 0.8]);
    colormap(flipud(othercolor('Blues9')))
    colorbar
    qstep =3;
    
    
    for k = time_iter
        k
        datestr(time_parent(k),'yyyy-mm-dd HH:MM')
        
        % get current timestep:
        vtmp = squeeze(v_hf(k,:,:));
        
        % interpolate v to u grid locations in ROMS grid:
        F = TriScatteredInterp(lon_v_parent(:),lat_v_parent(:),vtmp(:));
        v_at_u = F(lon_u_parent,lat_u_parent);
        
        try
            delete(h1)
        catch
        end

        % plot UV vector field:
        h1=quiver(lon_u_parent(1:qstep:end,1:qstep:end),lat_u_parent(1:qstep:end,1:qstep:end),...
            squeeze(u_hf(k,1:qstep:end,1:qstep:end)),squeeze(v_at_u(1:qstep:end,1:qstep:end)),3,'k');shading flat
        pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat;alpha(0.0)
        
        % add SSH anomalies:
        pcolor(lon_parent,lat_parent,squeeze(ssh_hf(k,:,:)));shading flat
        
        
        colorbar
        colormap(othercolor('BuDRd_18'))
        caxis([-0.1 0.1])
        contour(lon_parent,lat_parent,squeeze(-bathy_parent),cvec,'Color',[0.8 0.8 0.8]);
        
        geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
        
        title(['Width ' latwidth '^o ROMS HF currents and elevations [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        

        set(gca,'fontsize',18)
        
        grid on
        set(gca,'Layer','top')
        box on
        set(gca,'Layer','top')
        
        
        pngname=[outputdir 'ROMS_UVSSH_HF_' datestr(time_parent(k),'yyyymmddHHMM') '_w' latwidth params '.png'];
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
    
    
    figure(fignum);clf;hold on
    fignum=fignum+1;
    % add coastline:
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',mapLineWidth);
    
    
    for k = time_iter
        datestr(time_child(k),'yyyy-mm-dd HH:MM')
        
        try
            delete(h1)
        catch
        end
        
        % plot SSH anomaly in the harbour:
        h1=pcolor(lon_child,lat_child,squeeze(ssh_hf(k,:,:)));shading flat
        title(['Width ' latwidth '^o ROMS SSH anomaly HF component [m] on ' datestr(time_parent(k),'yyyy mm dd HH:MM')],'fontsize',18)
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
        
        pngname=[outputdir 'ROMS_SSH_HF_CIUT_anomaly_' datestr(time_parent(k),'yyyymmddHHMM') '_w ' latwidth params '.png'];
        print(pngname,'-dpng','-r72')
    end
end

%%
if iPlotMap
    
    bathymetry = bathy_parent;
    bathymetry(bathymetry==min(min(bathymetry)))=0;
    figure(fignum);clf;hold on
    fignum=fignum+1;
    pcolor(lon_parent,lat_parent,-bathy_parent); shading flat
    contour(lon_parent,lat_parent,bathy_parent,[20,20],'r')
    contour(lon_parent,lat_parent,bathy_parent,[75,75],'w')
    
    scatter(stations.lons,stations.lats,'ob','filled','markeredgecolor','w')
    %     text(stations.lons,stations.lats,num2str(ceil(pointDepths)))
    for k = 1:numel(maxAnomalies)
        
        cvec = othercolor('StepSeq_25',numel(maxAnomalies));
        
        if k==10;continue;end
        
        text(stations.lons(k),stations.lats(k)-0.02,sprintf('%.f m : %.2f m',...
            pointDepths(k), maxAnomalies(k)),'fontsize',6,'Color',cvec(k,:),'fontweight','bold')
    end
    title(['Width ' latwidth '^o Station locations and max SSH anomalies [m] at their locations'])
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
    
    
    
    
    epsname =[outputdir 'map_Mallorca_75m_isobath_stations' params '.png']
    print(epsname,'-dpng','-r300')
    
    
end

[outputdir 'numexp_' params '.mat']

% % save matfilescp:
if iTrackMaximum
    save(output_matfile,'bathy_parent','bathy_child','batChannel','lonChannel','latChannel',...
        'depthsAlongContour','distancesAlongContour','meanDepthAlongContour','maxTrajectory','lon_parent','lat_parent',...
        'params','points_zeta','stations')
else
    save(output_matfile,'bathy_parent','bathy_child','lon_parent','lat_parent',...
        'params','points_zeta','stations')
end