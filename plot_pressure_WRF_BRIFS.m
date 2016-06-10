function plot_pressure_WRF_BRIFS(strdate,dirname_out,dirname_plots)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function plot_pressure_WRF_BRIFS(strdate,dirname_out,dirname_plots)
%
%  Plot atmospheric pressure time series from WRF outputs at a given date.
%
%  Input arguments:
%     strdate: YYYYMMDD
%     dirname_out: directory with WRF output files for that date
%     dirname_plots: directory for plots
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Date of creation: May-2015
% Last modification: 12-Jun-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([' Script plot_pressure_WRF_BRIFS executed on ' datestr(now)]);

mydate=datenum(strdate,'yyyymmdd');

if ~exist(dirname_out)
    disp(['  ERROR: Directory ' dirname_out ' not found']);
    return
end
if ~exist(dirname_plots)
    disp(['  ERROR: Directory ' dirname_plots ' not found']);
    return
end

filelist=dir([dirname_out '/wrfout_d02_*']);
Icount=0;
firstfile=1;

if length(filelist)==0
    disp(['  ERROR: No WRF output files found for ' datestr(mydate)]);
    return
end

for kf=1:length(filelist)
    
    fname=[dirname_out '/' filelist(kf).name];
    disp([' Reading file ' fname '...']);
    ttime=datenum(nc_varget(fname,'Times'));
    if (max(ttime)<mydate)
        disp(['   Skip file ' fname ' :data in the past']);
        continue
    end
    nt=length(ttime);
    time(Icount+1:Icount+nt)=ttime;
    if (firstfile==1)
        lon_wrf=squeeze(nc_varget(fname,'XLONG',[0 0 0],[1 -1 -1]));
        lat_wrf=squeeze(nc_varget(fname,'XLAT',[0 0 0],[1 -1 -1]));
        [ny nx]=size(lon_wrf);
        firstfile=0;
    end
    PSFC(Icount+1:Icount+nt,:,:)=nc_varget(fname,'PSFC');
    HGT(Icount+1:Icount+nt,:,:)=nc_varget(fname,'HGT');
    T2(Icount+1:Icount+nt,:,:)=nc_varget(fname,'T2');
    Q2(Icount+1:Icount+nt,:,:)=nc_varget(fname,'Q2');
    XLAND(Icount+1:Icount+nt,:,:)=nc_varget(fname,'XLAND');
    
    Icount=Icount+nt;
end

nt=length(time);

% Compute MSLP
PSFC=PSFC/100;   % Convert to hPa
MSLP=PSFC.*exp(9.81.*HGT./(287.*T2.*(1+0.61.*Q2)));
% Mask MSLP
MSLP_masked=MSLP;
MSLP_masked(XLAND==1)=NaN;
PSFC_masked=PSFC;
PSFC_masked(XLAND==1)=NaN;

%load color_gravonde
load med_coastline_nolakes.dat
define_colors
load('rt_colormaps.mat')
im=get_SOCIB_logo;



% Define Stations
lon(1)=0.83;lat(1)=36.5;   % African coast 1
lon(2)=3.0;lat(2)=37.15;   % African coast 2
lon(3)=1.5;lat(3)=37.8;    % Middle Ibiza Africa
lon(4)=3.3;lat(4)=38.1;    % Middle Mallorca Africa
lon(5)=4.48;lat(5)=38.7; % Middle Menorca Africa
lon(6)=1.45;lat(6)=38.85;  % Ibiza
lon(7)=2.1;lat(7)=39.2;    % Ibiza-Mallorca channel
lon(8)=2.7;lat(8)=39.5;    % Palma
lon(9)=3.6;lat(9)=39.9;    % Middle of the channel
lon(10)=3.8;lat(10)=39.98; % Ciutadella
lon(11)=4.4;lat(11)=39.84; % Maó
lon(12)=2.7;lat(12)=41.1;    % Close to Cabo Begur

Name(:, 1)='African coast 1       ';
Name(:, 2)='African coast 2       ';
Name(:, 3)='Middle Ibiza-Africa   ';
Name(:, 4)='Middle Mallorca-Africa';
Name(:, 5)='Middle Menorca-Africa ';
Name(:, 6)='Ibiza                 ';
Name(:, 7)='Middle Ibiza-Mallorca ';
Name(:, 8)='Palma de Mallorca     ';
Name(:, 9)='Middle of Channel     ';
Name(:, 10)='Ciutadella            ';
Name(:, 11)='Mao                   ';
Name(:, 12)='Near Cabo Begur       ';

