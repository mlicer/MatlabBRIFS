function outstruct = mergeDataStructures(struct1,struct2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function outstruct = mergeDataStructures(struct1,struct2)
%
%  Merges data from two consecutive months, if the rissaga happens to occur
%  on the last day of a month (year).
%
%  Input arguments:
%     struct1: first month data structure from readBarometerObs
%     strcut2: second month data structure from readBarometerObs
%
%
% Output:
%   outstruct: concatenated data from both months, cropped to a given
%   timewindow (2 days usualy).
%
% Author: Matjaz Licer - NIB MBS / SOCIB
%         matjaz.licer@mbss.org
%
% Date of creation: Apr-2016
% Last modification: 12-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields1 = fieldnames(struct1);

 % if both structures contain data...
if struct1.dataExists && struct2.dataExists
    % ...loop over all the contained fields and concat them
    for i=1:numel(fields1)
        outstruct.(fields1{i})=[struct1.(fields1{i});struct2.(fields1{i})];
    end

    % keep only unique elements of metadata (no reason to have *two* same LATS, LONS, dataExists etc.)
        outstruct.dataExists = struct1.dataExists;
        outstruct.LAT = struct1.LAT;
        outstruct.LON = struct1.LON;

    % else return the data that DOES exist and ignore the other:
elseif struct1.dataExists && ~struct2.dataExists
    outstruct = struct1;
elseif ~struct1.dataExists && struct2.dataExists
    outstruct = struct2;
else
    disp('WARNING: mergeDataStructures: There seems to be no data available for merging!')
    outstruct.dataExists=false;
end
