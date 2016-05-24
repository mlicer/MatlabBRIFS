function plotPgraphs(strdate,mydate,tt_48h,time,Name_simple,Name,P_stations,barometers,steel,im,dirname_plots)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A simple plotting function that plots graphs of P01-P18 locations and
% compares the WRF pressures to observations where and when available.
%
% Author: Matjaz Licer - NIB MBS
% Date of creation: Jun-2015
% Last modification: 3-May-2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ks=1:6
    subplot(3,2,ks)
    plot(time(tt_48h), P_stations(tt_48h, ks),'Color',steel, 'linewidth', 1)
    title(['WRF (blue) vs OBS (red): ' datestr(mydate,'yyyy mm dd')])
    set(gca, 'fontsize', 10)
    set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
    set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm-yyyy'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
    %datetick('x','dd-mmm')
    ylim_min=min(P_stations(tt_48h, ks))-(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim_max=max(P_stations(tt_48h, ks))+(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim([ylim_min ylim_max]);
%     text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name_simple(:, ks)','Color','r','fontsize', 15);
    text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name(:, ks)','Color','r','fontsize', 15);
    grid on
    box on
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
pbaspect([21 29.7 1])

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 21 29.7]);

saveas(gcf,[dirname_plots '/BRIFS_pressure_timeseries_P1_P6_' strdate],'png')

% epsname = [dirname_plots 'BRIFS_pressure_timeseries_P1_P6_' strdate '.eps']
% 
% print(epsname,'-depsc','-r300')


% printpspng([dirname_plots '/MSLP_part1_' strdate]);

% Duplicate figure with new name
% printpspng([dirname_plots '/BRIFS_pressure_timeseries_P1_P6_' strdate]);

figure('position', [0 0 1000 1000])
for ks=7:12
    subplot(3,2,ks-6)
    switch ks
        case 10
            if barometers.ciutadella.dataExists
                hold on
                plot(barometers.ciutadella.time, barometers.ciutadella.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
    end
    plot(time(tt_48h), P_stations(tt_48h, ks),'Color',steel, 'linewidth', 1)
    title(['WRF (blue) vs OBS (red): ' datestr(mydate,'yyyy mm dd')])
    set(gca, 'fontsize', 10)
    set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
    set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
    %datetick('x','dd-mmm')
    ylim_min=min(P_stations(tt_48h, ks))-(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim_max=max(P_stations(tt_48h, ks))+(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim([ylim_min ylim_max]);
%     text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name_simple(:, ks)','Color','r','fontsize', 15);
    text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name(:, ks)','Color','r','fontsize', 15);
    grid on
    box on
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
pbaspect([21 29.7 1])


set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 21 29.7]);

saveas(gcf,[dirname_plots '/BRIFS_pressure_timeseries_P7_P12_' strdate],'png')

% epsname = [dirname_plots 'BRIFS_pressure_timeseries_P7_P12_' strdate '.eps']
% 
% print(epsname,'-depsc','-r300')
% printpspng([dirname_plots '/MSLP_part2_' strdate]);

% Duplicate figure with new name
% printpspng([dirname_plots '/BRIFS_pressure_timeseries_P7_P12_' strdate]);

figure('position', [0 0 1000 1000])
for ks=13:18
    subplot(3,2,ks-12)
    
    % add observations to figures:
    switch ks
        case 13
            if barometers.sarapita.dataExists
                hold on
                plot(barometers.sarapita.time, barometers.sarapita.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
        case 14
            if barometers.santantoni.dataExists
                hold on
                plot(barometers.santantoni.time, barometers.santantoni.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
        case 15
            if barometers.pollensa.dataExists
                hold on
                plot(barometers.pollensa.time, barometers.pollensa.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
        case 16
            if barometers.lamola.dataExists
                hold on
                plot(barometers.lamola.time, barometers.lamola.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
        case 17
            if barometers.coloniasantpere.dataExists
                hold on
                plot(barometers.coloniasantpere.time, barometers.coloniasantpere.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
        case 18
            if barometers.andratx.dataExists
                hold on
                plot(barometers.andratx.time, barometers.andratx.AIR_PRE,'r', 'linewidth', 1)
                xlim([min(time(tt_48h)),max(time(tt_48h))])
            end
    end
    
    % add WRF:
    plot(time(tt_48h), P_stations(tt_48h, ks),'Color',steel, 'linewidth', 1)
    
    title(['WRF (blue) vs OBS (red): ' datestr(mydate,'yyyy mm dd')])
    set(gca, 'fontsize', 10)
    set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
    set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
    %datetick('x','dd-mmm')
    ylim_min=min(P_stations(tt_48h, ks))-(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim_max=max(P_stations(tt_48h, ks))+(max(P_stations(tt_48h,ks))-min(P_stations(tt_48h, ks)))/10;
    ylim([ylim_min ylim_max]);
%     text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name_simple(:, ks)','Color','r','fontsize', 15);
    text(min(xlim)+diff(xlim)/100,max(ylim)-diff(ylim)/10,Name(:, ks)','Color','r','fontsize', 15);
    grid on
    box on
    %xlabel([datestr(max(time(tt_today)),'yyyy')], 'fontsize', 12)
    xlabel(['00:00 UTC                       00:00 UTC                        00:00 UTC' ], 'fontsize', 8)
    if (ks==15)
        ylabel('Sea level pressure (hPa)', 'fontsize', 15)
    end
end

% Add SOCIB logo
axes('position',[0.46,0.88,0.06,0.06])
imshow(im)
set(gcf,'renderer','zbuffer');
pbaspect([21 29.7 1])



set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 21 29.7]);

pngname = [dirname_plots '/BRIFS_pressure_timeseries_P13_P18_' strdate];
saveas(gcf,[dirname_plots '/BRIFS_pressure_timeseries_P13_P18_' strdate],'png')
print('-dpng','-r300',pngname)
% epsname = [dirname_plots 'BRIFS_pressure_timeseries_P13_P18_' strdate '.eps']
% 
% print(epsname,'-depsc','-r300')

% printpspng([dirname_plots '/MSLP_part2_' strdate]);

% Duplicate figure with new name
% printpspng([dirname_plots '/BRIFS_pressure_timeseries_P7_P12_' strdate]);
close all