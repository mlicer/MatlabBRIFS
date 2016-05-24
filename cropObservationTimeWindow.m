function outstruct = cropObservationTimeWindow(startdate,enddate,struct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function outstruct = cropObservationTimeWindow(startdate,enddate,struct)
%
%  Function subsets timewindow of observations to WRF model times.
%
%  Input arguments:
%   startdate: datenumber with start date
%   enddate: datenumber with end date
%   struct: data struct that needs to be cropped to [startdate,enddate] time interval 
%
% Output:
%   outstruct: cropped matlab struct data
%
% Author: Matjaz Licer - NIB MBS / SOCIB
%         matjaz.licer@mbss.org
%
% Date of creation: Apr-2016
% Last modification: 12-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% check if struct contains data:
if struct.dataExists
    % find indices of data within a given time window:
    [idx,~] = find(struct.time>=startdate & struct.time<=enddate);
    
    % crop structure data to this window:
    fields = fieldnames(struct);
    for i=1:numel(fields)
        % skip metadata, only crop actual observations:
        if ~strcmpi(fields{i},'URL') && ~strcmpi(fields{i},'LAT') && ~strcmpi(fields{i},'LON') && ~strcmpi(fields{i},'dataExists')
            tmp = struct.(fields{i});
            outstruct.(fields{i})=tmp(idx);
        else
            outstruct.(fields{i})=struct.(fields{i});
        end
    end 
else
   disp('cropObservationTimeWindow: data set empty. Ignoring...')
   outstruct = struct; 
end
