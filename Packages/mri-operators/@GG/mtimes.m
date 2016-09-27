function output = mtimes(gg,data) 
% This is the actual NUFFT operator
% Data is split in two cases, multi slice or single slice imaging.
% This is for efficient parfor evaluation.

% Set parameters
Kdims=num2cell(gg.Kdims);[ns,nl,nz,nc,ndyn]=deal(Kdims{:});
nx=gg.Rdims(1);ny=gg.Rdims(2);
data=double(data);
eps=gg.precision; 

%% Parallel cpu usage.
if gg.parfor>0
    if gg.adjoint==-1 % NUFFT^(-1)
        % non-Cartesian k-space to Cartesian image domain || type 1
        output=zeros([nx,ny,nz*nc*ndyn]);
        data=reshape(permute(data,[1 2 4 3 5]),[ns,nl,nz*nc*ndyn,1,1]);
        parfor nfft=1:size(data,3)
            cnt=1+floor((nfft-1)/nc);
            output(:,:,nfft)=nufft2d1(gg.nj,reshape(real(gg.k(:,:,cnt)),[gg.nj 1 1]),...
                reshape(imag(gg.k(:,:,cnt)),[gg.nj 1 1]),reshape(data(:,:,nfft),[gg.nj 1 1]),gg.adjoint,eps,nx,ny);
        end
        output=permute(reshape(output,[nx ny nc nz ndyn]),[1 2 4 3 5]);
    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        output=zeros([ns nl nz nc ndyn]);
        data=reshape(permute(data,[1 2 4 3 5]),[nx,ny,nz*nc*ndyn,1,1]);
        for nfft=1:size(data,3)
            cnt=1+floor((nfft-1)/nc);
            output(:,:,nfft)=reshape(nufft2d2(gg.nj,reshape(real(gg.k(:,:,cnt)),[gg.nj 1 1]),...
                reshape(imag(gg.k(:,:,cnt)),[gg.nj 1 1]),gg.adjoint,eps,nx,ny,reshape(data(:,:,nfft),[nx*ny 1 1])),[ns nl]);
        end
        output=permute(reshape(output,[ns nl nc nz ndyn]),[1 2 4 3 5]);
    end
else
    
%% Not parallel
     if gg.adjoint==-1 % NUFFT^(-1)
        % non-Cartesian k-space to Cartesian image domain || type 1
        output=zeros([nx ny nz nc ndyn]);
        for z=1:nz
            for dyn=1:ndyn
                xj=real(gg.k(:,:,z,dyn));
                yj=imag(gg.k(:,:,z,dyn));
                for c=1:nc
                    cj=squeeze(data(:,:,z,c,dyn));
                    output(:,:,z,c,dyn)=nufft2d1(gg.nj,xj(:),yj(:),cj(:),gg.adjoint,eps,nx,ny);
                end
            end
        end
    else % NUFFT
        % Cartesian image domain to non-Cartesian k-space || type 2
        output=zeros([ns nl nz nc ndyn]);
        for z=1:nz
            for dyn=1:ndyn
                xj=real(gg.k(:,:,z,dyn));
                yj=imag(gg.k(:,:,z,dyn));
                for c=1:nc
                    cj=squeeze(data(:,:,z,c,dyn));
                    output(:,:,z,c,dyn)=reshape(nufft2d2(gg.nj,xj(:),yj(:),gg.adjoint,eps,nx,ny,cj),[ns nl]);
                end
            end
        end
    end
end

% END  
end  

