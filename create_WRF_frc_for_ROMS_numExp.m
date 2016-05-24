function create_WRF_frc_for_ROMS_numExp(strdate,dirname_wrf_out,dirname_roms_in)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function create_WRF_frc_for_ROMS_numExp(strdate,dirname_wrf_out,dirname_roms_in)
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
%         Matjaz Licer - NIB MBS
%         matjaz.licer@mbss.org
% Date of creation: Jun-2015
% Last modification: 03-May-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% strdate='20150611';
% dirname_wrf_out = '/home/rissaga/new_setup/Archive/Outputs/WRF/20150611/';
% dirname_roms_in = '/home/mlicer/BRIFSverif';

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

%% Create ROMS forcing file

% generate pressure wave of appropriate dimensions for different parameters:
% wave duration in hours:
waveDuration = 6;

for theta=0:10:90;
    for cg = 25:1:35;
        pressureWaveFrequency = 1/1000.;
        for pressureWaveAmplitude = 3;
            
            % generate the wave:
            disp([theta,cg,pressureWaveAmplitude])
            pressureWave = generateArtificialPressureField(time_roms(tt_0_48)/86400.,...
                squeeze(lon_wrf(1,:)),squeeze(lat_wrf(:,1))',theta, cg,pressureWaveFrequency,pressureWaveAmplitude,waveDuration);
            
            % add 1013 hPa and permute to get the correct dimensions for
            % NetCDF writing:
            pressureWave = 1013. + permute(pressureWave,[2,1,3]);
            
            
            
            % Write netcdf file

            fname_out=[dirname_roms_in '/roms_BRIFS_frc_c' num2str(cg) ...
                '_a' num2str(pressureWaveAmplitude) '_t' num2str(theta) '.nc']
            disp([' Create ROMS forcing file ' fname_out]);
            
            % define dimensions / variables / attributes:
            
            nccreate(fname_out, 'lon','Dimensions',{'lon',size(lon_wrf,2)},'Format','classic');
            ncwriteatt(fname_out,'lon','long_name','longitude');
            ncwriteatt(fname_out,'lon','units','degrees_east');
            
            nccreate(fname_out, 'lat','Dimensions',{'lat',size(lon_wrf,1)});
            ncwriteatt(fname_out,'lat','long_name','latitude');
            ncwriteatt(fname_out,'lat','units','degrees_north');
            
            nccreate(fname_out, 'ocean_time','Dimensions',{'ocean_time',length(tt_0_48)});
            ncwriteatt(fname_out,'ocean_time','long_name','time');
            ncwriteatt(fname_out,'ocean_time','units','seconds since 1968-05-23 00:00:00 GMT');
            
            nccreate(fname_out, 'cg');
            ncwriteatt(fname_out,'cg','long_name','pressure wave group velocity');
            ncwriteatt(fname_out,'cg','units','ms-1');
            
            nccreate(fname_out, 'theta');
            ncwriteatt(fname_out,'theta','long_name','pressure wave propagation angle over Ciutadella');
            ncwriteatt(fname_out,'theta','units','degrees_from_north');
            
            nccreate(fname_out, 'pressure_wave_frequency');
            ncwriteatt(fname_out,'pressure_wave_frequency','long_name','pressure wave frequency');
            ncwriteatt(fname_out,'pressure_wave_frequency','units','s-1');
            
            nccreate(fname_out, 'pressure_wave_amplitude');
            ncwriteatt(fname_out,'pressure_wave_amplitude','long_name','pressure wave amplitude');
            ncwriteatt(fname_out,'pressure_wave_amplitude','units','hPa');
            
            nccreate(fname_out, 'Pair','Dimensions',{'lon',size(lon_wrf,2),'lat',size(lon_wrf,1),'ocean_time',length(tt_0_48)});
            ncwriteatt(fname_out,'Pair','long_name','Air pressure at 2 m');
            ncwriteatt(fname_out,'Pair','units','hPa');
            ncwriteatt(fname_out,'Pair','time','ocean_time');
            ncwriteatt(fname_out,'Pair','coordinates','lon lat');
            ncwriteatt(fname_out,'Pair','missing_value',Missval);
            
            % add global attributes:
            ncwriteatt(fname_out,'/','title','Numerical experiment artificial monochromatic pressure wave forcing file generated from WRF outputs for ROMS forcing');
            ncwriteatt(fname_out,'/','authors','bmourre@socib.es, matjaz.licer@mbss.org');
            ncwriteatt(fname_out,'/','date',datestr(now));
            
            % fill variables:
            ncwrite(fname_out,'ocean_time',time_roms(tt_0_48))
            ncwrite(fname_out,'lon',lon_wrf(1,:))
            ncwrite(fname_out,'lat',lat_wrf(:,1))
            ncwrite(fname_out,'cg',cg)
            ncwrite(fname_out,'theta',theta)
            ncwrite(fname_out,'pressure_wave_frequency',pressureWaveFrequency)
            ncwrite(fname_out,'pressure_wave_amplitude',pressureWaveAmplitude)
            
            ncwrite(fname_out,'Pair',pressureWave)
            
        end
    end
end

return




