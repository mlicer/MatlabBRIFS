function sealevels = readSeaLevelObservations(strdate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function barometers = readSeaLevelObservations(strdate)
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
    santantoni = readSeaLevelObs('santantoni','L1',year,month);
    sarapita = readSeaLevelObs('sarapita','L1',year,month);
    pollensa = readSeaLevelObs('pollensa','L1',year,month);
    portocristo = readSeaLevelObs('portocristo','L1',year,month);
    coloniasantpere = readSeaLevelObs('coloniasantpere','L1',year,month);
    andratx = readSeaLevelObs('andratx','L1',year,month);
    
else
    
    % b. if data spans over two different months (years)
    santantoni = readSeaLevelObs('santantoni','L1',year,month);
    sarapita = readSeaLevelObs('sarapita','L1',year,month);
    pollensa = readSeaLevelObs('pollensa','L1',year,month);
    portocristo = readSeaLevelObs('portocristo','L1',year,month);
    coloniasantpere = readSeaLevelObs('coloniasantpere','L1',year,month);
    andratx = readSeaLevelObs('andratx','L1',year,month);
    
    % read next month (and possibly year) as well
    santantoniNext = readSeaLevelObs('santantoni','L1',endyear,endmonth);
    sarapitaNext = readSeaLevelObs('sarapita','L1',endyear,endmonth);
    pollensaNext = readSeaLevelObs('pollensa','L1',endyear,endmonth);
    portocristoNext = readSeaLevelObs('portocristo','L1',endyear,endmonth);
    coloniasantpereNext = readSeaLevelObs('coloniasantpere','L1',endyear,endmonth);
    andratxNext = readSeaLevelObs('andratx','L1',endyear,endmonth); 
    
    % merge both datasets:
    santantoni = mergeDataStructures(santantoni, santantoniNext);
    sarapita = mergeDataStructures(sarapita, sarapitaNext);
    pollensa = mergeDataStructures(pollensa, pollensaNext);
    portocristo = mergeDataStructures(portocristo, portocristoNext);
    coloniasantpere = mergeDataStructures(coloniasantpere, coloniasantpereNext);
    andratx = mergeDataStructures(andratx, andratxNext);
end

% crop data to the time window of interest:
sealevels.santantoni = cropObservationTimeWindow(startdate,enddate,santantoni);
sealevels.sarapita = cropObservationTimeWindow(startdate,enddate,sarapita);
sealevels.pollensa = cropObservationTimeWindow(startdate,enddate,pollensa);
sealevels.portocristo = cropObservationTimeWindow(startdate,enddate,portocristo);
sealevels.coloniasantpere = cropObservationTimeWindow(startdate,enddate,coloniasantpere);
sealevels.andratx = cropObservationTimeWindow(startdate,enddate,andratx);