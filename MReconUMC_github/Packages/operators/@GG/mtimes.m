function res = mtimes(gg,data) 
% This is the actual NUFFT operator
% Data is split in two cases, multi slice or single slice imaging.
% This is for efficient parfor evaluation.

% Set parameters
Kdims=num2cell(gg.Kdims);[ns,nl,nz,nc,ndyn]=deal(Kdims{:});
nx=gg.Rdims(1);ny=gg.Rdims(2);
eps=gg.precision; 

%% Parallel cpu usage.
if gg.parfor>0
    if gg.adjoint==-1 % NUFFT^(-1)
        % non-Cartesian k-space to Cartesian image domain || type 1
        data=reshape(data,[ns*nl nz*nc ndyn 1]);
        
        nj=gg.nj;
        for dyn=1:ndyn
        ktmp=gg.k(:,dyn);
        tmp_data=single(data(:,:,dyn));
        parfor p=1:nc*nz
            res2(:,:,p)=single(nufft2d1(nj,real(ktmp),imag(ktmp),...
                    double(tmp_data(:,p)),-1,eps,nx,ny));
        end
        res(:,:,:,dyn)=res2;
        end
        clear data ktmp tmp_data res2
        res=reshape(res,[nx,ny,nz,nc,ndyn]);
    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        data=reshape(data,[nx*ny,nz*nc,ndyn,1]);
        nj=gg.nj;
        for dyn=1:ndyn
        ktmp=gg.k(:,dyn);
        tmp_data=single(data(:,:,dyn));
        for p=1:nz*nc
            res2(:,:,p)=single(reshape(nufft2d2(nj,real(ktmp),...
                        imag(ktmp),1,eps,nx,ny,double(tmp_data(:,p))),[ns nl]));
        end
        res(:,:,:,dyn)=res2;
        end
        clear data tmp_data i_ktmp r_ktmp res2
        res=reshape(res,[ns nl nz nc ndyn]);
    end
else
%% Parallize for 1 dynamic
    if gg.adjoint==-1 % NUFFT^(-1)
        % non-Cartesian k-space to Cartesian image domain || type 1
        data=reshape(permute(data,[1 2 5 3 4]),[ns*nl,nz*nc,1,1,1]);
        res={};
        nj=gg.nj;
        tmp_k=gg.k;
        parfor p=1:nc*nz
            res{p}=single(nufft2d1(nj,real(tmp_k),imag(tmp_k),...
                    double(data(:,p)),-1,eps,nx,ny));
        end
        clear data tmp_k 
        res=cat(5,res{:});
        res=reshape(res,[nx,ny,nz,nc,ndyn]);
        res=permute(res,[1 2 3 4 5]);
    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        data=reshape(permute(data,[1 2 5 3 4]),[nx*ny,nz*nc,1,1,1]);
        res={};
        tmp_k=gg.k;
        nj=gg.nj;
        parfor p=1:nc*nz
            res{p}=reshape(nufft2d2(nj,real(tmp_k),...
                        imag(tmp_k),1,eps,nx,ny,double(data(:,p))),[ns nl]);
        end
        clear data tmp_k 
        res=cat(5,res{:});
        res=reshape(res,[ns,nl,nz,nc,ndyn]);
        res=permute(res,[1 2 3 4 5]);
    end
end

% END  
end  

