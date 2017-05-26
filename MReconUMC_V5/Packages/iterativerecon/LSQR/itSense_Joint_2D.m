function res = itSense_Joint_2D(x,params,transp_flag)

% Forward and backward operations
if strcmp(transp_flag,'transp') % Nonuniform k-space uncombined --> uniform image space combined
    
    % Get image dimensions
    dims=num2cell(params.Idim);[nx,ny,nz,nc,ndyn]=deal(dims{:});
    
    % Vector to matrix
    x=vec_to_matrix(x,params.Kdim);
    
    % Data fidelity part 
    res=params.N'*(params.W*x);
    
    % Coil sensitivity maps operator
    res=params.S*res;
    
    % Visualization
    if strcmpi(params.Visualization,'yes')
        close all;h=figure;set(h,'units','normalized','outerposition',[0 0 1 1]);
        subplot(121);imshow(abs(res(:,:,round(end/2),:,1)),[]);colorbar
    end
    
    % Vectorize
    res=[matrix_to_vec(res)];
    
    
elseif strcmp(transp_flag,'notransp') % uniform image combined --> nonuniform k-space uncombined
    % Get kspace dimensions
    dims=num2cell(params.Kdim);[ns,nl,nz,nc,ndyn]=deal(dims{:});
    
    % Vector to matrix
    x=vec_to_matrix(x,[params.Idim(1:3) 1 ndyn]);
    
    % Visualization
    if strcmpi(params.Visualization,'yes')
        subplot(122);imshow(abs(x(:,:,round(end/2),:,1)),[]);colorbar;pause();
    end
    
    % S operator
    x=params.S'*x;
    
    % Data fidelity part
    res=params.W*(params.N*x);
    
    % Vectorize
    res=[matrix_to_vec(res)];
    
    % Deal with progress bar
    parfor_progress;
end

% END
end