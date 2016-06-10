function create_BRIFS_ROMS_child_bry(strdate,filename_roms_parent,romschildgridfile,VertGridParam,output_bry_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function create_BRIFS_ROMS_child_bry(strdate,filename_roms_parent,romschildgridfile,VertGridParam,output_bry_file)
%
%  Create boundary files for ROMS child model from ROMS parent model.
%
%  Input arguments:
%     strdate: YYYYMMDD
%     filename_roms_parent: ROMS parent filename 
%     romschildgridfile: ROMS child model grid file
%     VertGridParam: [Theta_s Theta_b Tcline Ns Vtransform Vstretching] for the child model
%     output_bry_file: child model boundary filename
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Date of creation: Jun-2015
% Last modification: 12-Jun-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mydate=datenum(strdate,'yyyymmdd');

if ~exist(filename_roms_parent)
    disp(['  ERROR: File ' filename_roms_parent ' not found']);
    return
end


% Read grid, providing sigma coordinate parameters
romsGrid_parent = roms_get_grid(filename_roms_parent,filename_roms_parent);
romsGrid_child = roms_get_grid(romschildgridfile, VertGridParam);

display('   Read child model grid ...')
lon_child=romsGrid_child.lon_rho(:,:);
lat_child=romsGrid_child.lat_rho(:,:);
lon_u_child=romsGrid_child.lon_u(:,:);
lat_u_child=romsGrid_child.lat_u(:,:);
lon_v_child=romsGrid_child.lon_v(:,:);
lat_v_child=romsGrid_child.lat_v(:,:);

lon_parent=romsGrid_parent.lon_rho(:,:);
lat_parent=romsGrid_parent.lat_rho(:,:);
lon_u_parent=romsGrid_parent.lon_u(:,:);
lat_u_parent=romsGrid_parent.lat_u(:,:);
lon_v_parent=romsGrid_parent.lon_v(:,:);
lat_v_parent=romsGrid_parent.lat_v(:,:);

[ny nx]=size(lon_child);
[nyu nxu]=size(lon_u_child);
[nyv nxv]=size(lon_v_child);


display('   Read parent model outputs ...')
time=nc_varget(filename_roms_parent,'ocean_time')/(3600*24);
nt=length(time);
zeta_parent=nc_varget(filename_roms_parent,'zeta');
ubar_parent=nc_varget(filename_roms_parent,'ubar');
vbar_parent=nc_varget(filename_roms_parent,'vbar');

zeta_parent(zeta_parent>1000)=0;
ubar_parent(ubar_parent>1000)=0;
vbar_parent(vbar_parent>1000)=0;

zeta_child_east=zeros(nt,ny);
ubar_child_east=zeros(nt,nyu);
vbar_child_east=zeros(nt,nyv);
zeta_child_west=zeros(nt,ny);
ubar_child_west=zeros(nt,nyu);
vbar_child_west=zeros(nt,nyv);
zeta_child_north=zeros(nt,nx);
ubar_child_north=zeros(nt,nxu);
vbar_child_north=zeros(nt,nxv);
zeta_child_south=zeros(nt,nx);
ubar_child_south=zeros(nt,nxu);
vbar_child_south=zeros(nt,nxv);

display('   Interpolate ...')

indlon=find(lon_parent(1,:)>=min(lon_child(:)) & lon_parent(1,:)<=max(lon_child(:)));
indlat=find(lat_parent(:,1)>=min(lat_child(:)) & lat_parent(:,1)<=max(lat_child(:)));
indlon=[(indlon(1)-3:indlon(1)-1) indlon (indlon(end)+1:indlon(end)+3)];
indlat=[(indlat(1)-3:indlat(1)-1)';indlat;(indlat(end)+1:indlat(end)+3)'];

for kt=1:nt
    if mod(kt,100)==0   disp(['    kt=' num2str(kt) ' over ' num2str(nt)]);  end
    
    zeta_child_east(kt,:)=interp2(lon_parent(1,indlon),lat_parent(indlat,1),squeeze(zeta_parent(kt,indlat,indlon)),lon_child(:,end),lat_child(:,end));
    ubar_child_east(kt,:)=interp2(lon_u_parent(1,indlon),lat_u_parent(indlat,1),squeeze(ubar_parent(kt,indlat,indlon)),lon_u_child(:,end),lat_u_child(:,end));
    vbar_child_east(kt,:)=interp2(lon_v_parent(1,indlon),lat_v_parent(indlat,1),squeeze(vbar_parent(kt,indlat,indlon)),lon_v_child(:,end),lat_v_child(:,end));
    
    zeta_child_west(kt,:)=interp2(lon_parent(1,indlon),lat_parent(indlat,1),squeeze(zeta_parent(kt,indlat,indlon)),lon_child(:,1),lat_child(:,1));
    ubar_child_west(kt,:)=interp2(lon_u_parent(1,indlon),lat_u_parent(indlat,1),squeeze(ubar_parent(kt,indlat,indlon)),lon_u_child(:,1),lat_u_child(:,1));
    vbar_child_west(kt,:)=interp2(lon_v_parent(1,indlon),lat_v_parent(indlat,1),squeeze(vbar_parent(kt,indlat,indlon)),lon_v_child(:,1),lat_v_child(:,1));
    
    zeta_child_north(kt,:)=interp2(lon_parent(1,indlon),lat_parent(indlat,1),squeeze(zeta_parent(kt,indlat,indlon)),lon_child(end,:),lat_child(end,:));
    ubar_child_north(kt,:)=interp2(lon_u_parent(1,indlon),lat_u_parent(indlat,1),squeeze(ubar_parent(kt,indlat,indlon)),lon_u_child(end,:),lat_u_child(end,:));
    vbar_child_north(kt,:)=interp2(lon_v_parent(1,indlon),lat_v_parent(indlat,1),squeeze(vbar_parent(kt,indlat,indlon)),lon_v_child(end,:),lat_v_child(end,:));
    
    zeta_child_south(kt,:)=interp2(lon_parent(1,indlon),lat_parent(indlat,1),squeeze(zeta_parent(kt,indlat,indlon)),lon_child(1,:),lat_child(1,:));
    ubar_child_south(kt,:)=interp2(lon_u_parent(1,indlon),lat_u_parent(indlat,1),squeeze(ubar_parent(kt,indlat,indlon)),lon_u_child(1,:),lat_u_child(1,:));
    vbar_child_south(kt,:)=interp2(lon_v_parent(1,indlon),lat_v_parent(indlat,1),squeeze(vbar_parent(kt,indlat,indlon)),lon_v_child(1,:),lat_v_child(1,:));
end

% Fill NaN value
for kb=1:12
    switch kb
        case 1
            myvar='zeta_child_east';
        case 2
            myvar='zeta_child_west';
        case 3
            myvar='zeta_child_south';
        case 4
            myvar='zeta_child_north';
        case 5
            myvar='ubar_child_east';
        case 6
            myvar='ubar_child_west';
        case 7
            myvar='ubar_child_south';
        case 8
            myvar='ubar_child_north';
        case 9
            myvar='vbar_child_east';
        case 10
            myvar='vbar_child_west';
        case 11
            myvar='vbar_child_south';
        case 12
            myvar='vbar_child_north';
    end
    
    eval(['data=' myvar ';']);
    indok=find(~isnan(data(1,:)));
    if length(indok)>0 & length(indok)<length(data(1,:))
        for kt=1:nt
            if indok(1)>1; data(kt,indok(1)-1:indok(1))=data(kt,indok(1)); end
            if indok(end)<length(data(1,:)); data(kt,indok(end)+1:end)=data(kt,indok(end)); end
        end
    else
        data(:,:)=0;
    end
eval([myvar '_filled=data;']);

end

%----------------------
% CREATE OUTPUT FILE
%----------------------
f = netcdf(output_bry_file, 'clobber');

if isempty(f)
    disp(' ROMS bry file not created.')
    return
end

% define global arguments
f.title=['BRIFS ROMS child boundary file generated from ROMS parent model'];
f.grid = romschildgridfile;
f.input=filename_roms_parent;
f.author = 'bmourre@socib.es';
f.date = datestr(now);

% define dimensions
f('xi_rho')      = nx ;
f('eta_rho')     = ny;
f('xi_u')        = nxu ;
f('eta_u')       = nyu  ;
f('xi_v')        = nxv ;
f('eta_v')       = nyv  ;
f('s_rho')       = VertGridParam(4) ;
f('time')        = nt ;

% define independent variables
f{'time'}                 = ncdouble('time');
f{'time'}.units           = 'days since 1968-05-23';
f{'time'}.longname        = 'open boundary conditions time';

f{'time'} = ncdouble('time');
f{'time'}.long_name = ncchar('time');
f{'time'}.units = ncchar('day');
f{'time'}.field = ncchar('temp_time, scalar, series');
%f{'time'}.missing_value = ncdouble(missing_value);

% set fill values

% define dependent variables
f{'zeta_east'}                = ncfloat('time','eta_rho');
f{'zeta_east'}.longname       = 'free-surface eastern boundary condition';
f{'zeta_east'}.units          = ' m ';
f{'zeta_east'}.time           = ncchar('time');

f{'ubar_east'}                = ncfloat('time','eta_u');
f{'ubar_east'}.longname       = '2D u-momentum eastern boundary condition';
f{'ubar_east'}.units          = 'm/s';
f{'ubar_east'}.time           = ncchar('time');

f{'vbar_east'}                = ncfloat('time','eta_v');
f{'vbar_east'}.longname       = '2D v-momentum eastern boundary condition';
f{'vbar_east'}.units          = 'm/s';
f{'vbar_east'}.time           = ncchar('time');

f{'zeta_north'}                = ncfloat('time','xi_rho');
f{'zeta_north'}.longname       = 'free-surface northern boundary condition';
f{'zeta_north'}.units          = ' m ';
f{'zeta_north'}.time           = ncchar('time');

f{'ubar_north'}                = ncfloat('time','xi_u');
f{'ubar_north'}.longname       = '2D u-momentum northern boundary condition';
f{'ubar_north'}.units          = 'm/s';
f{'ubar_north'}.time           = ncchar('time');

f{'vbar_north'}                = ncfloat('time','xi_v');
f{'vbar_north'}.longname       = '2D v-momentum northern boundary condition';
f{'vbar_north'}.units          = 'm/s';
f{'vbar_north'}.time           = ncchar('time');

f{'zeta_west'}                = ncfloat('time','eta_rho');
f{'zeta_west'}.longname       = 'free-surface western boundary condition';
f{'zeta_west'}.units          = ' m ';
f{'zeta_west'}.time           = ncchar('time');

f{'ubar_west'}                = ncfloat('time','eta_u');
f{'ubar_west'}.longname       = '2D u-momentum western boundary condition';
f{'ubar_west'}.units          = 'm/s';
f{'ubar_west'}.time           = ncchar('time');

f{'vbar_west'}                = ncfloat('time','eta_v');
f{'vbar_west'}.longname       = '2D v-momentum western boundary condition';
f{'vbar_west'}.units          = 'm/s';
f{'vbar_west'}.time           = ncchar('time');

f{'zeta_south'}                = ncfloat('time','xi_rho');
f{'zeta_south'}.longname       = 'free-surface southern boundary condition';
f{'zeta_south'}.units          = ' m ';
f{'zeta_south'}.time           = ncchar('time');

f{'ubar_south'}                = ncfloat('time','xi_u');
f{'ubar_south'}.longname       = '2D u-momentum southern boundary condition';
f{'ubar_south'}.units          = 'm/s';
f{'ubar_south'}.time           = ncchar('time');

f{'vbar_south'}                = ncfloat('time','xi_v');
f{'vbar_south'}.longname       = '2D v-momentum southern boundary condition';
f{'vbar_south'}.units          = 'm/s';
f{'vbar_south'}.time           = ncchar('time');

% Fill variables
f{'time'}(:)          =time;

f{'zeta_east'}(:,:)   =zeta_child_east_filled;
f{'ubar_east'}(:,:)   =ubar_child_east_filled;
f{'vbar_east'}(:,:)   =vbar_child_east_filled;

f{'zeta_north'}(:,:)  =zeta_child_north_filled;
f{'ubar_north'}(:,:)  =ubar_child_north_filled;
f{'vbar_north'}(:,:)  =vbar_child_north_filled;

f{'zeta_west'}(:,:)   =zeta_child_west_filled;
f{'ubar_west'}(:,:)   =ubar_child_west_filled;
f{'vbar_west'}(:,:)   =vbar_child_west_filled;

f{'zeta_south'}(:,:)  =zeta_child_south_filled;
f{'ubar_south'}(:,:)  =ubar_child_south_filled;
f{'vbar_south'}(:,:)  =vbar_child_south_filled;

%----------------------
% CLOSE NETCDF
%----------------------
close(f)
   
   
return




