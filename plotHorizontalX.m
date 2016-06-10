function plotHorizontalX(figNumber, wrfdata,timestep, clim,cmap,fieldName, fieldUnits, outputdir, savePlots)
% Plots horizontal cross sections through WRF arrays.
%
% INPUT:
% figNumber - well, figure number
% wrfdata - Matlab data structure obtained from readWRF function
% timestep - integer timestep of the plot
% clim - color limits [min max] for plot
% cmap - colormap name ('jet' or othercolor('Spectral10') or ...)
% fieldName - 'U10', 'V10', 'PSFC' etc.
% fieldUnits - '[m/s]', '[mbar]', etc.
% outputdir - directory where the plots will be saved
% savePlots - logical flag whether to save the plots as .png or not

% set figure params:
width = 0.75;
fntsize=18;

% set domain limits:
latmin = min(min(min(wrfdata.lats)));
latmax = max(max(max(wrfdata.lats)));
lonmin = min(min(min(wrfdata.lons)));
lonmax = max(max(max(wrfdata.lons)));

% datestrings used for titles and filenames:
datestring1 = datestr(wrfdata.times(timestep),'yyyy mm dd HH:MM');
datestring2 = datestr(wrfdata.times(timestep),'yyyymmddHHMM');
data = wrfdata.(fieldName);

% plot figure:
figure(figNumber);clf; hold on
pcolor(wrfdata.lons(:,:,timestep)',wrfdata.lats(:,:,timestep)',data(:,:,timestep)'); shading flat
caxis(clim)
colormap(cmap)
colorbar

% add coastline:
S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
title({['BRIFS WRF ' fieldName ' ' fieldUnits ' at date: ']; datestring1},'fontsize',fntsize)

% add contours:
[C,h] = contour(wrfdata.lons(:,:,timestep)',wrfdata.lats(:,:,timestep)',data(:,:,timestep)',20,'linecolor',[.5 .5 .5])
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*1)

% set plot limits:
xlim([lonmin,lonmax])
ylim([latmin,latmax])

set(gca,'fontsize',fntsize)
box on

if savePlots
    % save image:
    pngname = [outputdir fieldName '_' datestring2 wrfdata.nestingLevelString '.png'];
    saveas(gcf,pngname,'png')
end

% close all
end