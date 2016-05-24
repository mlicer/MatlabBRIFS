function plot_sealevel_ROMS_BRIFS_OBS(strdate,strbf,dirname_out,dirname_plots)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function plot_sealevel_ROMS_BRIFS_OBS(strdate,strbf,dirname_out,dirname_plots)
%
%  Plot sea level time series from ROMS outputs at a given date. Compare
%  SSH from ROMS to available observations of sea surface elevation.
%  
%
%  Input arguments:
%     strdate: YYYYMMDD
%     strbf: 'bestfit' if best fit ROMS simulation needs to be considered
%     dirname_out: directory with ROMS output files for that date
%     dirname_plots: directory for plots
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
%         Matjaz Licer - NIB MBS
% Date of creation: Jun-2015
% Last modification: 3-May-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% strdate='20150611';
% strbf = 'worstfit';
% dirname_out= '/home/rissaga/new_setup/Archive/Outputs/ROMS/';
% dirname_plots = '/home/mlicer/BRIFSverif/plots/ROMS/';
disp([' Script plot_sealevel_ROMS_BRIFS executed on ' datestr(now)]);

mydate=datenum(strdate,'yyyymmdd');
strdate_tomorrow=datestr(mydate+1,'yyyymmdd');


if ~exist([dirname_plots 'ROMS_OBS_stations_' strdate '.mat'])
    
    % read observational data:
    seaLevels = readSeaLevelObservations(strdate);
    tideGauges = readTideGaugeObservations(strdate);
    currentProfilers = readCurrentProfilerObservations(strdate);
    
    % remove low frequencies (apply high-pass filter) on all sea level data:
    try
        seaLevelsHF = removeLowFrequencies(seaLevels,'SLEV');
    catch
    end
    
    try
        tideGaugesHF = removeLowFrequencies(tideGauges,'WTR_PRE');
    catch
    end
    
    try
        tideGaugesHF = removeLowFrequencies(tideGauges,'SLEV');
    catch
    end
    
    try
        currentProfilersHF = removeLowFrequencies(currentProfilers,'WTR_PRE'); % 1 dbar = 1 meter
    catch
    end
    
    if ~exist(dirname_out)
        disp(['  ERROR: Directory ' dirname_out ' not found']);
        return
    end
    if ~exist(dirname_plots)
        disp(['  ERROR: Directory ' dirname_plots ' not found']);
        return
    end
    
    if strcmp(strbf,'bestfit')
        filename_parent=[dirname_out '/roms_BRIFS_parent_bf_' strdate '_his.nc'];
        filename_child=[dirname_out '/roms_BRIFS_child_bf_' strdate '_his.nc'];
    else
        filename_parent=[dirname_out '/roms_BRIFS_parent_' strdate '_his.nc'];
        filename_child=[dirname_out '/roms_BRIFS_child_' strdate '_his.nc'];
    end
    
    if exist(filename_parent)
        disp(['   Reading parent model file ' filename_parent ' ...']);
        lon_parent=nc_varget(filename_parent,'lon_rho');
        lat_parent=nc_varget(filename_parent,'lat_rho');
        time_parent=nc_varget(filename_parent,'ocean_time')/(3600*24)+datenum(1968,5,23);
        nt_parent=length(time_parent);
        zeta_parent=nc_varget(filename_parent,'zeta');
    else
        disp(['   ERROR: File ' filename_parent ' not found']);
        return
    end
    
    if exist(filename_child)
        disp(['   Reading child model file ' filename_child  ' ...']);
        lon_child=nc_varget(filename_child,'lon_rho');
        lat_child=nc_varget(filename_child,'lat_rho');
        time_child=nc_varget(filename_child,'ocean_time')/(3600*24)+datenum(1968,5,23);
        nt_child=length(time_child);
        zeta_child=nc_varget(filename_child,'zeta');
    else
        disp(['   WARNING: Filename ' filename_child ' not found']);
    end
    
    % Selected locations for parent model
    lon1(1)=2.7;lat1(1)=39.5;  % Palma Bay
    lon1(2)=3.6;lat1(2)=39.9;  % Menorca channel
    lon1(3)=3.8;lat1(3)=39.98; % Off Ciutadella
    lon1(4)=3.088467;lat1(4)=39.904646; % Pollensa
    lon1(5)=2.353052;lat1(5)=39.537565; % Andratx
    lon1(6)=3.831217;lat1(6)=39.99978; % Ciutadella
    lon1(7)=2.9533;lat1(7)=39.3603; % Sa Rapita
    % lon1(8)=3.33509;lat1(8)=39.53918; % Actual Porto Cristo = ROMS dry point
    lon1(8)= 3.340175;lat1(8)=39.536640; % Wet Porto Cristo
    % Name(:, 1)='Palma Bay        ';
    % Name(:, 2)='Menorca Channel  ';
    % Name(:, 3)='Off Ciutadella   ';
    % Name(:, 4)='Pollensa         ';
    % Name(:, 5)='Andratx          ';
    % Name(:, 6)='Ciutadella Harbor';
    % Name(:, 7)='Sa Rapita        ';
    % Name(:, 8)='Porto Cristo     ';
    
    %% points for ROMS elevation verification: 
    % 20150611:
    lat1(9) = 37.140498; lon1(9) =  1.596955;
    lat1(10) = 38.097707;lon1(10) =  3.091096;
    lat1(11) = 39.323563;lon1(11) =  3.640412;
    lat1(12) = 39.848501;lon1(12) =  3.673371;
    
    %%
    lon2(1)=3.824;lat2(1)=39.995;    % Finer grid Off Ciutadella
    lon2(2)=3.825340;lat2(2)=39.997172; % outer harbour
    lon2(3)=3.831283;lat2(3)=39.999884; % mid harbour: AWAC location
    lon2(4)=3.8353;lat2(4)=40.0015;  % Ciutadella inner harbor

    % Find nearest grid points for selected locations
    ii1=NaN*zeros(length(lon1),1);
    jj1=NaN*zeros(length(lon1),1);
    for kl=1:length(lon1)
        [minval ii1(kl)]=min(abs(lon_parent(1,:)-lon1(kl)));
        [minval jj1(kl)]=min(abs(lat_parent(:,ii1(kl))-lat1(kl)));
    end
    
    if exist(filename_child)
        ii2=NaN*zeros(length(lon2),1);
        jj2=NaN*zeros(length(lon2),1);
        for kl=1:length(lon2)
            [minval ii2(kl)]=min(abs(lon_child(1,:)-lon2(kl)));
            [minval jj2(kl)]=min(abs(lat_child(:,ii1(kl))-lat2(kl)));
        end
    end
    
    % Interpolate parent model on selected locations
    disp('   Interpolate parent model fields to selected locations ...')
    P1=NaN*zeros(nt_parent,length(lon1));
    P1_bf=NaN*zeros(nt_parent,length(lon1));
    for kl=1:length(lon1)
        P1(:,kl)=zeta_parent(:,jj1(kl),ii1(kl));
    end
    
    % Interpolate child model at Ciutadella port entrance and inside the harbor
    disp('   Interpolate child model fields to selected locations ...')
    if exist(filename_child)
        P2=NaN*zeros(nt_child,length(lon2));
        P2_bf=NaN*zeros(nt_child,length(lon2));
        for kl=1:length(lon2)
            P2(:,kl)=zeta_child(:,jj2(kl),ii2(kl));
        end
    end
    
%     clear zeta_parent zeta_child
    save([dirname_plots 'ROMS_OBS_stations_' strdate '.mat'])
    
else
    
    load([dirname_plots 'ROMS_OBS_stations_' strdate '.mat'])
    
end

im=get_SOCIB_logo;

% figure
%
%
% % Add SOCIB logo
%  axes('position',[0.13,0.85,0.07,0.07])
%  imshow(im)
%  set(gcf,'renderer','zbuffer');

%% plot sea levels
if ~exist('seaLevelsHF')
    seaLevelsHF=[];
end
if ~exist('currentProfilersHF')
    currentProfilersHF=[];
end
plotSeaLevelsObsROMS(lon1,lat1,lon2,lat2,seaLevelsHF,currentProfilersHF,filename_parent,time_parent,filename_child,time_child,P1,P2,dirname_plots,strdate,strbf)
return
roms_matdir=dirname_plots;
wrf_matdir = '/home/mlicer/BRIFSverif/plots/WRF/';

if ~isempty(seaLevelsHF) & ~isempty(currentProfilersHF)
WRF_ROMS_OBS_data_analysis(strdate,roms_matdir,wrf_matdir)
end





