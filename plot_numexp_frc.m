plotstep=30;    
for t = 1:plotstep:ntimes
        
        try
            delete(h1)
            delete(h2)
        catch
        end
        
        h1=surf(lons2,lats2,pressureWave(:,:,t));shading flat
        set(gca,'layer','bottom')        
        
        title(['Artificial pressure wave forcing for ROMS on date: ' datestr(dates(t),'yyyy mmm dd HH:MM')])
        colorbar
        colormap(othercolor('BuDRd12'))
        caxis([-pressureWaveAmplitude pressureWaveAmplitude])
        xlim([lonmin lonmax])
        ylim([latmin latmax])
        
        % set aspect:
        pbaspect([diff([lonmin lonmax]) diff([latmin latmax]) 1])
        


        
        grid on
        box on
        %         scatter(lonCIUTADELLA,latPoint,20,'filled')
        %         latPoint = latPoint + (cg * timestep/RE)*180/pi
%         set(gca,'layer','top')
        % add coastline:
        width=0.75;
        h2 = geoshow([S.Lat], [S.Lon],'Color','black','LineWidth',width);
        set(gca,'layer','top')        
        
        pause(0.001)
        pngname = ['ciutadella_p-wave_theta_' num2str(theta) '_frame_' datestr(dates(t),'yyyymmmddHHMM') '.png'];
        print(gcf,pngname,'-dpng','-r72')
end