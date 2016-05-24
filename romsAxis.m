clear hx hy
    daystring = 'ddmmm';
    hourstring='HH:MM'  
if exist(filename_child)
%     clear hx hy xdatestrings

    set(gca, 'xtick', [time_child(1):1/8:time_child(end)])
    xdatestrings={datestr(time_child(1),daystring),'','','',...
        datestr(time_child(1)+0.5,hourstring),'','','',...
        datestr(time_child(1)+1,daystring),'','','',...
        datestr(time_child(1)+1.5,hourstring),'','','',...
        datestr(time_child(1)+2,daystring)};
    set(gca,'xticklabels',xdatestrings)
xlim([time_child(1) time_child(end)])

else
    clear hx hy
    set(gca, 'xtick', [time_parent(1):1/8:time_parent(end)])
  
    xdatestrings={datestr(time_parent(1),daystring),'','','',...
        datestr(time_parent(1)+0.5,hourstring),'','','',...
        datestr(time_parent(1)+1,daystring),'','','',...
        datestr(time_parent(1)+1.5,hourstring),'','','',...
        datestr(time_parent(1)+2,daystring)};
    set(gca,'xticklabels',xdatestrings)
xlim([time_parent(1) time_parent(end)])

end
zmin = -1.3;
zmax = -zmin;
set(gca, 'ytick', zmin:0.25:zmax)
set(gca, 'fontsize', 12)
set(gca, 'xminorgrid', 'on')
set(gca,'GridLineStyle','-')
set(gca,'MinorGridLineStyle',':')
title(['HF SSH ' stationName ': ' datestr(time_parent(1),'yyyymmdd')])
ylim([zmin zmax])
ylabel('HF elevation [m]')
grid on
box on