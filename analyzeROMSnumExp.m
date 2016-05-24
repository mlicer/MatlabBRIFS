% This function analyzed ROMS numerical experiments
clc;clear

iPlotMap = true;
iExtract = false;
iAnalyze = true;

romsdir = '/home/rissaga/new_setup/ROMS_numExp/Outputs/';
outputdir = '/home/mlicer/BRIFSverif/numExp/';

stations.names = {'SaRapita','CapSalinas','ClFiguera','PtColom','PtCristo',...
    'Capdepera','SWChannel','NEChannel','OffCiutadella','Ciutadella',...
    'Pollenca','CalaStVincent','PuntaBeca','SaCalobra','PtSoller',...
    'PtValdemossa','Banyalbufar','Dragonera','NWChannel'}
stations.lats = [39.2837,39.2157,39.314477,39.3969,39.5099,...
    39.6603,39.7503,39.975,39.990648,39.999960,...
    39.9151,39.9675,39.9376,39.8927,39.8478,...
    39.7653,39.727847,39.5926,39.8852]
stations.lons = [2.8838,3.1084,3.216872,3.4111,3.4795,...
    3.5967,3.6455,3.6455,3.815416,3.831503,...
    3.2646,3.1084,2.9521,2.787121,2.675357,...
    2.575955,2.498876,2.284622, 3.408365]

if iExtract
    filesp = dir([romsdir 'romsBRIFS*parent*his*']);
    filesc = dir([romsdir 'romsBRIFS*child*his*'])
    filesc0 = dir([romsdir 'roms_BRIFS*child*_t0_his*'])
    % t0 files are missing from romsBRIFS list so i add them by hand:
    k=1
    nel = numel(filesc);
    for i = 1:numel(filesc0)
        filesc0(i).name
        filesc(nel+i).name = filesc0(i).name
        
    end

    %%
    readMetadata=true;
    
    for k = 1:numel(filesc)
        
        %         fnamep = [romsdir filesp(k).name]
        fnamec = [romsdir filesc(k).name]
        fnamep = strrep(fnamec,'child','parent')
        tmp = regexp(fnamep, '_c*', 'split');
        cg=tmp{5}
        numexp(k).cg = str2num(cg);
        tmp = regexp(fnamep, '_a*', 'split');
        amplitude=tmp{6}
        numexp(k).amplitude = str2num(amplitude);
        tmp = regexp(fnamep, '_t*', 'split');
        theta=tmp{7}
        numexp(k).theta = str2num(theta);
        
        
        if readMetadata
            ocean_time_parent = ncread(fnamep,'ocean_time');
            lon2d_parent = ncread(fnamep,'lon_rho');
            lat2d_parent = ncread(fnamep,'lat_rho');
            mask2d_parent = ncread(fnamep,'mask_rho');
            bathy_parent = ncread(fnamep,'h');
            ocean_time_child = ncread(fnamec,'ocean_time');
            lon2d_child = ncread(fnamec,'lon_rho');
            lat2d_child = ncread(fnamec,'lat_rho');
            mask2d_child = ncread(fnamec,'mask_rho');
            bathy_child = ncread(fnamec,'h');
            readMetadata=false;
        end
        
        disp(['Reading ROMS elevations from ' fnamep])
        zeta_parent = ncread(fnamep,'zeta');
        disp(['Reading ROMS elevations from ' fnamec])
        zeta_child = ncread(fnamec,'zeta');
        
        numexp(k).stations.zeta = extractROMSnumExp(zeta_parent,zeta_child,...
            lon2d_parent,lat2d_parent,lon2d_child,lat2d_child,...
            stations.names,stations.lons,stations.lats);
        
    end
    
    clearvars zeta_child zeta_parent iPlotMap iExtract iAnalyze
    save([outputdir 'numericalExperimentsData.mat'])
    
else
    load([outputdir 'numericalExperimentsData.mat'])
    numexp
end

