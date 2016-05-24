
function data = readTideGaugeObs(station,level,year,month)
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

disp(['Reading ' upper(station) ' IN SITU Sea Level Observations...'])
base_string = 'http://thredds.socib.es/thredds/dodsC/mooring/tide_gauge/';

% determine station name:
uLoc = strfind(station,'_');
if ~isempty(uLoc)
    stationName = station(1:uLoc-1);
else
    stationName = station;
end

station_string = ['station_' stationName];

tide_gauge_code.sarapita_scb= 'scb_sbe26003';
tide_gauge_code.sarapita_ime= 'ime_sbe26003';
tide_gauge_code.santantoni = 'scb_wlog001';
tide_gauge_code.portocristo = 'pib_sbe54006';
tide_gauge_code.pollensa_scb = 'scb_sbe26002';
tide_gauge_code.pollensa_ime3 = 'ime_sbe26003';
tide_gauge_code.pollensa_ime2 = 'ime_sbe26002';
tide_gauge_code.coloniasantpere = 'pib_sbe54004';
tide_gauge_code.andratx_ime4 = 'ime_sbe26004';
tide_gauge_code.andratx_ime1 = 'ime_sbe26001';

% construct filename:
fname = [base_string station_string '-' tide_gauge_code.(station) '/' level '/' year ...
    '/dep0001_station-' stationName '_' strrep(tide_gauge_code.(station),'_','-') '_' level '_' year '-' month '.nc'];

% try to download WTR_PRE:
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
    disp('>>>> readSeaLevelObs: CATCH WARNING: the file ')
    disp(fname)
    disp('could not be read.')
end

% try to download SLEV:
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