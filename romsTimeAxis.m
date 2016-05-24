if exist(filename_child)
    set(gca, 'xtick', [time_child(1):1/8:time_child(end)])
    set(gca,'XTickLabel',{datestr(time_child(1),'ddmmm'),'','','',...
        datestr(time_child(1)+0.5,'ddmmm'),'','','',...
        datestr(time_child(1)+1,'ddmmm'),'','','',...
        datestr(time_child(1)+1.5,'ddmmm'),'','','',...
        datestr(time_child(1)+2,'ddmmm')});
else
  set(gca, 'xtick', [time_parent(1):1/8:time_parent(end)])
    set(gca,'XTickLabel',{datestr(time_parent(1),'ddmmm'),'','','',...
        datestr(time_parent(1)+0.5,'ddmmm'),'','','',...
        datestr(time_parent(1)+1,'ddmmm'),'','','',...
        datestr(time_parent(1)+1.5,'ddmmm'),'','','',...
        datestr(time_parent(1)+2,'ddmmm')});  
end
xlim([time_parent(1),time_parent(end)])
legend('ROMS','location','southwest')
set(gca, 'fontsize', 12)
title(['SSH ' stationName ': ' datestr(time_parent(1),'yyyymmdd')])
ylabel('HF elevation [m]')