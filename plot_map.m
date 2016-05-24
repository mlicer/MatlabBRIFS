
% set domain:
latmin = 35; 
latmax = 42;
lonmin = 0;
lonmax = 6;

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
lon(12)=2.7;lat(12)=41.1;  % Close to Cabo Begur
lon(13)=3.0;lat(13)=39.4;  % Sarapita
lon(14)=1.3;lat(14)=39.0;  % Sant Antoni
lon(15)=3.1;lat(15)=39.9;  % Pollensa
lon(16)=4.3;lat(16)=39.9;  % Lamola
lon(17)=3.2;lat(17)=39.7;  % Colonia St Pere
lon(18)=2.4;lat(18)=39.5;  % Andratx

Name(:, 1) ='African coast 1       ';
Name(:, 2) ='African coast 2       ';
Name(:, 3) ='Middle Ibiza-Africa   ';
Name(:, 4) ='Middle Mallorca-Africa';
Name(:, 5) ='Middle Menorca-Africa ';
Name(:, 6) ='Ibiza                 ';
Name(:, 7) ='Middle Ibiza-Mallorca ';
Name(:, 8) ='Palma de Mallorca     ';
Name(:, 9) ='Middle of Channel     ';
Name(:, 10)='Ciutadella            ';
Name(:, 11)='Mao                   ';
Name(:, 12)='Near Cabo Begur       ';
Name(:, 13)='Sarapita              ';
Name(:, 14)='Sant Antoni           ';
Name(:, 15)='Pollensa              ';
Name(:, 16)='Lamola                ';
Name(:, 17)='Colonia Sant Pere     ';
Name(:, 18)='Andratx               ';

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
Name_simple(:, 13)='P13';
Name_simple(:, 14)='P14';
Name_simple(:, 15)='P15';
Name_simple(:, 16)='P16';
Name_simple(:, 17)='P17';
Name_simple(:, 18)='P18';

figure(1);clf; hold on
% add coastline:
width=0.75;
S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);

scatter(lon,lat,45,'dk','filled')

h = text(lon,lat,Name','color','b')
set(h, 'rotation', 60)
xlim([lonmin lonmax])
ylim([latmin latmax])

grid on 
box on

pbaspect([1 1 1])
set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

pngname='/home/mlicer/BRIFSverif/map_mallorca_stations.png';
print(pngname,'-dpng','-r300')

figure(2);clf; hold on
% add coastline:
width=0.75;
S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);

scatter(lon,lat,45,'dk','filled')

h = text(lon,lat,Name_simple','color','b')
set(h, 'rotation', 60)
xlim([lonmin lonmax])
ylim([latmin latmax])

grid on 
box on

pbaspect([1 1 1])
set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

pngname='/home/mlicer/BRIFSverif/map_mallorca_stations_simple.png';
print(pngname,'-dpng','-r300')