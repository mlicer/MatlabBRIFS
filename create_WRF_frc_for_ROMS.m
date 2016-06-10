function create_WRF_frc_for_ROMS(strdate,dirname_wrf_out,dirname_roms_in)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function create_WRF_frc_for_ROMS(strdate,dirname_wrf_out,dirname_roms_in)
%
%  Create atmospheric pressure forcing file for ROMS from WRF outputs at a given date.
%
%  Input arguments:
%     strdate: YYYYMMDD
%     dirname_wrf_out: directory with WRF output files for that date
%     dirname_roms_in: directory for ROMS forcing files
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Date of creation: Jun-2015
% Last modification: 12-Jun-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mydate=datenum(strdate,'yyyymmdd');

if ~exist(dirname_wrf_out)
    disp(['  ERROR: Directory ' dirname_wrf_out ' not found']);
    return
end

filelist=dir([dirname_wrf_out '/wrfout_d02_*']);
Icount=0;
firstfile=1;

if length(filelist)==0
    disp(['  ERROR: No WRF output files found for ' datestr(mydate)]);
    return
end

for kf=1:length(filelist)
    
    fname=[dirname_wrf_out '/' filelist(kf).name];
    disp([' Reading file ' fname '...']);
    ttime=datenum(nc_varget(fname,'Times'));
    if (max(ttime)<mydate)
        disp(['   Skip file ' fname ' :data in the past']);
        continue
    end
    nt=length(ttime);
    time(Icount+1:Icount+nt)=ttime;
    if (firstfile==1)
        lon_wrf=squeeze(nc_varget(fname,'XLONG',[0 0 0],[1 -1 -1]));
        lat_wrf=squeeze(nc_varget(fname,'XLAT',[0 0 0],[1 -1 -1]));
        [ny nx]=size(lon_wrf);
        firstfile=0;
    end
    PSFC(Icount+1:Icount+nt,:,:)=nc_varget(fname,'PSFC');
    HGT(Icount+1:Icount+nt,:,:)=nc_varget(fname,'HGT');
    T2(Icount+1:Icount+nt,:,:)=nc_varget(fname,'T2');
    Q2(Icount+1:Icount+nt,:,:)=nc_varget(fname,'Q2');
    XLAND(Icount+1:Icount+nt,:,:)=nc_varget(fname,'XLAND');
    
    Icount=Icount+nt;
end

nt=length(time);

% Compute MSLP
PSFC=PSFC/100;   % Convert to hPa
MSLP=PSFC.*exp(9.81.*HGT./(287.*T2.*(1+0.61.*Q2)));
% Mask MSLP
MSLP_masked=MSLP;
MSLP_masked(XLAND==1)=NaN;
PSFC_masked=PSFC;
PSFC_masked(XLAND==1)=NaN;

% Prepare variables for routine Write_cdf_rissaga
time_roms=(time-datenum(1968,5,23))*3600*24;   % convert WRF time to ROMS time
tt_0_48=find(time-mydate>=0 & time-mydate<=2);

% Missing value
Missval=32234;
MSLP(isnan(MSLP))=Missval;

% Create ROMS forcing file 
fname_out=[dirname_roms_in '/roms_BRIFS_WRF_frc_' strdate '.nc'];
fname_out=[dirname_roms_in '/frc_template.nc'];
disp([' Create ROMS forcing file ' fname_out]);

% Write netcdf file
f = netcdf(fname_out, 'CLOBBER');
if isempty(f)
    disp(' ROMS forcing file not created.')
    return
end
% define global arguments
f.title=['Pressure forcing file generated from WRF outputs for ROMS forcing'];
f.author = 'bmourre@socib.es';
f.date = datestr(now);
% define dimensions
f('lon')     = size(lon_wrf,2);
f('lat')     = size(lon_wrf,1);
f('ocean_time')    = length(tt_0_48)  ;
% define independent variables
f{'ocean_time'} = ncdouble('ocean_time');
f{'ocean_time'}.long_name = ncchar('time');
f{'ocean_time'}.units = ncchar('seconds since 1968-05-23 00:00:00 GMT');
f{'lon'} = ncdouble('lon');
f{'lon'}.long_name = ncchar('longitude');
f{'lon'}.units = ncchar('degrees_east');
f{'lat'} = ncdouble('lat');
f{'lat'}.long_name = ncchar('latitude');
f{'lat'}.units = ncchar('degrees_north');
% define dependent variables
f{'Pair'}                = ncfloat('ocean_time','lat','lon');
f{'Pair'}.long_name       = 'Air pressure at 2 m';
f{'Pair'}.units          = 'hPa';
f{'Pair'}.time          = 'ocean_time';
f{'Pair'}.coordinates    = 'lon lat';
f{'Pair'}.missing_value  = Missval;
% fill variables
 f{'ocean_time'}(:)=time_roms(tt_0_48);
 f{'lon'}(:)=lon_wrf(1,:);
 f{'lat'}(:)=lat_wrf(:,1);
 f{'Pair'}(:,:,:)=MSLP(tt_0_48,:,:);
% close file
 close(f);


% Generate best fit WRF forcing (with adjusted latitude of the pressure wave)
fname_out_adjusted=[dirname_roms_in '/roms_BRIFS_WRF_bf_frc_' strdate '.nc'];
disp([' Create ROMS adjusted forcing file ' fname_out_adjusted]);
% Compute latitudinal correction
alpha=compute_meridional_offset_wrf_wavetrain(lon_wrf(1,:),lat_wrf(:, 1),double(MSLP));
lat_wrf_adjusted=lat_wrf+alpha;

% Write netcdf file
f = netcdf(fname_out_adjusted, 'clobber');
if isempty(f)
    disp(' ROMS forcing file not created.')
    return
end
% define global arguments
f.title=['Adjuted pressure forcing file (including meridional correction) generated from WRF outputs for ROMS forcing'];
f.author = 'bmourre@socib.es';
f.date = datestr(now);
% define dimensions
f('lon')     = size(lon_wrf,2);
f('lat')     = size(lon_wrf,1);
f('ocean_time')    = length(tt_0_48)  ;
% define independent variables
f{'ocean_time'} = ncdouble('ocean_time');
f{'ocean_time'}.long_name = ncchar('time');
f{'ocean_time'}.units = ncchar('seconds since 1968-05-23 00:00:00 GMT');
f{'lon'} = ncdouble('lon');
f{'lon'}.long_name = ncchar('longitude');
f{'lon'}.units = ncchar('degrees_east');
f{'lat'} = ncdouble('lat');
f{'lat'}.long_name = ncchar('latitude');
f{'lat'}.units = ncchar('degrees_north');
% define dependent variables
f{'Pair'}                = ncfloat('ocean_time','lat','lon');
f{'Pair'}.long_name       = 'Air pressure at 2 m';
f{'Pair'}.units          = 'hPa';
f{'Pair'}.time          = 'ocean_time';
f{'Pair'}.coordinates    = 'lon lat';
f{'Pair'}.missing_value  = Missval;
% fill variables
 f{'ocean_time'}(:)=time_roms(tt_0_48);
 f{'lon'}(:)=lon_wrf(1,:);
 f{'lat'}(:)=lat_wrf_adjusted(:,1);
 f{'Pair'}(:,:,:)=MSLP(tt_0_48,:,:);
% close file
 close(f);

return




