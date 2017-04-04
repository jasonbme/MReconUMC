function [res,resvec] = config_itSense_Joint_2D(kdata,IR)

% LSQR settings
ops=optimset('Display','off');

% Function handle for lsqr
func=@(x,tr) itSense_Joint_2D(x,IR,tr);

% Start progress monitoring
parfor_progress(IR.Niter);

% LSQR
[tmp,~,~,~,~,resvec]=lsqr(func,matrix_to_vec(kdata),1E-08,IR.Niter);
res=reshape(tmp,[IR.Idim(1:3) 1 IR.Idim(5)]);

% Reset progress script
parfor_progress(0);

% END
end