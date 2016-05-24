function y_hf = removeROMSLowFrequencies(y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function y_hf = removeROMSLowFrequencies(y)
%
%  Removes low-frequency signal from ROMS point-value timeseries y, using a zero-phase
%  4th order Butterworth filter.
%
%  Input arguments:
%     y: timeseries of a variable from a gridpoint in ROMS
%
%  Output:
%     y_hf: high pass filtered timeseries
%
%   cutOffPeriodInNormalizedUnits is cutOff period in minutes.
%
% Author: Matjaz Licer - NIB MBS @SOCIB
%         matjaz.licer@mbss.org
% Date of creation: May-2015
% Last modification: 18-Apr-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off;

% design 4th order Butterworth filter:
filterOrder=4;
cutOffPeriodInNormalizedUnits=200;
cutOffFrequency = 1/(cutOffPeriodInNormalizedUnits/2);
h=fdesign.highpass('N,F3dB',filterOrder,cutOffFrequency);
d1 = design(h,'butter');

% perform filtering:
y_hf = filtfilt(d1.sosMatrix,d1.ScaleValues,...
    naninterp(y));



