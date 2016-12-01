function res = mtimes(gg,data) 
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
        data=reshape(permute(data,[1 2 3 5 4]),[ns*nl,nz*ndyn,nc,1]);
        
        res={};
        res2={};
        i_ktmp=imag(gg.k);
        r_ktmp=real(gg.k);
        for c=1:nc
            tmp_data=data(:,:,c);
            parfor p=1:ndyn*nz;res2{p}=nufft2d1(gg.nj,r_ktmp(:,p),...
                        i_ktmp(:,p),tmp_data(:,p),-1,eps,nx,ny);end
                res{c}=cat(3,res2{:});
        end
        clear data i_ktmp r_ktmp tmp_data res2
        res=cat(4,res{:});
        res=permute(res,[1 2 5 4 3]);
    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        data=reshape(permute(data,[1 2 3 5 4]),[nx*ny,nz*ndyn,nc,1]);
        res={};
        res2={};
        i_ktmp=imag(gg.k);
        r_ktmp=real(gg.k);
        for c=1:nc
            tmp_data=data(:,:,c);
            parfor p=1:ndyn*nz;res2{p}=reshape(nufft2d2(gg.nj,r_ktmp(:,p),...
                        i_ktmp(:,p),1,eps,nx,ny,tmp_data(:,p)),[ns nl]);end
                res{c}=cat(3,res2{:});
        end
        clear data tmp_data i_ktmp r_ktmp res2
        res=cat(4,res{:});
        res=permute(res,[1 2 5 4 3]);
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

