function res = reg_itSense_Joint_2D(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined
    
    % Get image dimensions
    dims=num2cell(params.Idim);[nx,ny,nz,nc,ndyn]=deal(dims{:});
    
    % Vector to matrix
    x1=vec_to_matrix(x(1:prod(params.Kdim)),params.Kdim);
    x2=x(prod(params.Kdim)+1:end);

    % Data fidelity part 
    res=params.N'*(params.W*x1);
    
    % Total variation part
    if params.TVflag==0
        D=params.TV'*x2;
    else
        D=abs(params.TV'*(real(x2)))+abs(params.TV1'*(real(x2)));
    end

    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Visualization
    if strcmpi(params.Visualization,'yes')
        vis=reshape(D,[params.Idim(1:3) 1 params.Idim(5)]);
        close all;h=figure;set(h,'units','normalized','outerposition',[0 0 1 1]);
        subplot(221);imshow(abs(res(:,:,round(end/2),:,1)),[]);colorbar
        subplot(222);imshow(vis(:,:,round(end/2),:,1),[]);colorbar
    end
    
    % Matrix to vector
    res=matrix_to_vec(res)+params.lambda*complex(D);
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    % Get kspace dimensions
    dims=num2cell(params.Kdim);[ns,nl,nz,nc,ndyn]=deal(dims{:});
    
    % Total variation part
    if params.TVflag==0
        D=params.TV*matrix_to_vec(x);
    else
        D=abs(params.TV*matrix_to_vec(real(x)))+abs(params.TV1*matrix_to_vec((real(x))));
    end

    % Vector to matrix
    x=vec_to_matrix(x,[params.Idim(1:3) 1 params.Idim(5)]);
    
    % Visualization
    if strcmpi(params.Visualization,'yes')
        vis=reshape(D,[params.Idim(1:3) 1 params.Idim(5)]);
        subplot(223);imshow(abs(x(:,:,round(end/2),:,1)),[]);colorbar
        subplot(224);imshow(vis(:,:,round(end/2),:,1),[]);colorbar;pause();
    end
    
    % S operator
    x=params.S'*x;
    
    % Data fidelity part
    res=params.W*(params.N*x);
    
    % Vectorize
    res=[matrix_to_vec(res);  params.lambda*complex(D)];    
    
    % Deal with progress bar
    parfor_progress;
end

% END
end