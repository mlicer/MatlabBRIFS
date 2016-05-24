function wrf_data = maskLandPoints(wrf_data)
% masks out land points (land = 1, sea = 0) if so specified

% get all field names in WRF data:
fields = fieldnames(wrf_data);
    
% loop over all fields:
    for f = 1:length(fields)

        % if array is equal in size to wrf_data.lsm (land sea mask), set to NaN
        % all points over land (where lsm == 1):
        if isequal(size(wrf_data.(fields{f})), size(wrf_data.LANDMASK))
            tmp = wrf_data.(fields{f});
            tmp(wrf_data.LANDMASK==1)=NaN;
            wrf_data.(fields{f}) = tmp;
        end
    end