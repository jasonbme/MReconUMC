function [res,lsvec] = configure_regularized_iterative_sense(params)

% LSQR settings
ops=optimset('Display','off');

% Function handle for (regularized) lsqr
if isempty(params.TV)
    func=@(x,tr) iterative_sense(x,params,tr);
    s=matrix_to_vec(params.y);
else
    func=@(x,tr) regularized_iterative_sense(x,params,tr);
    s=matrix_to_vec(params.y);
    s=double([s ;zeros(numel(s),1)]);
end

% LSQR
[tmp,~,relres,~,resvec,lsvec]=lsqr(func,s,1E-08,params.N_iter);
res=reshape(tmp,[params.Id(1:3) 1 params.Id(5:12)]);

% END
end