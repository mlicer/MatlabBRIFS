
function data = readSeaLevelObs(station,level,year,month)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function data = readSeaLevelObs(station,instrument,type,code,level,year,month)
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

disp(['Reading ' upper(station) ' IN SITU Sea Level Observations...'])
base_string = 'http://thredds.socib.es/thredds/dodsC/mooring/sea_level/';
station_string = ['station_' station];

sea_level_code.sarapita = '20110505';
sea_level_code.santantoni = '20150305';
sea_level_code.portocristo = '20160206';
sea_level_code.pollensa = '20110701';
sea_level_code.coloniasantpere = '20151028';
sea_level_code.andratx = '20110602';

% construct filename:
fname = [base_string station_string '/' level '/' year ...
    '/dep' sea_level_code.(station) '_' 'station-' station '_' level '_' year '-' month '.nc'];


% try to download:
try
    QC_SLEV = double(ncread(fname,'QC_SLEV'));
    % check for missing data:
    if any(QC_SLEV~=9)
        data.dataExists=true;
        data.URL=fname;
        time = ncread(fname,'time');
        t0 = datenum('1970-01-01 00:00:00','yyyy-mm-dd HH:MM:SS');
        dates = t0 + time/86400.;
        data.time = dates;
        data.LAT =  double(ncread(fname,'LAT'));
        data.LON =  double(ncread(fname,'LON'));
        data.SLEV =  double(ncread(fname,'SLEV'));
        data.QC_SLEV =  QC_SLEV;
    else        
        disp([upper(station) ' contains no data.'])
        data.dataExists=false;
    end
catch
    data.dataExists=false;
    disp('>>>> readSeaLevelObs: CATCH WARNING: the file ')
    disp(fname)
    disp('could not be read.')
end