%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a wrapper script which loops over all folders of WRF archived
% outputs and performs pressure verifications against the in situ data. For
% more details see plot_pressure_WRF_BRIFS_OBS.m.
%
%
% Author: Matjaz Licer - NIB MBS
%         matjaz.licer@mbss.org
% Date of creation: Jun-2015
% Last modification: 02-May-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folders = dir('/home/rissaga/new_setup/Archive/Outputs/WRF/');
folders = folders(3:end);

for i =1:numel(folders)
   strdate = folders(i).name
   try
       plot_pressure_WRF_BRIFS_OBS(strdate,['/home/rissaga/new_setup/Archive/Outputs/WRF/' strdate '/'],'/home/mlicer/BRIFSverif/plots/WRF/')
   catch
       continue
   end
end
 