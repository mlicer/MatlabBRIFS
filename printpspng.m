function printpspng(plotname,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function printpspng(plotname,varargin)
%
% Print figure in ps format before converting it to png.
% Syntax: printpspng(plotname)     % By default: Do not create thumbnail and remove .ps file
%         printpspng(plotname,1)   % Create thumbnail and remove .ps file
%         printpspng(plotname,1,0) % Create thumbnail and do not remove .ps file
%         printpspng(plotname,1,1) % Create thumbnail and remove .ps file
%
% Author: Baptiste Mourre - SOCIB
%         bmourre@socib.es
% Date of creation: 06-Oct-2014
% Last modification: 01-June-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------
% SET DEFAULT VALUES
%----------------------
create_thumbnail=0;
remove_ps=1;

[~, user_name] = system('whoami');
switch deblank(user_name)
    case {'baptiste','mlicer'}
        convert_cmd='convert';
    case {'balop','rissaga'}
        convert_cmd='/opt/ImageMagick/bin/convert';
end


%----------------------
% READ ARGUMENTS
%----------------------
if (nargin < 1)
    error('Not enough input arguments!')
elseif (nargin>=2)
    create_thumbnail=varargin{2};
elseif (nargin==3)
    remove_ps=varargin{3};
end

if (strcmp(plotname(end-3:end),'.png')) || (strcmp(plotname(end-3:end),'.eps')) || (strcmp(plotname(end-3:end),'.jpg')) || (strcmp(plotname(end-3:end),'.gif'))
    plotname=plotname(1:end-4)
elseif (strcmp(plotname(end-2:end),'.ps'))
    plotname=plotname(1:end-3)
end

%----------------------
% PRINT .PS FILE
%----------------------
print('-painters','-dpsc','-cmyk','-r300',[plotname '.ps']);

%----------------------
% CONVERT TO .PNG
%----------------------
system([convert_cmd ' -density 300  -units PixelsPerCentimeter -quality 100 -colors 256 -format png ' plotname '.ps ' plotname '.png']);

%----------------------
% CREATE THUMBNAIL
%----------------------
if (create_thumbnail==1)
    system([convert_cmd ' -density 61  -units PixelsPerCentimeter -quality 100 -colors 256 -format png ' plotname '.ps ' plotname '_t.png']);
end

%----------------------
% REMOVE .PS
%----------------------
if (remove_ps==1)
    system(['rm ' plotname '.ps']);
end

end
