% BRIFS VERIFICATION SCRIPTS
%
% The code reads and plots BRIFS WRF results for subsequent verification.
% More info: Matjaz Licer, matjaz.licer@mbss.org, matjaz.licer@gmail.com
% SOCIB/IMEDEA, April 2016
%
% TASK 1
%
% T1.1 Characterization of synoptic atmospheric conditions from observations
% and WRF model at the surface and upper levels, inversion (?), characterization
% of atmospheric pressure disturbance (wavelike and/or step function, amplitude,
% speed, etc.) and associate back with synoptic conditions/observations from satellite....
% T1.2: WRF Validation: Does the model generate atmospheric pressure jumps
% and where?, What is the direction/speed of propagation of these atmospheric
% pressure jumps/oscillations ?
clc; clear; close all

% set WRF archive directory:
wrf_archive_dir='/home/rissaga/new_setup/Archive/Outputs/WRF/';

% do we mask out the land points (1) or not (0):
maskLand = logical(1);

% do we save plots (1) or not (0):
savePlots = logical(0);

% set verification directory:
verif_dir = '/home/mlicer/BRIFSverif/';
verif_plot_dir = [verif_dir 'plots/']

% list all folders therein:
folders = dir(wrf_archive_dir);

% loop over folders (starts with 3 to avoid . and ..):
for k = 3:length(folders)
    
    % set folder name:
    folder = folders(k).name;
    
    % check if 'wrfout_*' output files exist in the folder:
    wrf_outputs = dir([wrf_archive_dir folder '/wrfout_*']);
    
    % if they do, loop over the outputs:
    if size(wrf_outputs,1) > 0
        for i = 1:size(wrf_outputs,1)
            
            % set current WRF output filename:
            wrf_output_filename = [wrf_archive_dir folder '/' wrf_outputs(i).name];
            
            % read WRF output:
            disp(['...Reading data from: ' wrf_output_filename])
            wrfdata = readWRF(wrf_output_filename);
            
            if maskLand
                wrfdata = maskLandPoints(wrfdata);
            end
            
            % loop over all timesteps in given WRF output:
            disp(['...Plotting data from: ' wrf_output_filename])
            
            for t = 1:length(wrfdata.times)
                % plot HORIZONTAL CROSS SECTION OF data:
                % plotHorizontalX(figNumber, wrfdata,timestep, clim,cmap, fieldName, fieldUnits, outputdir, savePlots)
                plotHorizontalX(1, wrfdata,t,[950 1020],othercolor('RdYlBu9'),'PSFC', '[mbar]',verif_plot_dir, savePlots)
                plotHorizontalX(2, wrfdata,t,[283 300],othercolor('Spectral10'),'T2', '[K]',verif_plot_dir, savePlots)
                
                % plot terrain height:
                if t==1
                    plotHorizontalX(3, wrfdata,t,[0,1000],'jet','HGT', '[m]',verif_plot_dir, savePlots)
                end
            end
        end
    end
end
