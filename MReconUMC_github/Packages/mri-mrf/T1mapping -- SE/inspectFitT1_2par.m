function inspectFitT1_2par(T1map,Amap,IM,ITlist)
% Function to inspect the fit from the T1 map.
    figure(5)
    imagesc(T1map);colormap('gray')
    t=0:0.01:ITlist(end)+500;
for j=1:100
    figure(5)
    [x,y]=ginput(1);
    x=round(x);
    y=round(y);
    figure(7);

    ygraph=Amap(y,x)*(1-2*exp(-t/T1map(y,x)));
    if (max(abs(IM(y,x,:)))>max(abs(ygraph)))
        maxval=max(abs(IM(y,x,:)));
    else
        maxval=max(abs(ygraph));
    end
    ygraph=ygraph/maxval;
    IM(y,x,:)=IM(y,x,:)/maxval;
    scatter(ITlist,IM(y,x,:),'k');
    hold on
    plot(t,ygraph);
    hold off
    %% Part to make a good T1 plot
    hTitle  = title ('IR-SE T1 mapping','fontweight','bold','FontSize',14,'FontName', 'AvantGarde');
    hXLabel = xlabel('Inversion time [ms]','FontSize',14,'FontName', 'AvantGarde');
    hYLabel = ylabel('Intensity [-]','FontSize',14,'FontName', 'AvantGarde');
    set(gca,'fontsize',14)
    axis([0 2500 -1 1])
    box off
    set(gca, ...
    'Box'         , 'off'     , ...
    'YGrid'       , 'on'      , ...
    'YTick'       , -1:0.5:1, ...
    'TickDir'     , 'out'   );
end
end