Name_simple(:, 1)='P01';
Name_simple(:, 2)='P02';
Name_simple(:, 3)='P03';
Name_simple(:, 4)='P04';
Name_simple(:, 5)='P05';
Name_simple(:, 6)='P06';
Name_simple(:, 7)='P07';
Name_simple(:, 8)='P08';
Name_simple(:, 9)='P09';
Name_simple(:, 10)='P10';
Name_simple(:, 11)='P11';
Name_simple(:, 12)='P12';

% Separate today and tomorrow figures
tt_today=find(time-mydate>=0 & time-mydate<=1);
tt_tomorrow=find(time-mydate>=1 & time-mydate<=2);
nt_today=length(tt_today);
nt_tomorrow=length(tt_tomorrow);

CAXIS_0_24=[nanmin(nanmin(MSLP_masked(tt_today,:))) nanmax(nanmax(MSLP_masked(tt_today,:)))];
CAXIS_24_48=[nanmin(nanmin(MSLP_masked(tt_tomorrow,:))) nanmax(nanmax(MSLP_masked(tt_tomorrow,:)))];
CAXIS_MEAN=[nanmin(nanmin(nanmean(MSLP_masked(tt_today,:)))) nanmax(nanmax(nanmean(MSLP_masked(tt_today,:))))];