%%
iAnalyze = true;
if iAnalyze
    shortnames = {'SRp','CSL','CLF','PtCL','PtCr',...
        'CDp','SWC','NEC','OCtd','Ctd',...
        'Pllnc','CalStVc','PunBc','SaCal','PtSoll',...
        'PtVld','Bbf','Drgnr','NWC'}
    % SSH at stations depending on cg, theta
    stationMaxElevs = zeros([length(numexp),length(stations.names)]);
    speeds = zeros([length(numexp),length(stations.names)]);
    angles = zeros([length(numexp),length(stations.names)]);
    stationMaxElevs(stationMaxElevs==0)=NaN;
    speeds(speeds==0)=NaN;
    angles(angles==0)=NaN;
    % loop over cg
    for n = 1:length(numexp)
        n
        for s = 1: length(stations.names)
            s
            size(speeds)
            speeds(n,s) = numexp(n).cg;
            angles(n,s) = numexp(n).theta;
            
            if strcmp(stations.names{s},'Ciutadella')
                stationMaxElevs(n,s) = max(numexp(n).stations.zeta(s).child);
            else
                stationMaxElevs(n,s) = max(numexp(n).stations.zeta(s).parent);
            end
            
            
            
        end
        
    end
    
    
    iPlotMap=true
    
    nx = length(unique(angles(:,1)));
    ny = length(unique(speeds(:,1)));
    dimvc=[nx,ny]
    speeds2 = reshape(speeds(:,1),dimvc);
    angles2 = reshape(angles(:,1),dimvc);
    speeds1 = speeds2(1,:)
    angles1 = angles2(:,1)'
    
    for s = 1: length(stations.names)
        stationMaxElevs2 = reshape(stationMaxElevs(:,s),dimvc);
        
        if iPlotMap
            figure(2);clf
            bar3c(stationMaxElevs2,angles1,speeds1,[],jet(50));
            view([0 90])
            
            
            set(gca,'XTick',angles1)
            set(gca,'YTick',speeds1)
            title({'Maximum SSH(c_g,\theta) in [m] ';['during numerical experiments at ' stations.names{s}]})
            xlabel('Pressure wave propagation angle [\circ] (0 = N, 90 = E) ')
            ylabel('Pressure wave group velocity c_g [m/s]')
            caxis([0 1])
            grid on
            box on
            colorbar
            set(gca, 'Position', get(gca, 'OuterPosition') - ...
                get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
            pngname =[outputdir 'numExp_maxSSH_' stations.names{s} '.png']
            print(pngname,'-dpng','-r100')
            
                    epsname =[outputdir 'numExp_maxSSH_' strrep(stations.names{s},' ','') '.eps']
                    print(epsname,'-depsc','-r100')
        end
    end
    
    
    for a =1:size(angles2,1)
        figure(3);clf
        
        for sp = 1:size(speeds2,2)
            subplot(size(speeds2,2),1,sp)
            angle0 = angles2(a,1)
            speed0 = speeds2(1,sp);
            [r,c,v] = find(speeds==speed0 & angles==angle0)
            sshCut = stationMaxElevs(r,:);
            sshCut = sshCut(1,:);
            
            locations = [2,3,5,6,9,10];
            places = stations.names(locations);
            plot(stations.lats(locations),sshCut(locations),'-dr','MarkerFaceColor','r')
            text(stations.lats(locations),sshCut(locations),shortnames(locations))
            %     set(gca,'XTick',locations)
            %     set(gca,'XtickLabel',places)
            xlim([39 40.2])
            ylim([0 1.1])
            
                title(['cg =' num2str(speed0) ' and \theta = ' num2str(angle0)])

            if sp<size(speeds2,2)
%                  set(gca, 'XTickLabels', []);
                ylabel('Max SSH [m]')

            else
                
                xlabel('Latitude of SSH location along East Mallorcan coast')
                ylabel('Max SSH [m]')
            end
            pbaspect([3 1 1])
            grid on
            box on
            
        end
        
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 21 29.7]);

        pngname =[outputdir 'maxSSH_Alltheta' num2str(angle0) '.png']
        print(pngname,'-dpng','-r100')
        pdfname =[outputdir 'maxSSH_Alltheta' num2str(angle0) '.pdf']
        print(pdfname,'-dpdf','-r100')
    end
end



if iPlotMap
    
    lonmin = min(min(lon2d_parent));
    lonmax = max(max(lon2d_parent));
    latmin = min(min(lat2d_parent));
    latmax = max(max(lat2d_parent));
    
    figure(1);clf; hold on
    
    
    contourf(lon2d_parent,lat2d_parent,bathy_parent,[20]);shading flat
    contour(lon2d_parent,lat2d_parent,bathy_parent,[0,75],':b');shading flat
    scatter(stations.lons,stations.lats,45,'ob','filled')
    
    % add coastline:
    width=0.75;
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    geoshow([S.Lat], [S.Lon],'Color','r','LineWidth',width);
    
    h = text(stations.lons,stations.lats,stations.names','color','b')
    
    set(h, 'rotation', 0)
    xlim([lonmin lonmax])
    ylim([latmin latmax])
    pbaspect([1 1 1])
    colormap(flipud(bone))
    
    box on
    
    grid on
    set(gca,'layer','top')
    pbaspect([1 1 1])
    % set(gca, 'Position', get(gca, 'OuterPosition') - ...
    %     get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
    
    pngname= [outputdir 'map_mallorca_numExp_stations_75mIsobath.eps'];
    print(pngname,'-depsc','-r300')
    
    
end
