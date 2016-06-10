function plotSeaLevelsObsROMS(lon1,lat1,lon2,lat2,seaLevelsHF,currentProfilersHF,filename_parent,time_parent,filename_child,time_child,P1,P2,dirname_plots,strdate,strbf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% A simple plotting function that plots a Figure of 3x2 subplots at
% different locations, comparing ROMS SSH and in situ SSH. Both signals are
% high-pass filtered to allow comparisons. For details on filtering see
% removeROMSLowFrequencies.m, removeWRFLowFrequencies.m and
% removeLowFrequencies.m codes
%
% Author: Matjaz Licer - NIB MBS
% Date of creation: Jun-2015
% Last modification: 3-May-2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
figure;clf;hold on
subplot(3,2,1)
stationName='ANDRATX';
try
    plot(seaLevelsHF.andratx.time,seaLevelsHF.andratx.SLEV,'r',time_parent,removeROMSLowFrequencies(P1(:,5)),'b')
    legend('OBS','ROMS','location','southwest','orientation','horizontal')
    romsAxis
catch
    plot(time_parent,removeROMSLowFrequencies(P1(:,5)),'b')
    legend('ROMS','location','southwest')
    romsAxis
end

subplot(3,2,2)
stationName='SA RAPITA';
try
    plot(seaLevelsHF.sarapita.time,seaLevelsHF.sarapita.SLEV,'r',time_parent,removeROMSLowFrequencies(P1(:,7)),'b')
    legend('OBS','ROMS','location','southwest','orientation','horizontal')
    romsAxis
catch
    plot(time_parent,removeROMSLowFrequencies(P1(:,7)),'b')
    legend('ROMS','location','southwest')
    romsAxis
end
subplot(3,2,3)
stationName='PORTOCRISTO';
try
    plot(seaLevelsHF.portocristo.time,seaLevelsHF.portocristo.WTR_PRE,'r',time_parent,removeROMSLowFrequencies(P1(:,8)),'b')
    legend('OBS','ROMS','location','southwest','orientation','horizontal')
    romsAxis
catch
    plot(time_parent,removeROMSLowFrequencies(P1(:,8)),'b')
    legend('ROMS','location','southwest')
    romsAxis
end

subplot(3,2,4)
stationName='POLLENSA';
try
    plot(seaLevelsHF.pollensa.time,seaLevelsHF.pollensa.SLEV,'r',time_parent,removeROMSLowFrequencies(P1(:,4)),'b')
    legend('OBS','ROMS','location','southwest','orientation','horizontal')
    romsAxis
catch
    plot(time_parent,removeROMSLowFrequencies(P1(:,4)),'b')
    legend('ROMS','location','southwest')
    romsAxis
end

subplot(3,2,5)
stationName='OFF CIUTADELLA';

plot(time_child,removeROMSLowFrequencies(P2(:,1)),'b')
legend('ROMS','location','southwest')
romsAxis

subplot(3,2,6)
stationName='CIUTADELLA';

try
    plot(currentProfilersHF.ciutadella.time,currentProfilersHF.ciutadella.WTR_PRE,'r',time_child,removeROMSLowFrequencies(P2(:,2)),'b')
    legend('OBS','ROMS','location','southwest','orientation','horizontal')
    romsAxis
catch
    plot(time_child,removeROMSLowFrequencies(P2(:,2)),'b')
    legend('ROMS','location','southwest')
    romsAxis
end

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 21 29.7]);


% if strcmpi(strbf,'bestfit')
%     epsname = [dirname_plots 'ROMS_OBS_HF_' strdate '_BF.eps']
% else
epsname = [dirname_plots 'ROMS_OBS_HF_' strdate '.eps']
% end
print(epsname,'-depsc','-r300')

%% CIUTADELLA INLET:
close all
figure;clf;hold on

