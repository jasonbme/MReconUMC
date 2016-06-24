function  res = GG(k,Rdims,Kdims)
% NUFFT operator
res.adjoint=1; % Inverse FFT
res.k=k*2*pi;
res.precision=1e-03; 
res.nj=numel(k(:,:,1));
res.Rdims=round(Rdims);
res.Kdims=Kdims;
res=class(res,'GG');

%END
end