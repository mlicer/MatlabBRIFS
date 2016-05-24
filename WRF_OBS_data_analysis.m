clc; clear

% set parent directory:
matdir = '/home/mlicer/BRIFSverif/plots/WRF/';
dpdtdir = '/home/mlicer/BRIFSverif/plots/WRF/dpdt/';
fftdir = '/home/mlicer/BRIFSverif/plots/WRF/FFT/';

% list matfiles:
matfiles = dir([matdir '*.mat']);

% barometer station key table:
stationNum.ciutadella = 10;
stationNum.sarapita = 13;
stationNum.santantoni = 14;
stationNum.pollensa = 15;
stationNum.lamola = 16;
stationNum.coloniasantpere = 17;
stationNum.andratx = 18;

% loop over rissaga events:
for i = 1:numel(matfiles)
    
    % load matfile with data:
    fname = matfiles(i).name;
    load(fname);
    strdate= datestr(mydate,'yyyymmdd');
    
    % compute WRF pressure time-difference per minute:
    WRF_dt_in_seconds = (time(2)-time(1))*86400;
    dpdt_WRF = 60. * diff(P_stations) / WRF_dt_in_seconds;
    
    % compute OBS pressure time-differences at all stations:
    stations = fieldnames(barometers);
    dpdt_OBS = [];
    
    for s = 1:numel(stations)
        dpdt_OBS.(stations{s})=[];
        if barometers.(stations{s}).dataExists && numel(barometers.(stations{s}).time) > 2
            %% compute WRF pressure time-difference per minute:
            dtime = barometers.(stations{s}).('time');
            
            % timestep is different for different stations so we do it
            % for every station separately:
            OBS_dt_in_seconds = (dtime(2)-dtime(1))*86400.;
            dtime = dtime(1:end-1);
            dpdt_OBS.(stations{s}).time=dtime;
            % finally the measures dpdt is:
            dpdt_OBS.(stations{s}).dpdt= 60 * diff(barometers.(stations{s}).('AIR_PRE')) / OBS_dt_in_seconds;
            
            %% perform Fourier analysis:
            
            fft_WRF.(stations{s}) = fft_h(P_stations(:,stationNum.(stations{s})));
            fft_OBS.(stations{s}) = fft_h(naninterp(barometers.(stations{s}).('AIR_PRE')));
            
            %% plot results
            fntsize=20;
            figure(1);clf
            plot(dpdt_OBS.(stations{s}).time,dpdt_OBS.(stations{s}).dpdt,'r',...
                time(1:end-1),dpdt_WRF(:,stationNum.(stations{s})),'b')
            title(['(dp/dt) [hPa/min] at ' upper(stations{s}) ' : ' datestr(mydate,'yyyy mm dd')]...
                ,'fontsize', fntsize)
            xlim([time(1),time(end)])
            %             title(['WRF (blue) vs OBS (red): ' datestr(mydate,'yyyy mm dd')])
            set(gca, 'fontsize', fntsize)
            set(gca,'XTick',(min(time(tt_48h)):0.25:max(time(tt_48h))));
            set(gca,'XTickLabel',{datestr(min(time(tt_48h)),'dd-mmm'),'','','',datestr(min(time(tt_48h)+1),'dd-mmm'),'','','',datestr(min(time(tt_48h)+2),'dd-mmm')});
            ylabel('(dp/dt) [hPa/minute]','fontsize', fntsize)
            xlabel('Date','fontsize', fntsize)            
            legend('OBS','WRF','location','southeast')
            grid on
            box on
            pngname=[dpdtdir 'dpdt_' stations{s} '_' datestr(mydate,'yyyymmdd')];
            print(pngname,'-dpng','-r300')
%             print(strrep(pngname,'.png','.eps'),'-depsc','-r300')
            
            figure(2);clf
            semilogy( fft_OBS.(stations{s}).period,fft_OBS.(stations{s}).power,'r',fft_WRF.(stations{s}).period,fft_WRF.(stations{s}).power,'b')
            xmin = 0;
            xmax = 20;
            ymin=0;
            ymax=2000;
            xlim([xmin,xmax])
            ylim([ymin,ymax])
            xlabel('FFT period [minutes]','fontsize', fntsize)
            ylabel('FFT power density [|hPa|^2]','fontsize', fntsize)
            
            legend('OBS','WRF','Location','southeast')
            title(['MSLP signal FFT at ' upper(stations{s}) ' : ' datestr(mydate,'yyyy mm dd')]...
                ,'fontsize', fntsize)
            set(gca, 'fontsize', fntsize)
            
            grid on
            box on
            pngname=[fftdir 'pFFT_' stations{s} '_' datestr(mydate,'yyyymmdd')];
            print(pngname,'-dpng','-r300')
%             print(strrep(pngname,'.png','.eps'),'-depsc','-r300')
            
            
            % reproduce P1-P18 plots as well:
            plotPgraphs(strdate,mydate,tt_48h,time,Name_simple,Name,P_stations,barometers,steel,im,matdir)
            
        end
    end
end
