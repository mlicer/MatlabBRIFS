function currentProfilers = readCurrentProfilerObservations(strdate)
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
% profiler_code.lamola_scb2= 'scb_aqp002';
% profiler_code.lamola_scb1= 'scb_aqp001';
% profiler_code.ciutadella = 'ime_awac001';
% profiler_code.canaldeibiza = 'scb_sontek002';
% profiler_code.bahiadepalma = 'scb_sontek001';

if strcmpi(endyear,year) && strcmpi(endmonth,month)
    
    % a. if all the data is in the same month (year):
    lamola_scb1 = readCurrentProfilerObs('lamola_scb1','L1',year,month);
    lamola_scb2 = readCurrentProfilerObs('lamola_scb2','L1',year,month);
    ciutadella = readCurrentProfilerObs('ciutadella','L1',year,month);
    canaldeibiza = readCurrentProfilerObs('canaldeibiza','L1',year,month);
    bahiadepalma = readCurrentProfilerObs('bahiadepalma','L1',year,month);
    
else
    
    % b. if data spans over two different months (years)
    lamola_scb1 = readCurrentProfilerObs('lamola_scb1','L1',year,month);
    lamola_scb2 = readCurrentProfilerObs('lamola_scb2','L1',year,month);
    ciutadella = readCurrentProfilerObs('ciutadella','L1',year,month);
    canaldeibiza = readCurrentProfilerObs('canaldeibiza','L1',year,month);
    bahiadepalma = readCurrentProfilerObs('bahiadepalma','L1',year,month);
    
    % read next month (and possibly year) as well
    lamola_scb1Next = readCurrentProfilerObs('lamola_scb1','L1',endyear,endmonth);
    lamola_scb2Next = readCurrentProfilerObs('lamola_scb2','L1',endyear,endmonth);
    ciutadellaNext = readCurrentProfilerObs('ciutadella','L1',endyear,endmonth)
    canaldeibizaNext = readCurrentProfilerObs('canaldeibiza','L1',endyear,endmonth);
    bahiadepalmaNext = readCurrentProfilerObs('bahiadepalma','L1',endyear,endmonth);
    
    % merge both datasets:
    lamola_scb1 = mergeDataStructures(lamola_scb1, lamola_scb1Next);
    lamola_scb2 = mergeDataStructures(lamola_scb2, lamola_scb2Next);
    ciutadella = mergeDataStructures(ciutadella, ciutadellaNext);
    canaldeibiza = mergeDataStructures(canaldeibiza, canaldeibizaNext);
    bahiadepalma = mergeDataStructures(bahiadepalma, bahiadepalmaNext);
end

% crop data to the time window of interest:
currentProfilers.lamola_scb1 = cropObservationTimeWindow(startdate,enddate,lamola_scb1);
currentProfilers.lamola_scb2 = cropObservationTimeWindow(startdate,enddate,lamola_scb2);
currentProfilers.ciutadella = cropObservationTimeWindow(startdate,enddate,ciutadella);
currentProfilers.canaldeibiza = cropObservationTimeWindow(startdate,enddate,canaldeibiza);
currentProfilers.bahiadepalma = cropObservationTimeWindow(startdate,enddate,bahiadepalma);
