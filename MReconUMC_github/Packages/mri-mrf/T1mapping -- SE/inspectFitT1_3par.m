function inspectFitT1_3par(T1map,Amap,Cmap,IM,ITlist)
% Function to inspect the fit from the T1 map.
    figure(5)
    imagesc(T1map);colormap('gray')
    t=0:0.01:ITlist(end);
for j=1:100
    figure(5)
    [x,y]=ginput(1);
    x=round(x);
    y=round(y);
    figure(7);
    scatter(ITlist,IM(y,x,:),'k');
    y=Cmap(y,x)+Amap(y,x)*exp(-t/T1map(y,x));
    hold on
    plot(t,y);
    hold off
end
end
