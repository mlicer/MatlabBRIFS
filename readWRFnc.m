function [time,lon_wrf,lat_wrf,MSLP] = readWRFnc(strdate,dirname_out,dirname_plots);

mydate=datenum(strdate,'yyyymmdd');

if ~exist(dirname_out)
    disp(['  ERROR: Directory ' dirname_out ' not found']);
    return
end
if ~exist(dirname_plots)
    disp(['  ERROR: Directory ' dirname_plots ' not found']);
    return
end

filelist=dir([dirname_out '/wrfout_d02_*']);
Icount=0;
firstfile=1;

if length(filelist)==0
    disp(['  ERROR: No WRF output files found for ' datestr(mydate)]);
    return
end

%%
for kf=1:length(filelist)
    
    fname=[dirname_out '/' filelist(kf).name]
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