function barometers = readPressureObservations(strdate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function barometers = readPressureObservations(strdate)
%
%  Reads atmospheric pressure time series from in situ stations for a given
%  month from the SOCIB THREDDS data server.
%
%  Input arguments:
%     strdate: YYYYMMDD
%
% Author: Matjaz Licer - NIB MBS @SOCIB
%         matjaz.licer@mbss.org
%
% Date of creation: Apr-2016
% Last modification: 12-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse date:
year=strdate(1:4);
month=strdate(5:6);

% determine time window for comparison with observations:
daysOfForecast = 2;
startdate = datenum(strdate,'yyyymmdd');
enddate = startdate+daysOfForecast;

endyear = datestr(enddate,'yyyy');
endmonth = datestr(enddate,'mm');

% Read in situ barometer observations:

if strcmpi(endyear,year) && strcmpi(endmonth,month)
    
    % a. if all the data is in the same month (year):
    santantoni = readBarometerObs('santantoni','pib','baro','004','L1',year,month);
    sarapita = readBarometerObs('sarapita','scb','baro','007','L1',year,month);
    pollensa = readBarometerObs('pollensa','scb','baro','001','L1',year,month);
    lamola = readBarometerObs('lamola','scb','baro','002','L1',year,month);
    coloniasantpere = readBarometerObs('coloniasantpere','pib','baro','005','L1',year,month);
    ciutadella = readBarometerObs('ciutadella','scb','baro','005','L1',year,month);
    andratx = readBarometerObs('andratx','scb','baro','003','L1',year,month);
    
else
    
    % b. if data spans over two different months (years)
    santantoni = readBarometerObs('santantoni','pib','baro','004','L1',year,month);
    sarapita = readBarometerObs('sarapita','scb','baro','007','L1',year,month);
    pollensa = readBarometerObs('pollensa','scb','baro','001','L1',year,month);
    lamola = readBarometerObs('lamola','scb','baro','002','L1',year,month);
    coloniasantpere = readBarometerObs('coloniasantpere','pib','baro','005','L1',year,month);
    ciutadella = readBarometerObs('ciutadella','scb','baro','005','L1',year,month);
    andratx = readBarometerObs('andratx','scb','baro','003','L1',year,month);
    
    % read next month (and possibly year) as well
    santantoniNext = readBarometerObs('santantoni','pib','baro','004','L1',endyear,endmonth);
    sarapitaNext = readBarometerObs('sarapita','scb','baro','007','L1',endyear,endmonth);
    pollensaNext = readBarometerObs('pollensa','scb','baro','001','L1',endyear,endmonth);
    lamolaNext = readBarometerObs('lamola','scb','baro','002','L1',endyear,endmonth);
    coloniasantpereNext = readBarometerObs('coloniasantpere','pib','baro','005','L1',endyear,endmonth);
    ciutadellaNext = readBarometerObs('ciutadella','scb','baro','005','L1',endyear,endmonth);
    andratxNext = readBarometerObs('andratx','scb','baro','003','L1',endyear,endmonth);  
    
    % merge both datasets:
    santantoni = mergeDataStructures(santantoni, santantoniNext);
    sarapita = mergeDataStructures(sarapita, sarapitaNext);
    pollensa = mergeDataStructures(pollensa, pollensaNext);
    lamola = mergeDataStructures(lamola, lamolaNext);
    coloniasantpere = mergeDataStructures(coloniasantpere, coloniasantpereNext);
    ciutadella = mergeDataStructures(ciutadella, ciutadellaNext);
    andratx = mergeDataStructures(andratx, andratxNext);
end

% crop data to the time window of interest:
barometers.santantoni = cropObservationTimeWindow(startdate,enddate,santantoni);
barometers.sarapita = cropObservationTimeWindow(startdate,enddate,sarapita);
barometers.pollensa = cropObservationTimeWindow(startdate,enddate,pollensa);
barometers.lamola = cropObservationTimeWindow(startdate,enddate,lamola);
barometers.coloniasantpere = cropObservationTimeWindow(startdate,enddate,coloniasantpere);
barometers.ciutadella = cropObservationTimeWindow(startdate,enddate,ciutadella);
barometers.andratx = cropObservationTimeWindow(startdate,enddate,andratx);