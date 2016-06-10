function pressureWave = generateArtificialPressureFieldTEST(dates,lons,lats,thetaDEG, cg,pressureWaveFrequency,pressureWaveAmplitude,waveDuration);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function pressureWave = generateArtificialPressureField(dates,lons,lats,theta, cg,pressureWaveFrequency,pressureWaveAmplitude)
%
%  Creates a monochromatic plane pressure wave of limited lateral width to
%  be used as artificial ROMS forcing for numerical experiments related to
%  the Rissaga phenomenon.
%
%  Input arguments:
%   -- dates: 1D vector of matlab datenumbers from WRF netCDF
%   -- lons: 1D vector of ROMS grid longitudes [deg]
%   -- lats: 1D vector of ROMS grid latitudes [deg]
%   -- theta: the nautical (compass) angle of propagation [deg] of the wave relatively to the CIUTADELLA
%   harbour. theta = 0: the wave travels north. theta = 90: the wave travels east.
%   -- cg: wave propagation group (and phase) velocity [km/h]. cg = 30 is
%   close to Proudman resonance value over the Mallorca shelf.
%   -- pressureWaveFrequency: the frequency of the pressure wave [s-1]
%   Frequency value 1/3000 suits observations.
%   -- pressureWaveAmplitude: the amplitude of the pressure wave [hPa]
%   Amplitude value 1.0 suits observations.
%
% Output:
%   -- pressureWave: nlons x nlats x ntimes array of the traveling pressure
%   wave.
%
% Author: Matjaz Licer - NIB MBS / @SOCIB
%         matjaz.licer@mbss.org
%
% Date of creation: Apr-2016
% Last modification: 29-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iPlot=true;

if iPlot
    % read coastline shapefile:
    S = shaperead(which('mediterranean.shp'),'UseGeoCoords',true);
    figure(1);clf;hold on
end

if true
    
    ntimes = length(dates);
    
    % Earth Radius [m]:
    RE = 6371000;
    
    % convert group (and in our monochromatic case also phase) velocity of the pressure wave [km/h] to [m/s]:
    %     cg = cg * 1000/3600;
    
    % pressureWaveWavelength [m]:
    pressureWaveWavelength = cg/pressureWaveFrequency;
    
    % grid domain (from ROMS):
    nlats = length(lats);
    nlons = length(lons);
    [lons2,lats2] = meshgrid(lons,lats);
    latmin = min(lats);
    latmax = max(lats);
    lonmin = min(lons);
    lonmax = max(lons);
    meanlat = 0.5*(latmin+latmax)*(pi/180);
    
    
    % point of passage of the pressure wave - CIUTADELLA HARBOUR:
    latCIUTADELLA = 40;
    lonCIUTADELLA = 3.8;
    
    % the NAUTICAL angle of propagation (direction of propagation: 0=N, 90 = E) of the pressure wave:
    theta = thetaDEG*pi/180;
    
    % the wave vector, with wavelength normalized to arc length at Earth radius:
    k = (2*pi/(pressureWaveWavelength/RE)) * [cos(theta),sin(theta)];
    
    % angular frequency [s-1]:
    omega = 2*pi*pressureWaveFrequency;
    
    % lateral width of pressureWave in degrees:
    lateralWidth = 1;
    perpendicularWidth = lateralWidth / cos(pi/2-theta);
    
    % wave duration in seconds:
%     waveDuration = waveDuration*3600;
    
    % axis of the pressure wave propagation:
    slope = tan(pi/2 - theta);
    axisOfPropagation = @(x) slope*(x-lonCIUTADELLA) + latCIUTADELLA;
    
    % front of wave packet:
    frontOfWavePacket = ...
    @(x,t,t0) (1/slope)*(lonmin + (180/pi)*cg*sin(theta)*(t-t0)*86400/(RE*cos(meanlat)) - x ) + latmin+...
    (180/pi)*cg*cos(theta)*(t-t0)*86400/(RE);

    % end of wave packet:
    endOfWavePacket = @(x,t,t0) frontOfWavePacket(x,t-waveDuration/24.,t0);

    % initialize pressure wave:
    pressureWave = zeros([nlats, nlons, ntimes]);
    
    
    % time ramp to gradually generate the wave from zero:
    timeRamp = 8;
    
    
    % Generating pressure wave array:
    for t = 1:ntimes
    pressureWave2d = zeros([nlats, nlons]);
        
        % cropping to domain of the wave path:
        if thetaDEG >= 0 && thetaDEG<=90
            [r,c,v] = find(lats2 < axisOfPropagation(lons2)+0.5*perpendicularWidth & ...
                lats2 > axisOfPropagation(lons2)-0.5*perpendicularWidth & ...
                lats2 < frontOfWavePacket(lons2,dates(t),dates(1)) & ...
                lats2 > endOfWavePacket(lons2,dates(t),dates(1)));
        elseif thetaDEG > 90 && thetaDEG<180
            [r,c,v] = find(lats2 < axisOfPropagation(lons2)+0.5*perpendicularWidth & ...
                lats2 > axisOfPropagation(lons2)-0.5*perpendicularWidth & ...
                lats2 > frontOfWavePacket(lons2,dates(t),dates(1)) & ...
                lats2 < endOfWavePacket(lons2,dates(t),dates(1)));
        else
            error(['PLEASE LIMIT THETA TO 0-180 degrees. CURRENTLY thetaDEG = ' num2str(thetaDEG)])
        end

        % linear increase of wave amplitude in time:
        if t<=timeRamp
            p0 = pressureWaveAmplitude + (pressureWaveAmplitude/(timeRamp-1))*(t-timeRamp);
        else
            p0 = pressureWaveAmplitude;
        end
        
        % generate a right-travelling wave (k r MINUS omega t):
        pressureWaveNow = p0 * cos(dot(repmat(k,length(r),1),[lats(r)',lons(c)']*(pi/180.),2) - omega*dates(t)*86400.);
        pressureWave2d(sub2ind(size(lats2),r,c)) = pressureWaveNow;
        
        % smooth edges to prevent infinite gradients at lateral boundary of the
        % wave:
        pressureWave(:,:,t) = smooth2a(pressureWave2d,1,1);
        %         pressureWave(:,:,t) = pressureWave2d;
    end
    
end
%%

% tracer point - just to check velocities:
%     latPoint = latmin;
if iPlot
    
    for t = 1:ntimes
        
        try
            delete(h1)
            delete(h2)
        catch
        end
        
        h1=surf(lons2,lats2,pressureWave(:,:,t));shading flat
        set(gca,'layer','bottom')        
        
        title(['Artificial pressure wave forcing for ROMS on date: ' datestr(dates(t),'yyyy mmm dd HH:MM')])
        colorbar
        colormap(othercolor('RdYlBu6'))
        caxis([-pressureWaveAmplitude pressureWaveAmplitude])
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        
        % set aspect:
        pbaspect([diff([lonmin lonmax]) diff([latmin latmax]) 1])
        


        
        grid on
        box on
        %         scatter(lonCIUTADELLA,latPoint,20,'filled')
        %         latPoint = latPoint + (cg * timestep/RE)*180/pi
%         set(gca,'layer','top')
        % add coastline:
        width=0.75;
        h2 = geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
        set(gca,'layer','top')        
        
        pause(0.001)
        pngname = ['ciutadella_p-wave_theta_' num2str(theta) '_frame_' datestr(dates(t),'yyyymmmddHHMM') '.png'];
        print(gcf,pngname,'-dpng','-r72')
    end
end

