function make_convolution_video(T,dt)
    opengl hardware
    [xx yy tt]=size(T);
    figure;
    pathName=pwd;
    zz=fullfile(pathName,'gaussianConvolution_Tin.avi');
    writerObj = VideoWriter(zz);
    writerObj.FrameRate=3;
    open(writerObj);
    vmin=0;
    vmax=max(T,[],'all');
    hold on
    for e=1:tt
%         subplot(2,1,1)
        h = pcolor(T(:,:,e));
        set(h, 'EdgeColor', 'none');
        hc=colorbar; 
        title(hc,'T,°C');
        caxis([vmin vmax]); 
        title({'Temperature, °C',[num2str(e), ' sec']});
%         hold on
%         subplot(2,1,2)
%         title('Focal Spot Zoom');
%         h2 = pcolor(T(54:74,54:74,e));
%         set(h2, 'EdgeColor', 'none');
%         hc=colorbar; 
%         title(hc,'T,°C');
%         caxis([vmin vmax]); 
        drawnow;
        F = getframe(gcf);
        writeVideo(writerObj,F);
        fprintf("%i\n",e)
        hold off;
    end
    close(writerObj);
end

