function [res,lsvec] = configure_regularized_iterative_sense(params)

% LSQR settings
ops=optimset('Display','off');

% Function handle for (regularized) lsqr
if isempty(params.TV)
    func=@(x,tr) tikhonov_iterative_sense(x,params,tr);
    s=matrix_to_vec(params.y);
    s=double([s ;zeros(prod(params.Id([1 2 3 5 6 7 8 9 10 11 12])),1)]);
else
    func=@(x,tr) regularized_iterative_sense(x,params,tr);
    s=matrix_to_vec(params.y);
    s=double([s ;zeros(prod(params.Id([1 2 3 5 6 7 8 9 10 11 12])),1)]);
end

% LSQR
[tmp,~,relres,~,resvec,lsvec]=lsqr(func,s,1E-08,params.N_iter);
res=reshape(tmp,[params.Id(1:3) 1 params.Id(5:12)]);

% Append resvec if it converges reached prior to N_iter
if size(lsvec,1)<params.N_iter;lsvec(end+1:params.N_iter)=0;end

% END
end