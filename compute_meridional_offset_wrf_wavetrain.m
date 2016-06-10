function alpha=compute_meridional_offset_wrf_wavetrain(lon, lat, Pair)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function compute_meridional_offset_wrf_wavetrain(lon, lat, Pair);
%
%  Compute latitudinal offset of the WRF wave train so that it travels over
%  Menorca channel. Used then to force best fit ROMS  simulations.
%
%  Input arguments:
%     lon: 1D longitude vector
%     lat: 1D latitude vector
%     Pair: 3D matrix (t,y,x) with atmospheric pressure values
%
%  Calls subroutine caleof to compute EOFs.
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Script adapted from IMEDEA-SOCIB 2009-2013 legacy.
% Date of creation: Jun-2015
% Last modification: 12-Jun-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
indx=find(lon>=2.6 & lon<=4.6);
indy=find(lat>=39.2 & lat<=40.3);
LON=lon(indx);
LAT=lat(indy);
[XX YY]=meshgrid(LON, LAT);
xmin_ref=3.3;
ymin_ref=39.8;

xmax_ref=3.85;
ymax_ref=40.;

Pref = polyfit([xmin_ref xmax_ref],[ymin_ref ymax_ref], 1);

sig=Pair(:, indy, indx);
sigd=diff(sig, 1);

[tt m n]=size(sigd);
[EOFs,PC,EXPVAR] = caleof(sigd(:, :),1,2);
essai1=reshape(EOFs(1,:), m,n);

%  max and min to have a linear ext.

[ii iii]=max(essai1(:));
[ii2 iii2]=min(essai1(:));
xmax=XX(iii);
ymax=YY(iii);

xmin=XX(iii2);
ymin=YY(iii2);

P = polyfit([xmin xmax],[ymin ymax], 1);

Pnew(1)=P(1);
Y(1)=P(1)*xmin_ref+P(2);
alpha=ymin_ref-P(2)-P(1)*xmin_ref;
Pnew(2)=P(2)+alpha;

return

