function res = regularized_iterative_sense(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined  
    
    % Vector to matrix
    x1=vec_to_matrix(x(1:prod(params.Kd)),params.Kd);
    x2=x(prod(params.Kd)+1:end);

    % Data fidelity part 
    res=params.N'*(params.W*x1);
    
    % Total variation part
    D=params.TV'*x2;

    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Visualization
    if params.Verbose
        vis=reshape(D,[params.Id(1:3) 1 params.Id(5:12)]);
        h=figure(5);set(h,'units','normalized','outerposition',[0 0 1 1]);
        subplot(221);imshow(abs(res(:,:,round(end/2),:,1)),[]);colorbar
        subplot(222);imshow(vis(:,:,round(end/2),:,1),[]);colorbar
    end
    
    % Matrix to vector
    res=matrix_to_vec(res)+params.Lambda*complex(D);
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    % Get kspace dimensions
    dims=num2cell(params.Kd);
    
    % Total variation part
    D=params.TV*matrix_to_vec(x);

    % Vector to matrix
    x=vec_to_matrix(x,[params.Id(1:3) 1 params.Id(5:12)]);
    
    % Visualization
    if params.Verbose
        vis=reshape(D,[params.Id(1:3) 1 params.Id(5:12)]);
        subplot(223);imshow(abs(x(:,:,round(end/2),:,1)),[]);colorbar
        subplot(224);imshow(vis(:,:,round(end/2),:,1),[]);colorbar;pause();
    end
    
    % S operator
    x=params.S'*x;
    
    % Data fidelity part
    res=params.W*(params.N*x);
    
    % Vectorize
    res=[matrix_to_vec(res);  params.lambda*complex(D)];    
   
end

% END
end