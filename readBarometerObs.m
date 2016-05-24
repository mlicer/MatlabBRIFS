function data = readBarometerObs(station,instrument,type,code,level,year,month)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function data = readBarometerObs(station,instrument,type,code,level,year,month)
%
%  Reads barometer observations from SOCIB THREDDS server
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

disp('Reading IN SITU Barometer Observations...')
base_string = 'http://thredds.socib.es/thredds/dodsC/mooring/barometer/';
station_string = ['station_' station];

% construct filename:
fname = [base_string station_string '-' instrument '_' type code '/' level '/' year ...
    '/dep0001_station-' station '_' instrument '-' type code '_' level '_' year '-' month '.nc'];

% try to download:
try
     data.dataExists=true;
     data.URL=fname;
     time = ncread(fname,'time');
     t0 = datenum('1970-01-01 00:00:00','yyyy-mm-dd HH:MM:SS');
     dates = t0 + time/86400.;
     data.time = dates;
     data.LAT =  double(ncread(fname,'LAT'));
     data.LON =  double(ncread(fname,'LON'));
     data.AIR_PRE =  double(ncread(fname,'AIR_PRE'));
     data.QC_AIR_PRE =  double(ncread(fname,'QC_AIR_PRE'));
catch
    data.dataExists=false;
    disp('>>>> readBarometerObs: CATCH WARNING: the file ')
    disp(fname)
    disp('could not be read.')
end