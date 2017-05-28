function res = configure_regularized_iterative_sense(params)

% LSQR settings
ops=optimset('Display','off');

% Function handle for lsqr
func=@(x,tr) reguralized_iterative_sense(x,params,tr);

% Prepare input for regularized LSQR
s=matrix_to_vec(params.y);
s=double([s ;zeros(numel(s),1)]);

% Start progress monitoring
parfor_progress(params.N_iter);

% LSQR
[tmp,~,relres,~,resvec,lsvec]=lsqr(func,s,1E-08,params.N_iter);
res=reshape(tmp,[params.Id(1:3) 1 params.Id(5:12)]);

% Reset progress script
parfor_progress(0);

% END
end