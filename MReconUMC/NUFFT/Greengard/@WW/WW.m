function  res = WW(w)
% DCF operator
res.adjoint=1; % 1 = normal DCF, -1 is inverse DCF
res.w=w;
res=class(res,'WW');

%END
end