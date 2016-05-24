function struct_hf = removeLowFrequencies(struct,fieldname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function struct_hf = removeLowFrequencies(struct,fieldname)
%
%  Removes low-frequency signal from struct.fieldname data, using a zero-phase
%  4th order Butterworth filter.
%
%  Input arguments:
%     struct: Matlab structure, containing observational data from several
%     stations, each of which contains a field "fieldname", on which
%     high-pass filtering will be performed. struct should be obtained from
%     readSeaLevelObservations.m or readPressureObservations.m
%     fieldname: a string name of the field contained in the 
%     struct.station.fieldname, for example 'SLEV': seaLevels.santantoni.SLEV.
%
%   cutOffPeriodInNormalizedUnits is cutOff period in minutes.
%     
%
% Author: Matjaz Licer - NIB MBS @SOCIB
%         matjaz.licer@mbss.org
% Date of creation: May-2015
% Last modification: 18-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off;


% list all stations in the struct:
stations = fieldnames(struct);

% loop over all stations in the struct:
for k =1:numel(stations)
    % if data exists and is not NaN:
    if struct.(stations{k}).dataExists && any(struct.(stations{k}).(fieldname))
        try
            % design 4th order Butterworth filter:
            filterOrder=4;
            cutOffPeriodInNormalizedUnits=200;           
            cutOffFrequency = 1/(cutOffPeriodInNormalizedUnits/2);
            
            h=fdesign.highpass('N,F3dB',filterOrder,cutOffFrequency);
            d1 = design(h,'butter');
            
            % add time to output structure:
            struct_hf.(stations{k}).time = struct.(stations{k}).time;
            
            % perform filtering:
            y_hf = filtfilt(d1.sosMatrix,d1.ScaleValues,...
                naninterp(struct.(stations{k}).(fieldname)));
            % remove low frequencies and add high-pass filtered data to output 
            % structure:
            struct_hf.(stations{k}).(fieldname) = y_hf;
            struct_hf.dataExists=true;
        catch
            if ~struct_hf.dataExists
                struct_hf.dataExists=false;
            end
            continue
        end
    end
end

