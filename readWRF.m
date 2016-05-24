function wrf_data = readWRF(wrf_output)
           % read dates contained & convert to datenums:
           wrf_data.times = datenum(ncread(wrf_output,'Times')','yyyy-mm-dd_HH:MM:SS');
           wrf_data.startdate = wrf_data.times(1);
           wrf_data.enddate = wrf_data.times(end);
           % temporal resolution in minutes:
           wrf_data.dt = diff(wrf_data.times(1:2))*24;
           
           % determine nesting level:
           dloc = strfind(wrf_output,'_d0');
           nestingLevelString = wrf_output(dloc:dloc+3);
           wrf_data.nestingLevelString = nestingLevelString;
           
           % read grid:
           wrf_data.lats =  double(ncread(wrf_output,'XLAT'));
           wrf_data.lons =  double(ncread(wrf_output,'XLONG'));
        
           % read data:
           wrf_data.PSFC = double(ncread(wrf_output,'PSFC')) * 1.e-2;
           wrf_data.U10 = double(ncread(wrf_output,'U10'));
           wrf_data.V10 = double(ncread(wrf_output,'V10'));
           wrf_data.PBLH = double(ncread(wrf_output,'PBLH'));
           wrf_data.T2 = double(ncread(wrf_output,'T2'));
           wrf_data.LANDMASK = double(ncread(wrf_output,'LANDMASK'));
           wrf_data.HGT = double(ncread(wrf_output,'HGT'));
end