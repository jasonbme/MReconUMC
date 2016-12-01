function inspectFitT2(T2map,Amap,IM,ETlist)
% Function to inspect the fit from the T2 map.
    figure(6)
    imagesc(T2map);colormap('hot')
    t=0:0.01:ETlist(end)+100;
for j=1:100
    figure(6)
    [x,y]=ginput(1);
    x=round(x);
    y=round(y);
    yg=Amap(y,x)*exp(-t/T2map(y,x));
    if (max(yg)>max(IM(y,x,:)))
        maxval=max(yg);
    else
        maxval=max(IM(y,x,:));
    end
    yg=yg/maxval;
    IM(y,x,:)=IM(y,x,:)/maxval;
    figure(8);
    scatter(ETlist,IM(y,x,:),'k');
    hold on
    plot(t,yg);
    hold off
     %% Part to make a good T1 plot
    hTitle  = title ('multi-SE T2 mapping','fontweight','bold','FontSize',14,'FontName', 'AvantGarde');
    hXLabel = xlabel('Echo time [ms]','FontSize',14,'FontName', 'AvantGarde');
    hYLabel = ylabel('Intensity [-]','FontSize',14,'FontName', 'AvantGarde');
    set(gca,'fontsize',14)
    axis([0 500 0 1])
    box off
    set(gca, ...
    'Box'         , 'off'     , ...
    'YGrid'       , 'on'      , ...
    'YTick'       , 0:0.25:1, ...
    'TickDir'     , 'out'   );
end
end
