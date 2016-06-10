% This script is used for BULK analysis of ALL the ROMS numerical experiments 
% and plots maxSSH(theta, cf) matrices for all stations specified.

% RECOMMENDED PLAN OF WORK:
%   1. set iExtract=true to read all the netCDF files and extract relevant
% data at all the stations. This takes HOURS since there are many (140+)
% files for numerical experiments.
%   2. set iExtract=false and start playing around with the plots and
% analyses.

clc;clear

%  plot map of the bathymetry and the station locations:
iPlotMap = true;
% extract all 100+ netcdf files?
iExtract = false;
% analyze extracted data and find maximum SSH:
iAnalyze = true;

% folder with ROMS netCDFs:
romsdir = '/home/rissaga/new_setup/ROMS_numExp/Outputs/linkedFiles/';
% folder for output plots:
outputdir = '/home/mlicer/BRIFSverif/numExp/';

% set station names:
stations.names = {'SaRapita','CapSalinas','CalaFiguera','PtColom','PtCristo',...
    'Capdepera','SWChannel','NEChannel','OffCiutadella','Ciutadella',...
    'Channel1','Channel2','Channel3','Channel4','Channel5',...
    'Pollenca','CalaStVincent','PuntaBeca','SaCalobra','PtSoller',...
    'PtValldemossa','Banyalbufar','Dragonera','NWChannel'}

% set station locations:
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


%% extract data:
if iExtract
    % list filenames:
    filesp = dir([romsdir 'BRIFS*parent*his*'])
    filesc = dir([romsdir 'BRIFS*child*his*.nc'])
    filesc0 = dir([romsdir 'roms_BRIFS*child*_t0_his*'])
    
    readMetadata=true;
    
    for k = 1:numel(filesc)
        
        
%         fnamep = [romsdir filesp(k).name]
        fnamec = [romsdir filesc(k).name]
        fnamep = strrep(fnamec,'child','parent')
        
        
        
        % extract parameters from filename (warning: this changes with different filenames!!!):
        tmp = regexp(fnamep, '_c*', 'split');
        cg=tmp{5}
        numexp(k).cg = str2num(cg);
        tmp = regexp(fnamep, '_a*', 'split');
        amplitude=tmp{6}
        numexp(k).amplitude = str2num(amplitude);
        tmp = regexp(fnamep, '_t*', 'split');
        theta=tmp{7}
        numexp(k).theta = str2num(theta);
        

        % read grid, times and bathymetries:
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
    
        % read elevations:
        disp(['Reading ROMS elevations from ' fnamep])
        zeta_parent = ncread(fnamep,'zeta');
        disp(['Reading ROMS elevations from ' fnamec])
        zeta_child = ncread(fnamec,'zeta');
        
        % extract values at station locations:
        numexp(k).stations.zeta = extractROMSnumExp(bathy_parent,bathy_child,zeta_parent,zeta_child,...
            lon2d_parent,lat2d_parent,lon2d_child,lat2d_child,...
            stations.names,stations.lons,stations.lats);
       
    end
    
    % save matfile:
    clearvars zeta_child zeta_parent
    save([outputdir 'numericalExperimentsData.mat'])
    
else
    if iAnalyze || iPlotMap
        % load matfile:
        load([outputdir 'numericalExperimentsData.mat'])
        numexp
    end
end

%% ANALYSIS

