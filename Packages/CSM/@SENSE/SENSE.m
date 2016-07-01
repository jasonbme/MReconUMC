function  res = SENSE(csm)
% S operator
res.S=csm;
res.adjoint=1; % 1=S, -1=S^-1
res=class(res,'SENSE');

%END
end