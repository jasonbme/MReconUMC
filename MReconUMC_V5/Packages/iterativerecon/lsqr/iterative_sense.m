function res = iterative_sense(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined  
    
    % Vector to matrix
    x=vec_to_matrix(x,params.Kd);

    % Data fidelity part 
    res=params.N'*(params.W*x);

    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Matrix to vector
    res=matrix_to_vec(res{1});
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    
    % Vector to matrix
    x=vec_to_matrix(x,[params.Id(1:3) 1 params.Id(5:12)]);
    
    % S operator
    x=params.S'*x;
    
    % Data fidelity part
    res=params.W*(params.N*x);
    
    % Vectorize
    res=matrix_to_vec(res{1});    
    
end

% END
end