display('Create atmospheric pressure maps 0-24h ...')
fname_avi_0_24=[dirname_plots, '/forecast_', strdate, '_0_24.avi'];
aviobj = avifile(fname_avi_0_24, 'quality', 30);
fig=figure;
for kt=1:nt_today
    disp(['   kt=' num2str(kt) ' over ' num2str(nt_today)]);
    pcolor(lon_wrf,lat_wrf,double(squeeze(MSLP(tt_today(kt),:,:))))
    hold on
    plot(med_coastline_nolakes(:,1),med_coastline_nolakes(:,2),'k','LineWidth',1)
    dasp(mean(lat_wrf(:)));
    cbar=colorbar('fontsize',12,'position',[0.25 0.5 0.03 0.3]);
    xlabel(cbar, '     (hPa)', 'fontsize',12)
    shading flat
    set(gca,  'fontsize', 12)
    %colormap(colorred)
    colormap(rt_colormaps.barbara)
    [cs,bh]=contour(lon_wrf,lat_wrf,double(squeeze(MSLP_masked(tt_today(kt),:,:))),[980:1:1030]','w','linewidth',1); 
    ht=clabel(cs,bh,'labelspacing',200,'fontsize',8,'color','w');
    caxis(CAXIS_0_24);
    text(-2,41.6,datestr(time(tt_today(kt)),'dd-mmm-yyyy HH:MM UTC'),'fontsize',12, 'color', 'k','backgroundcolor', 'w');
    axis off
    M(kt)=getframe;
    clf
end
if (nt_today>0)
    display(['Save movie atmospheric pressure maps 0-24h in file ' fname_avi_0_24])
    aviobj = addframe(aviobj,M);
    aviobj = close(aviobj);
    clear M
end
close(fig)

display('Create atmospheric pressure maps 24-48h ...')
fname_avi_24_48=[dirname_plots, '/forecast_', strdate, '_24_48.avi'];
aviobj = avifile(fname_avi_24_48, 'quality', 30);
fig=figure;
for kt=1:nt_tomorrow
    disp(['   kt=' num2str(kt) ' over ' num2str(nt_tomorrow)]);
    pcolor(lon_wrf,lat_wrf,double(squeeze(MSLP(tt_tomorrow(kt),:,:))))
    hold on
    plot(med_coastline_nolakes(:,1),med_coastline_nolakes(:,2),'k','LineWidth',1)
    dasp(mean(lat_wrf(:)));
    cbar=colorbar('fontsize',12,'position',[0.25 0.5 0.03 0.3]);
    xlabel(cbar, '     (hPa)', 'fontsize',12)
    shading flat
    set(gca,  'fontsize', 12)
    %colormap(colorred)
    colormap(rt_colormaps.barbara)
    [cs,bh]=contour(lon_wrf,lat_wrf,double(squeeze(MSLP_masked(tt_tomorrow(kt),:,:))),[980:1:1030]','w','linewidth',1); 
    ht=clabel(cs,bh,'labelspacing',200,'fontsize',8,'color','w');
    caxis(CAXIS_24_48);
    text(-2,41.5,datestr(time(tt_tomorrow(kt)),'dd-mmm-yyyy HH:MM UTC'), 'fontsize', 12, 'color', 'k','backgroundcolor', 'w')
    axis off
    M(kt)=getframe;
    clf
end
    display(['Save movie atmospheric pressure maps 24-48h in file ' fname_avi_24_48])
if (nt_tomorrow>0)
    aviobj = addframe(aviobj,M);
    aviobj = close(aviobj);
    clear M
end
close(fig)


% Plot mean pressure map with point locations
figure
pcolor(lon_wrf,lat_wrf,double(squeeze(nanmean(MSLP(tt_today,:,:)))))
hold on
dasp(mean(lat_wrf(:)));
plot(med_coastline_nolakes(:,1),med_coastline_nolakes(:,2),'k','LineWidth',1)
cbar=colorbar;
%ylabel(cbar, 'hPa', 'fontsize', 20)
shading flat
set(gca,  'fontsize', 15)
%colormap(colorred)
colormap(rt_colormaps.barbara)
[cs,bh]=contour(lon_wrf,lat_wrf,double(squeeze(nanmean(MSLP_masked(tt_today,:,:)))),[980:1:1030]','w','linewidth',2); 
ht=clabel(cs,bh,'labelspacing',200,'fontsize',10,'color','w');
plot(lon, lat, 'd', 'markersize', 3,'Color',grey, 'linewidth', 1)
for k=[2:8 11 12]
    text(lon(k)+0.1, lat(k), Name_simple(:, k)','Color',grey,'fontsize', 12)
end
for k=[1 9]
    text(lon(k)-0.65, lat(k)+0.0, Name_simple(:, k)','Color',grey, 'fontsize', 12)
end
for k=[10]
    text(lon(10)-0.3, lat(10)+0.2, Name_simple(:, 10)','Color',grey, 'fontsize', 12)
end
caxis(CAXIS_MEAN);
xlabel('Longitude (degE)', 'fontsize', 15)
ylabel('Latitude (degN)', 'fontsize', 15)
title(['Mean sea level pressure (hPa) for ' datestr(mydate,'dd-mmm-yyyy')], 'fontsize', 15);
% Add SOCIB logo
 axes('position',[0.68,0.12,0.08,0.08])
 imshow(im)
 set(gcf,'renderer','zbuffer');     
printpspng([dirname_plots '/Map_locations_' strdate])

% Duplicate figure with new name
printpspng([dirname_plots '/BRIFS_mean_pressure_map_' strdate]);

% Plot pressure time series at specified locations
P_stations=NaN*zeros(nt,length(lon));
for kt=1:nt
    P_stations(kt,:)=interp2(lon_wrf,lat_wrf,squeeze(MSLP(kt,:,:)),lon,lat);
end

tt_48h=unique([tt_today;tt_tomorrow]);

figure('position', [0 0 1000 1000])
for ks=1:6
    subplot(3,2,ks)
    plot(time(tt_48h), P_stations(tt_48h, ks),'Color',steel, 'linewidth', 1)
    set(gca, 'fontsize', 10)
    set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
    set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm-yyyy'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
    %datetick('x','dd-mmm')
    ylim_min=min(P_stations(tt_48h, ks))-(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim_max=max(P_stations(tt_48h, ks))+(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim([ylim_min ylim_max]);
    text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name_simple(:, ks)','Color','r','fontsize', 15);
    grid on
    %xlabel([datestr(max(time(tt_today)),'yyyy')], 'fontsize', 12)
    xlabel(['00:00 UTC                       00:00 UTC                        00:00 UTC' ], 'fontsize', 8)
    if (ks==3)
        ylabel('Sea level pressure (hPa)', 'fontsize', 15)
    end
end
% Add SOCIB logo
 axes('position',[0.46,0.88,0.06,0.06])
 imshow(im)
 set(gcf,'renderer','zbuffer');     
printpspng([dirname_plots '/MSLP_part1_' strdate]);

% Duplicate figure with new name
printpspng([dirname_plots '/BRIFS_pressure_timeseries_P1_P6_' strdate]);

figure('position', [0 0 1000 1000])
for ks=7:12
    subplot(3,2,ks-6)
    plot(time(tt_48h), P_stations(tt_48h, ks),'Color',steel, 'linewidth', 1)
    set(gca, 'fontsize', 10)
     set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
    set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
    %datetick('x','dd-mmm')
     ylim_min=min(P_stations(tt_48h, ks))-(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim_max=max(P_stations(tt_48h, ks))+(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim([ylim_min ylim_max]);
    text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name_simple(:, ks)','Color','r','fontsize', 15);
    grid on
    %xlabel([datestr(max(time(tt_today)),'yyyy')], 'fontsize', 12)
    xlabel(['00:00 UTC                       00:00 UTC                        00:00 UTC' ], 'fontsize', 8)
     if (ks==9)
        ylabel('Sea level pressure (hPa)', 'fontsize', 15)
    end
end
% Add SOCIB logo
 axes('position',[0.46,0.88,0.06,0.06])
 imshow(im)
 set(gcf,'renderer','zbuffer'); 
printpspng([dirname_plots '/MSLP_part2_' strdate]);

% Duplicate figure with new name
printpspng([dirname_plots '/BRIFS_pressure_timeseries_P7_P12_' strdate]);

return