stationName='CIUTADELLA';
try
    plot(currentProfilersHF.ciutadella.time,currentProfilersHF.ciutadella.WTR_PRE,'r',time_child,removeROMSLowFrequencies(P2(:,4)),'b',...
        time_child,P2(:,3),'c',...
        time_child,P2(:,2),'g',...
        time_child,P2(:,1),'k',...
        time_parent,P1(:,3),'m','linewidth',2)
    legend('OBS','ROMS INNER HARBOUR','ROMS MID HARBOUR','ROMS OUTER HARBOUR','CHILD ROMS OUT OF HARBOUR','PARENT ROMS OUT OF HARBOUR','location','southwest')
    romsAxis
catch
    plot(time_child,P2(:,4),'b',...
        time_child,P2(:,3),'c',...
        time_child,P2(:,2),'g',...
        time_child,P2(:,1),'k',...
        time_parent,P1(:,3),'m','linewidth',2)    
    legend('ROMS INNER HARBOUR','ROMS MID HARBOUR','ROMS OUTER HARBOUR','CHILD ROMS OUT OF HARBOUR','PARENT ROMS OUT OF HARBOUR','location','southwest')
    romsAxis
end

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 29.7 21]);


% if strcmpi(strbf,'bestfit')
%     epsname = [dirname_plots 'ROMS_OBS_HF_' strdate '_BF.eps']
% else
epsname = [dirname_plots 'ROMS_OBS_HF_CIUTADELLA_' strdate '.eps']
% end
print(epsname,'-depsc','-r300')

pngname = [dirname_plots 'ROMS_OBS_HF_CIUTADELLA_' strdate '.png']
% end
print(pngname,'-dpng','-r300')

close all
figure;clf;hold on
try
    plot(3.831217,max(abs(currentProfilersHF.ciutadella.WTR_PRE)),'or')
    text(3.831217,max(abs(currentProfilersHF.ciutadella.WTR_PRE)),'AWAC MID HARBOUR')
    namesH = {'ROMS INNER HARBOUR','ROMS MID HARBOUR','ROMS OUTER HARBOUR','CHILD ROMS OUT OF HARBOUR', 'PARENT ROMS OUT OF HARBOUR'}
    plotlons = [lon1(3),lon2(1:4)]
    heights = [max(abs(P1(:,3))),max(abs(P2(:,:)))]
    plot(plotlons,heights,'-ob','linewidth',2)
    for k=1:length(plotlons)
        text(plotlons(k),heights(k),namesH{length(plotlons)-k+1})
    end
    xlim([min(plotlons)-0.01,max(plotlons)+0.01])
catch
    namesH = {'ROMS IN HARBOUR','ROMS MID HARBOUR','ROMS OUTER HARBOUR','CHILD ROMS OUT OF HARBOUR', 'PARENT ROMS OUT OF HARBOUR'}
    plotlons = [lon1(3),lon2(1:4)]
    heights = [max(abs(P1(:,3))),max(abs(P2(:,:)))]
    plot(plotlons,heights,'-ob','linewidth',2)
    for k=1:length(plotlons)
        text(plotlons(k),heights(k),namesH{length(plotlons)-k+1},'fontsize',18)
    end
    xlim([min(plotlons)-0.01,max(plotlons)+0.01])
end
fntsize=18
title({'Maximum absolute elevation anomaly along the Ciutadella Harbor Inlet';['during Rissaga: ' strdate]},'fontsize',fntsize)
xlabel('Longitude E','fontsize',fntsize)
ylabel('Max SSH [m]','fontsize',fntsize)
set(gca, 'fontsize',fntsize)

grid on
box on
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [ 0 0 29.7 21]);


% if strcmpi(strbf,'bestfit')
%     epsname = [dirname_plots 'ROMS_OBS_HF_' strdate '_BF.eps']
% else
epsname = [dirname_plots 'ROMS_OBS_HF_CIUTADELLAmax_' strdate '.eps']
% end
print(epsname,'-depsc','-r300')

pngname = [dirname_plots 'ROMS_OBS_HF_CIUTADELLAmax_' strdate '.png']
% end
print(pngname,'-dpng','-r300')

end