function make_intTemp_plot(XXX,T)
    figure;
    pathName=pwd;
    zz=fullfile(pathName,'intTemp_plot.png');
    for gg=1:length(XXX)
%         vv=T(:,:,gg);
%         vv=vv(vv>5);
%         intTemp(gg)=sum(vv(:));
        zu=T(54:74,54:74,gg);
        intTemp(gg)=sum(zu(:));
    end
    plot(XXX,squeeze(intTemp));
    title('$\mathit{Integral \, Temperature}$','Interpreter','Latex')
    xlabel('$\mathit{time,\,s}$','Interpreter','Latex')
    ylabel('$\mathit{^{\circ} C.mm^{2}}$','Interpreter','Latex') 
    grid on;
    grid minor;
    hold off;
    saveas(gcf,zz)
end