%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This is a wrapper script which loops over all folders of ROMS archived
% outputs and performs SSH verifications against the in situ data. For
% more details see plot_sealevel_ROMS_BRIFS_OBS.m.
%
%
% Author: Matjaz Licer - NIB MBS
%         matjaz.licer@mbss.org
% Date of creation: Jun-2015
% Last modification: 02-May-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dir('/home/rissaga/new_setup/Archive/Outputs/ROMS/');

datesList = [];

for i =3:numel(files)
    fname = files(i).name
    splitloc = regexp(fname,'_')
    strdate = fname(splitloc(end-1)+1:splitloc(end)-1)
    % if strdate date was not yet analyzed, do it:
    if ~any(datesList==str2num(strdate))
%         try
            plot_sealevel_ROMS_BRIFS_OBS(strdate,'worstfit','/home/rissaga/new_setup/Archive/Outputs/ROMS/','/home/mlicer/BRIFSverif/plots/ROMS/')
            datesList = [datesList; str2num(strdate)]
%         catch
%             continue
%         end
    end
end
