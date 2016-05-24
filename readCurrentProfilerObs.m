function data = readCurrentProfilerObs(station,level,year,month)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function data = readTideGaugeObs(station,instrument,type,code,level,year,month)
%
%  Reads sea level observations from SOCIB THREDDS server
%
%  Input arguments:
%   station: string station name (i.e. 'ciutadella')
%   instrument: string instrument name ('scb','pib', 'ime'...)
%   type: barometer = string baro
%   code: string number 007, 004, ...
%   level: string QC level, 'L1' recommended i guess
%   year: string yyyy year
%   month: string mm month
%
% Output:
%   data: matlab struct data
%
% Author: Matjaz Licer - NIB MBS / SOCIB
%         matjaz.licer@mbss.org
%
% Date of creation: Apr-2016
% Last modification: 12-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Reading ' upper(station) ' IN SITU Current Profiler Observations...'])
base_string = 'http://thredds.socib.es/thredds/dodsC/mooring/current_profiler/';

% http://thredds.socib.es/thredds/dodsC/mooring/current_profiler/
% station_ciutadella-ime_awac001/L1/2016/dep0001_station-ciutadella_ime-awac001_L1_2016-03.nc

% determine station name:
uLoc = strfind(station,'_');
if ~isempty(uLoc)
    stationName = station(1:uLoc-1);
else
    stationName = station;
end

station_string = ['station_' stationName];

profiler_code.lamola_scb2= 'scb_aqp002';
profiler_code.lamola_scb1= 'scb_aqp001';
profiler_code.ciutadella = 'ime_awac001';
profiler_code.canaldeibiza = 'scb_sontek002';
profiler_code.bahiadepalma = 'scb_sontek001';

% http://thredds.socib.es/thredds/dodsC/mooring/current_profiler/
% station_ciutadella-ime_awac001/L1/2016/dep0001_station-ciutadella_ime-awac001_L1_2016-03.nc

% http://thredds.socib.es/thredds/dodsC/mooring/current_profiler/
% station_lamola-scb_aqp001/L1/2015/dep0001_station-lamola_scb-aqp001_L1_2015-07.nc

% construct filename:
fname = [base_string station_string '-' profiler_code.(station) '/' level '/' year ...
    '/dep0001_station-' stationName '_' strrep(profiler_code.(station),'_','-') '_' level '_' year '-' month '.nc'];


% try to download:
try
    QC_WTR_PRE = double(ncread(fname,'QC_WTR_PRE'));
    % check for missing data:
    if any(QC_WTR_PRE~=9)
        data.dataExists=true;
        data.URL=fname;
        time = ncread(fname,'time');
        t0 = datenum('1970-01-01 00:00:00','yyyy-mm-dd HH:MM:SS');
        dates = t0 + time/86400.;
        data.time = dates;
        data.LAT =  double(ncread(fname,'LAT'));
        data.LON =  double(ncread(fname,'LON'));
        
        data.WTR_PRE =  double(ncread(fname,'WTR_PRE'));
        data.QC_WTR_PRE =  QC_WTR_PRE;
    else
        disp([upper(station) ' contains no data.'])
        data.dataExists=false;
    end
catch
    data.dataExists=false;
    disp('>>>> readCurrentProfilerObs: CATCH WARNING: the file ')
    disp(fname)
    disp('could not be read.')
end