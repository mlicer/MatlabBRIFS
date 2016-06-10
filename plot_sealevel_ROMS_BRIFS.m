function plot_sealevel_ROMS_BRIFS(strdate,strbf,dirname_out,dirname_plots)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function plot_sealevel_ROMS_BRIFS(strdate,strbf,dirname_out,dirname_plots)
%
%  Plot sea level time series from ROMS outputs at a given date.
%
%  Input arguments:
%     strdate: YYYYMMDD
%     strbf: 'bestfit' if best fit ROMS simulation needs to be considered
%     dirname_out: directory with ROMS output files for that date
%     dirname_plots: directory for plots
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Date of creation: Jun-2015
% Last modification: 12-Jun-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([' Script plot_sealevel_ROMS_BRIFS executed on ' datestr(now)]);

mydate=datenum(strdate,'yyyymmdd');
strdate_tomorrow=datestr(mydate+1,'yyyymmdd');

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
Name(:, 1)='Palma Bay        ';
Name(:, 2)='Menorca Channel  ';
Name(:, 3)='Off Ciutadella   ';
Name(:, 4)='Ciutadella Harbor';

lon2(1)=3.824;lat2(1)=39.995;    % Finer grid Off Ciutadella
lon2(2)=3.8353;lat2(2)=40.0015;  % Ciutadella harbor

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


% Plots

define_colors;
if strcmp(strbf,'bestfit')
    disp('   Plot Sea Level Anomalies timeseries for best fit ...')
else
    disp('   Plot Sea Level Anomalies timeseries ...')
end

im=get_SOCIB_logo;

figure
if exist(filename_child)
    plot(time_child,P2(:, 2).*100,'Color',red,'linewidth', 1)
    hold on
    plot(time_child,P2(:, 1).*100,'Color',orange,'linewidth', 1)
    strlegend=Name(:, 4:-1:1)';
else
    strlegend=Name(:, 2:-1:1)';
end
plot(time_parent,P1(:, 2).*100,'Color',steel, 'linewidth', 1)
hold on
plot(time_parent,P1(:, 1).*100,'Color',olive ,'linewidth', 1)
legend(strlegend,'location', 'northoutside','orientation','horizontal')
set(gca, 'fontsize', 15)
xlabel(['00:00 UTC               12:00 UTC                00:00 UTC                  12:00 UTC              00:00 UTC '],'fontsize', 12)
if exist(filename_child)
    set(gca, 'xtick', [time_child(1):1/8:time_child(end)])
    set(gca,'XTickLabel',{datestr(time_child(1),'dd-mmm-yyyy'),'','','',...
        datestr(time_child(1)+0.5,'dd-mmm'),'','','',...
        datestr(time_child(1)+1,'dd-mmm'),'','','',...
        datestr(time_child(1)+1.5,'dd-mmm'),'','','',...
        datestr(time_child(1)+2,'dd-mmm')});
else
  set(gca, 'xtick', [time_parent(1):1/8:time_parent(end)])
    set(gca,'XTickLabel',{datestr(time_parent(1),'dd-mmm-yyyy'),'','','',...
        datestr(time_parent(1)+0.5,'dd-mmm'),'','','',...
        datestr(time_parent(1)+1,'dd-mmm'),'','','',...
        datestr(time_parent(1)+1.5,'dd-mmm'),'','','',...
        datestr(time_parent(1)+2,'dd-mmm')});  
end
grid on
if strcmp(strbf,'bestfit')
    title('Sea level anomalies "best fit" (cm)', 'fontsize', 20)
else
    title('Sea level anomalies (cm)', 'fontsize', 20)
end
if exist(filename_child)
    [minval minind]=min(P2(:, 2)*100);
    [maxval maxind]=max(P2(:, 2)*100);
    if max([abs(minval) abs(maxval)])>5
        text(time_child(minind)-0.25,minval-0.7*(maxval-minval)/20,['Min=' num2str(round(minval)) 'cm [' datestr(time_child(minind),'dd-mmm-yyyy HH:MM UTC') ']'],'Color','r','fontsize',12);
        text(time_child(maxind)-0.25,maxval+0.7*(maxval-minval)/20,['Max=' num2str(round(maxval)) 'cm [' datestr(time_child(maxind),'dd-mmm-yyyy HH:MM UTC') ']'],'Color','r','fontsize',12);
        ylim([minval-1.6*(maxval-minval)/20 maxval+1.6*(maxval-minval)/20])
    end 
end
if strcmp(strbf,'bestfit')
    title('Sea level anomalies "best fit" (cm)', 'fontsize', 20)
    plotname=[dirname_plots '/zeta_bf_' strdate];
else
    title('Sea level anomalies (cm)', 'fontsize', 20)
    plotname=[dirname_plots '/zeta_' strdate];
end
% Add SOCIB logo
 axes('position',[0.13,0.85,0.07,0.07])
 imshow(im)
 set(gcf,'renderer','zbuffer');     
printpspng(plotname);

% Duplicate figure with new name
if strcmp(strbf,'bestfit')
    plotname=[dirname_plots '/BRIFS_sealevel_timeseries_bf_' strdate];
else
    plotname=[dirname_plots '/BRIFS_sealevel_timeseries_' strdate];
end
printpspng(plotname);

% Detect rissaga and write date in rissaga recording events file
recording_file='/home/rissaga/new_setup/BRIFS_rissaga_events.txt';
recording_threshold=15;   % in centimeters, absolute value of min or max
if exist(filename_child)
    tt_0_24=find(time_child>=mydate & time_child<mydate+1);
    minval_0_24=min(P2(tt_0_24, 2)*100);
    maxval_0_24=max(P2(tt_0_24, 2)*100);
    if max([abs(minval_0_24) abs(maxval_0_24)])>=recording_threshold
        system(['echo ' strdate ' >> ' recording_file]);
    end
    tt_24_48=find(time_child>=mydate+1 & time_child<mydate+2);
    minval_24_48=min(P2(tt_24_48, 2)*100);
    maxval_24_48=max(P2(tt_24_48, 2)*100);
    if max([abs(minval_24_48) abs(maxval_24_48)])>=recording_threshold
        system(['echo ' strdate_tomorrow ' >> ' recording_file]);
    end
% Record magnitude of sea level oscillations 
if strcmp(strbf,'bestfit')
    rissaga_amplitude_file='/home/rissaga/new_setup/BRIFS_bf_rissaga_magnitude.txt';
else
    rissaga_amplitude_file='/home/rissaga/new_setup/BRIFS_rissaga_magnitude.txt';
end
    amplitude_max=max([maxval_0_24 maxval_24_48])-min([minval_0_24 minval_24_48]);
    system(['echo ' num2str(round(amplitude_max)) ' > ' rissaga_amplitude_file]);
end

return



