function tide_gauges = readTideGaugeObservations(strdate)
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

% Read in situ tide gauge observations:

if strcmpi(endyear,year) && strcmpi(endmonth,month)
    sarapita_scb = readTideGaugeObs('sarapita_scb','L1',year,month);
    sarapita_ime = readTideGaugeObs('sarapita_ime','L1',year,month);
    santantoni = readTideGaugeObs('santantoni','L1',year,month);
    portocristo = readTideGaugeObs('portocristo','L1',year,month);
    pollensa_scb = readTideGaugeObs('pollensa_scb','L1',year,month);
    pollensa_ime3 = readTideGaugeObs('pollensa_ime3','L1',year,month);
    pollensa_ime2 = readTideGaugeObs('pollensa_ime2','L1',year,month);
    coloniasantpere = readTideGaugeObs('coloniasantpere','L1',year,month);
    andratx_ime4 = readTideGaugeObs('andratx_ime4','L1',year,month);
    andratx_ime1 = readTideGaugeObs('andratx_ime1','L1',year,month);    
else
    
    % b. if data spans over two different months (years)
    sarapita_scb = readTideGaugeObs('sarapita_scb','L1',year,month);
    sarapita_ime = readTideGaugeObs('sarapita_ime','L1',year,month);
    santantoni = readTideGaugeObs('santantoni','L1',year,month);
    portocristo = readTideGaugeObs('portocristo','L1',year,month);
    pollensa_scb = readTideGaugeObs('pollensa_scb','L1',year,month);
    pollensa_ime3 = readTideGaugeObs('pollensa_ime3','L1',year,month);
    pollensa_ime2 = readTideGaugeObs('pollensa_ime2','L1',year,month);
    coloniasantpere = readTideGaugeObs('coloniasantpere','L1',year,month);
    andratx_ime4 = readTideGaugeObs('andratx_ime4','L1',year,month);
    andratx_ime1 = readTideGaugeObs('andratx_ime1','L1',year,month);   
    
    % read next month (and possibly year) as well
    sarapita_scbNext = readTideGaugeObs('sarapita_scb','L1',endyear,endmonth);
    sarapita_imeNext = readTideGaugeObs('sarapita_ime','L1',endyear,endmonth);
    santantoniNext = readTideGaugeObs('santantoni','L1',endyear,endmonth);
    portocristoNext = readTideGaugeObs('portocristo','L1',endyear,endmonth);
    pollensa_scbNext = readTideGaugeObs('pollensa_scb','L1',endyear,endmonth);
    pollensa_ime3Next = readTideGaugeObs('pollensa_ime3','L1',endyear,endmonth);
    pollensa_ime2Next = readTideGaugeObs('pollensa_ime2','L1',endyear,endmonth);
    coloniasantpereNext = readTideGaugeObs('coloniasantpere','L1',endyear,endmonth);
    andratx_ime4Next = readTideGaugeObs('andratx_ime4','L1',endyear,endmonth);
    andratx_ime1Next = readTideGaugeObs('andratx_ime1','L1',endyear,endmonth);    
    
    % merge both datasets:
    santantoni = mergeDataStructures(santantoni, santantoniNext);
    sarapita_scb = mergeDataStructures(sarapita_scb, sarapita_scbNext);
    sarapita_ime = mergeDataStructures(sarapita_ime, sarapita_imeNext);
    portocristo = mergeDataStructures(portocristo, portocristoNext);
    coloniasantpere = mergeDataStructures(coloniasantpere, coloniasantpereNext);
    pollensa_scb = mergeDataStructures(pollensa_scb, pollensa_scbNext);
    pollensa_ime3 = mergeDataStructures(pollensa_ime3, pollensa_ime3Next);
    pollensa_ime2 = mergeDataStructures(pollensa_ime2, pollensa_ime2Next);
    andratx_ime4 = mergeDataStructures(andratx_ime4, andratx_ime4Next);
    andratx_ime1 = mergeDataStructures(andratx_ime1, andratx_ime1Next);
end

% crop data to the time window of interest:
tide_gauges.santantoni = cropObservationTimeWindow(startdate,enddate,santantoni);
tide_gauges.sarapita_scb = cropObservationTimeWindow(startdate,enddate,sarapita_scb);
tide_gauges.sarapita_ime = cropObservationTimeWindow(startdate,enddate,sarapita_ime);
tide_gauges.portocristo = cropObservationTimeWindow(startdate,enddate,portocristo);
tide_gauges.coloniasantpere = cropObservationTimeWindow(startdate,enddate,coloniasantpere);
tide_gauges.pollensa_scb = cropObservationTimeWindow(startdate,enddate,pollensa_scb);
tide_gauges.pollensa_ime3 = cropObservationTimeWindow(startdate,enddate,pollensa_ime3);
tide_gauges.pollensa_ime2 = cropObservationTimeWindow(startdate,enddate,pollensa_ime2);
tide_gauges.andratx_ime4 = cropObservationTimeWindow(startdate,enddate,andratx_ime4);
tide_gauges.andratx_ime1 = cropObservationTimeWindow(startdate,enddate,andratx_ime1);
