function [res,resvec] = config_reg_itSense_Joint_2D(kdata,IR)

% LSQR settings
ops=optimset('Display','off');

% Function handle for lsqr
func=@(x,tr) reg_itSense_Joint_2D(x,IR,tr);

% Prepare input for regularized LSQR
s=matrix_to_vec(kdata);
s=double([s ;zeros(prod(IR.TVdim),1)]);

% Start progress monitoring
parfor_progress(IR.Niter);

% LSQR
[tmp,~,relres,~,resvec,lsvec]=lsqr(func,s,1E-08,IR.Niter);
res=reshape(tmp,[IR.Idim(1:3) 1 IR.Idim(5)]);

% Reset progress script
parfor_progress(0);

% END
end