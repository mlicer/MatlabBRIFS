% this script plots maximum trajectories from numexp__c' num2str(speed) '_a3_t50.mat'
% matfiles, created by the ROMS_analyze_numexp.m (see iTrackMaximum flag
% therein).

% maximum trajectories:
numexpdir = '/home/mlicer/BRIFSverif/numExp/'
fignum=1;
% coastline width in the plot:
mapLineWidth=2;
% speeds at which to plot maximum trajectories:
speeds =  26:4:40;

k=1;

% set colormap for maximum anomaly contours:
lcolors =  othercolor('Spectral5',length(speeds));

figure(fignum);clf;hold on
fignum = fignum+1;

% initialize basic arrays:
allPaths=[];
labels={};
proudman_vs_topographic = []; % this is a stupid naming -
% i thought there was a difference between proudman and topographic regimes
% on and off the shelf, but there isn't. We're stuck with the name
% currently. Feel free to modify it...

% loop over speeds:
for speed = speeds
    fname = [numexpdir 'c' num2str(speed) '_a3_t50/numexp__c' num2str(speed) '_a3_t50.mat'];
    if speed==speeds(1)
        load(fname,'bathy_parent');
        load(fname,'lon_parent');
        load(fname,'lat_parent');
        lonmin = min(min(lon_parent));
        lonmin = 3;
        lonmax = max(max(lon_parent));
        lonmax=4.2;
        latmin = min(min(lat_parent));
        latmin = 39.5;
        latmax = max(max(lat_parent));
        latmax = 40.1;
        
        % filled depth contours:
        contvec = [0,25,50,55,60,65,70,75,100,125,150,200,300,400,500,1000,1500];
        contourf(lon_parent, lat_parent,bathy_parent,contvec,'linecolor',[.8 .8 .8])
        colormap(flipud(gray(length(contvec))))
        set(gca,'layer','bottom')
        cbr = colorbar('location','southoutside','position',[0.34 0.1 0.3 0.02])
    end
    
    load(fname,'maxTrajectory');
    
    % max trajectory in the proudman region:
    maxTrajectory
    mtp = maxTrajectory(maxTrajectory(:,1)>3.5381 & maxTrajectory(:,1)<=3.646,:);
    % in topographic region:
    mtt = maxTrajectory(maxTrajectory(:,1)>=3.665 & maxTrajectory(:,1)<=3.8115,:);
    % all values - total except for the coastal at menorca, which contaminate:
    mttotal = maxTrajectory(maxTrajectory(:,1)>3.5381 & maxTrajectory(:,1)<=3.8115,:);
    
    %     allPaths = [allPaths maxTrajectory(:,1) maxTrajectory(:,2)]
    [meanH, meanSpeed] = computeMeanDepthSpeed(mttotal);
    [hp, sp] = computeMeanDepthSpeed(mtp);
    [ht, st] = computeMeanDepthSpeed(mtt);
    
    proudman_vs_topographic = [proudman_vs_topographic; [speed, hp, sp, ht, st, meanH, meanSpeed]];
    labels=[['c_{PW} = ' num2str(speed) ' m/s: <H>_L = ' sprintf('%4.2f',meanH) ' m.' ],labels]
    %     labels=[['c_{GW} = ' num2str(speed) ' m/s' ],labels]
    
    %     plot(maxTrajectory(:,1),maxTrajectory(:,2),'-o','color',lcolors(k,:),'markerfacecolor',lcolors(k,:),'linewidth',1)
    plot(maxTrajectory(:,1),maxTrajectory(:,2),'-','color',lcolors(k,:),'markerfacecolor',lcolors(k,:),'linewidth',4)
    %     legend
    k=k+1
    %     scatter(maximumLocation(:,1),maximumLocation(:,2),20,maximumLocation(:,3),'filled')
    title({'Trajectories of the maximum SSH anomaly for different pressure wave velocities'})
    xlim([lonmin,lonmax])
    ylim([latmin,latmax])
    q=(latmin-latmax)/(lonmin-lonmax);
    pbaspect([1 q 1])
    grid off
    box on
    
end

% generate legend labels:
h = get(gca,'Children');
size(h)
labels{:}
% h = [h(4:11);h(13)];
legend(h,labels,'location','southeast')

% add bathymetry scale:
text(3.5,39.38,'Bathymetry [m]','fontsize',15)
set(gca,'layer','top')

% add specific contour lines:
[Ccf,hcf] = contour(lon_parent, lat_parent,bathy_parent,[50,60,75],'.','linecolor',[.6 .6 .6])
clabel(Ccf,hcf)

% add coastline:
S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color',[47 79 79]./255.,'LineWidth',mapLineWidth);


set(gca,'fontsize',13)
set(gca,'LooseInset',get(gca,'TightInset'))
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperType', 'A4');
set(gcf, 'PaperPosition', [0 0 29.7 21]);

pngname  =[numexpdir 'allMaxTrajectories.png']
print(pngname,'-dpng','-r300')
pngname  =[numexpdir 'allMaxTrajectories.pdf']
print(pngname,'-dpdf','-r300')
pngname  =[numexpdir 'allMaxTrajectories.eps']
print(pngname,'-depsc','-r300')

fntsize = 18

% linear regression of mean depth along the contour in the proudman region:
ptotal = polyfit(proudman_vs_topographic(:,1),proudman_vs_topographic(:,6),1);
ptotal2 = polyfit(proudman_vs_topographic(:,1),proudman_vs_topographic(:,6),2);
pvtotal = polyval(ptotal,proudman_vs_topographic(:,1));
pvtotal2 = polyval(ptotal,proudman_vs_topographic(:,1));
pproud = polyfit(proudman_vs_topographic(:,1),proudman_vs_topographic(:,2),1);
pvproud = polyval(pproud,proudman_vs_topographic(:,1));
ptopo = polyfit(proudman_vs_topographic(:,1),proudman_vs_topographic(:,4),1);
pvtopo = polyval(ptopo,proudman_vs_topographic(:,1));

figure(fignum);clf;hold on
fignum=fignum+1;
plot(proudman_vs_topographic(:,1),proudman_vs_topographic(:,6),'-ok',...
    proudman_vs_topographic(:,1),pvtotal,'--k',...
    proudman_vs_topographic(:,1),pvtotal2,':k','linewidth',2)%,...
%     proudman_vs_topographic(:,1),proudman_vs_topographic(:,2),'-ob',...
%     proudman_vs_topographic(:,1),pvproud,'--b',...
%     proudman_vs_topographic(:,1),proudman_vs_topographic(:,4),'-or',...
%     proudman_vs_topographic(:,1),pvtopo,'--r')
title({'Mean depth along the maximum anomaly contour';' at different pressure wave phase speeds'},'fontsize',fntsize)
xlabel('pressure wave phase speed c_f [m/s]','fontsize',fntsize)
ylabel('<H>(c_f) [m]','fontsize',fntsize)
set(gca,'fontsize',fntsize)
grid on
box on
pngname  =[numexpdir 'meanDepthLinReg.eps']
print(pngname,'-depsc','-r300')