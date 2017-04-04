function res = mtimes(gg,data) 
% This is the actual NUFFT operator
% Data is split in two cases, multi slice or single slice imaging.
% This is for efficient parfor evaluation.

% Set parameters
Kdims=num2cell(gg.Kdims);[ns,nl,nz,nc,ndyn]=deal(Kdims{:});
nx=gg.Rdims(1);ny=gg.Rdims(2);
eps=gg.precision; 
data=double(data);

if gg.parfor>0 % if parallel
    
    if ndyn < nz
        if gg.adjoint==-1 % NUFFT^(-1)
            % non-Cartesian k-space to Cartesian image domain || type 1
            data=reshape(data,[ns*nl nz*nc ndyn 1]);
            
            nj=gg.nj;
            for dyn=1:ndyn
                ktmp=gg.k(:,dyn);
                tmp_data=data(:,:,dyn);
                parfor p=1:nc*nz
                    res2(:,:,p)=nufft2d1(nj,real(ktmp),imag(ktmp),...
                        tmp_data(:,p),-1,eps,nx,ny);
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
                tmp_data=data(:,:,dyn);
                parfor p=1:nz*nc
                    res2(:,:,p)=reshape(nufft2d2(nj,real(ktmp),...
                        imag(ktmp),1,eps,nx,ny,tmp_data(:,p)),[ns nl]);
                end
                res(:,:,:,dyn)=res2;
            end
            clear data tmp_data i_ktmp r_ktmp res2
            res=reshape(res,[ns nl nz nc ndyn]);
        
        end
    else
         if gg.adjoint==-1 % NUFFT^(-1)
            % non-Cartesian k-space to Cartesian image domain || type 1
            data=permute(reshape(data,[ns*nl nz nc ndyn 1]),[1 4 2 3 5]);
            
            for z=1:nz
                for c=1:nc
                    tmp_data=data(:,:,z,c);
                    parfor dyn=1:ndyn
                        res2(:,:,dyn)=nufft2d1(gg.nj,real(gg.k(:,dyn)),imag(gg.k(:,dyn)),...
                            tmp_data(:,dyn),-1,eps,nx,ny);
                    end
                end
                res(:,:,z,c,:)=res2;
            end
            clear data ktmp tmp_data res2
        else
            % Cartesian image domain to non-Cartesian k-space || type 2
            data=permute(reshape(data,[nx*ny nz nc ndyn,1]),[1 4 2 3 5]);

            for z=1:nz
                for c=1:nc              
                    tmp_data=data(:,:,z,c,:);
                    parfor dyn=1:ndyn
                        res2(:,:,dyn)=reshape(nufft2d2(gg.nj,real(gg.k(:,dyn)),...
                            imag(gg.k(:,dyn)),1,eps,nx,ny,tmp_data(:,dyn)),[ns nl]);
                    end
                    res(:,:,z,c,:)=res2;
                end
            end
            clear data tmp_data i_ktmp r_ktmp res2
            res=reshape(res,[ns nl nz nc ndyn]);
        end
    end
    
else % If not parallel

    if gg.adjoint==-1 % NUFFT^(-1)
        
        
        % non-Cartesian k-space to Cartesian image domain || type 1
        res=zeros(nx,ny,nz,nc,ndyn);

        % Loop over all nufft steps
        for z=1:nz
            for c=1:nc
                for dyn=1:ndyn
                    res(:,:,z,c,dyn)=nufft2d1(gg.nj,real(gg.k(:,dyn)),...
                        imag(gg.k(:,dyn)),data(:,:,z,c,dyn),-1,eps,nx,ny);
                end
            end
        end
    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        res=zeros(ns,nl,nz,nc,ndyn);
        
        % Loop over all nufft steps
        for z=1:nz
            for c=1:nc
                for dyn=1:ndyn
                    res(:,:,z,c,dyn)=reshape(nufft2d2(gg.nj,real(gg.k(:,dyn)),...
                        imag(gg.k(:,dyn)),1,eps,nx,ny,data(:,:,z,c,dyn)),[ns nl]);
                end
            end
        end
        
    end
end

% END  
end  