if iAnalyze
    shortnames = {'SRp','CSL','CLF','PtCL','PtCr',...
        'CDp','SWC','NEC','OCtd','Ctd',...
        'C1','C2','C3','C4','C5',...
        'Pllnc','CalStVc','PunBc','SaCal','PtSoll',...
        'PtVld','Bbf','Drgnr','NWC'}
    
    % SSH at stations depending on cg, theta. Initialize:
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
            % there seems to be something wrong with the 15 point, so i
            % skip it since its not crucial:
            if s==15
                stationMaxElevs(n,s)=0;
                continue
            end
            s
            size(speeds)
            % fill speeds and angles:
            speeds(n,s) = numexp(n).cg;
            angles(n,s) = numexp(n).theta;
            
            if strcmp(stations.names{s},'Ciutadella')
                stationMaxElevs(n,s) = max(numexp(n).stations.zeta(s).child);
            else
                disp('max:')
                max(max(numexp(n).stations.zeta(s).parent))
                
                % fill array of maximum elevations at this station at this
                % speed and this angle:
                stationMaxElevs(n,s) = max(numexp(n).stations.zeta(s).parent);
            end
        end
        
    end
    

    nx = length(unique(angles(:,1)));
    ny = length(unique(speeds(:,1)));
    dimvc=[nx,ny]
    speeds2 = reshape(speeds(:,1),dimvc);
    angles2 = reshape(angles(:,1),dimvc);
    speeds1 = speeds2(1,:)
    angles1 = angles2(:,1)'
    
    % plot color SSH matrix for every station for all phase speeds and
    % angles:
    for s = 1: length(stations.names)
        stationMaxElevs2 = reshape(stationMaxElevs(:,s),dimvc);
        if ~strcmp(stations.names{s},'Ciutadella')
            clim = [0 .7];
        else
            clim = [0 1.6];
        end
        stationMaxElevs2(stationMaxElevs2>clim(2))=clim(2);
        figure(2);clf
        bar3c_ml(stationMaxElevs2,angles1,speeds1,[],othercolor('BuOr_12',50),clim);
        %             pcolor(angles2,speeds2,stationMaxElevs2)
        caxis(clim)
        view([0 90])
        colorbar
        
        
        set(gca,'XTick',angles1)
        set(gca,'YTick',speeds1)
        title({'Maximum SSH(\theta,c_f) in [m] ';['during numerical experiments at ' stations.names{s}]})
        xlabel('Pressure wave propagation angle [\circ] (0 = N, 90 = E) ')
        ylabel('Pressure wave phase velocity c_f [m/s]')
        
        grid on
        box on
        set(gca, 'Position', get(gca, 'OuterPosition') - ...
            get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
        
        
        pdfname =[outputdir 'numExp_maxSSH_' stations.names{s} '.pdf']
        print(pdfname,'-dpdf','-r100')
        
        epsname =[outputdir 'numExp_maxSSH_' strrep(stations.names{s},' ','') '.eps']
        print(epsname,'-depsc','-r100')
        
        
    end
    
    % plot SSH rise towards Ciutadella 
    for a =1:size(angles2,1)
        figure(3);clf;hold on
        
        % legend labels:
        cc={};
        speedStep=1;
        for kk = 1:speedStep:size(speeds2,2)
            cc{kk}=['c_f = ' num2str(speeds2(1,kk)) ' m/s'];
        end
        
        
        locstring = 'south';
        locations_south = [2,3,4,5,6,11,12,13,14,9,10];
        locations = locations_south;
        xlimits = [39.2 40.11];
        ylimits = [0 1.6];
        
        
        
        for sp = 1:speedStep:size(speeds2,2)
            %             subplot(size(speeds2,2),1,sp)
            angle0 = angles2(a,1);
            speed0 = speeds2(1,sp);
            [r,c,v] = find(speeds==speed0 & angles==angle0);
            sshCut = stationMaxElevs(r,:);
            sshCut = sshCut(1,:);
            
            places = stations.names(locations);
            cvec= othercolor('StepSeq_25',size(speeds2,2));
            linecolor = cvec(sp,:);
            plot(stations.lats(locations),sshCut(locations),'-d','Color',linecolor,'MarkerFaceColor',linecolor,'linewidth',3)
            
            if sp==size(speeds2,2)
                text_yloc_top = 0.4 * ones(size(locations));
                text_yloc_bottom = 0.35 * ones(size(locations));
                text_yloc_max = max(sshCut(locations));
                %                 text(stations.lats(locations(1:2:end-1)),text_yloc_top(1:2:end-1),stations.names(locations(1:2:end-1)),'color','r');
                %                 text(stations.lats(locations(2:2:end-1)),text_yloc_bottom(2:2:end-1),stations.names(locations(2:2:end-1)),'color','r');
                scatter(stations.lats(locations(1:end-1)),text_yloc_top(1:end-1)-0.02,'+','MarkerEdgeColor',[0 .5 .5],'linewidth',1);
                scatter(stations.lats(locations(end)),text_yloc_max-0.02,'+','MarkerEdgeColor',[0 .5 .5],'linewidth',1);
                bottom_idx=1:2:length(locations)-1;
                top_idx=2:2:length(locations)-1;
                txColor = 'k';
                text(stations.lats(locations(bottom_idx)),text_yloc_bottom(bottom_idx),stations.names(locations(bottom_idx)),'color',txColor);
                text(stations.lats(locations(top_idx)),text_yloc_top(top_idx),stations.names(locations(top_idx)),'color',txColor);
                text(stations.lats(locations(end)),text_yloc_max,stations.names(locations(end)),'color',txColor);
                
            end
            
            fntsize=15;
            set(gca,'fontsize',fntsize)
            lgnd = legend(cc{:},'location','northwest');
            lgo = findobj(lgnd,'type','text');
            set(lgo,'fontsize',12)
            %                 set(gca,'XTick',stations.lats(locations))
            %                 set(gca,'XtickLabel',[shortnames(locations)] )
            xlim(xlimits)
            ylim(ylimits)
            title(['Max SSH [m] along ' locstring ' Mallorcan coast at \theta = ' num2str(angle0) ])
            %             title(['cg =' num2str(speed0) ' and \theta = ' num2str(angle0)])
            
            if sp<size(speeds2,2)
                %                  set(gca, 'XTickLabels', []);
                ylabel('Max SSH [m]')
                
            else
                xlabel(['Latitude of SSH location along ' locstring ' Mallorcan coast'])
                ylabel('Max SSH [m]')
            end
            
            pbaspect([1.5 1 1])
            grid on
            box on
            
        end
        set(gca,'LooseInset',get(gca,'TightInset'))
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperOrientation', 'landscape');
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperType', 'A4');
        set(gcf, 'PaperPosition', [0 0 29.7 21]);
        
        pngname =[outputdir 'maxSSH_Alltheta' num2str(angle0) '_' locstring '.png']
        print(pngname,'-dpng','-r100')
        pdfname =[outputdir 'maxSSH_Alltheta' num2str(angle0) '_' locstring '.pdf']
        print(pdfname,'-dpdf','-r100')
        
    end
end

if iPlotMap

figure(10);clf;hold on
bathy_parent(mask2d_parent==0)=0;
contourf(lon2d_parent,lat2d_parent,bathy_parent,20); shading flat
contour(lon2d_parent,lat2d_parent,bathy_parent,[0,0],'r')
contour(lon2d_parent,lat2d_parent,bathy_parent,[75,75],'b')

scatter(stations.lons,stations.lats,'ob')

colormap(flipud(bone(100)))
epsname =[outputdir 'map_Mallorca_75m_isobath_stations.eps']
print(epsname,'-depsc','-r100')
    
    
end
