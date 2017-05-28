function res = configure_regularized_iterative_sense(kdata,params)

% LSQR settings
ops=optimset('Display','off');

% Function handle for lsqr
func=@(x,tr) reg_itSense_Joint_2D(x,params,tr);

% Prepare input for regularized LSQR
s=matrix_to_vec(kdata);
s=double([s ;zeros(numel(s),1)]);

% Start progress monitoring
parfor_progress(params.N_iter);

% LSQR
[tmp,~,relres,~,resvec,lsvec]=lsqr(func,s,1E-08,params.N_iter);
res=reshape(tmp,[params.Id(1:3) 1 params.Id(5:12)]);

% Save residual
params.Residual=[params.resvec resvec];

% Reset progress script
parfor_progress(0);

% END
end