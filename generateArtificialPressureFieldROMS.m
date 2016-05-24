
% function pressureWave = generateArtificialPressureField(dates,lons,lats,theta, cg,pressureWaveFrequency)
dates = datenum('2015-01-01 00:00:00','yyyy-mm-dd HH:MM')+(0:120:86400)/86400;

% domain:
lons = linspace(2,4.5,254);
lats = linspace(39,40.4,198);
[lons2,lats2] = meshgrid(lons,lats);

% angle of propagation towards CIUTADELLA (0 = wave goes north, 90 = waves goes east)
theta = 120;

% group (and phase - since the wave is monochromatic) velocity of wave
% propagation:
cg = 30;

% pressure wave frequency (1/3000. suits previous experience):
pressureWaveFrequency = 1/1000.;

% pressure wave amplitude in hPa:
pressureWaveAmplitude = 1;
    
% pressure wave duration in hours:
waveDuration = 1;

% generate the wave:
% pressureWave = generateArtificialPressureField(dates,lons,lats,theta,cg,pressureWaveFrequency, pressureWaveAmplitude);
pressureWave = generateArtificialPressureFieldTEST(dates,lons,lats,theta,cg,pressureWaveFrequency, pressureWaveAmplitude,waveDuration);

