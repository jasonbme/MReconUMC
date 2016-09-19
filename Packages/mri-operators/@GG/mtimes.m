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
        output=zeros([nx,ny,nz,nc,ndyn]);
        if nz > 1
            parfor z=1:nz % loop over slices
                myTemp2=zeros([nx ny nc ndyn]);
                for dyn=1:ndyn
                    myTemp=zeros([nx ny nc]);
                    myData=data(:,:,z,:,dyn);
                    xj=real(gg.k(:,:,z,dyn));
                    yj=imag(gg.k(:,:,z,dyn));
                    for c=1:nc
                        cj=myData(:,:,c);
                        myTemp(:,:,c)=nufft2d1(gg.nj,xj(:),yj(:),cj(:),gg.adjoint,eps,nx,ny);
                    end
                    myTemp2(:,:,:,dyn)=myTemp;
                end
                output(:,:,z,:,:)=myTemp2;
            end
        else
            parfor dyn=1:ndyn
                myTemp=zeros([nx ny nz nc]);
                myData=data(:,:,:,:,dyn);
                xj=real(gg.k(:,:,:,:,dyn));
                yj=imag(gg.k(:,:,:,:,dyn));
                for c=1:nc
                    cj=myData(:,:,:,c);
                    myTemp(:,:,:,c)=nufft2d1(gg.nj,xj(:),yj(:),cj(:),gg.adjoint,eps,nx,ny);
                end
                output(:,:,:,:,dyn)=myTemp;
            end
        end
    else % NUFFT
        % Cartesian image domain to non-Cartesian k-space || type 2
        output=zeros([ns nl nz nc ndyn]);
        if nz > 1
            parfor z=nz
                myTemp2=zeros([ns nl 1 nc ndyn]);
                for dyn=1:ndyn
                    myTemp=zeros([ns nl nc]);
                    myData=data(:,:,z,:,dyn);
                    xj=real(gg.k(:,:,z,dyn));
                    yj=imag(gg.k(:,:,z,dyn));
                    for c=1:nc
                        cj=myData(:,:,:,c);
                        myTemp(:,:,c)=reshape(nufft2d2(gg.nj,xj(:),yj(:),gg.adjoint,eps,nx,ny,cj),[ns nl]);
                    end
                    myTemp2(:,:,:,:,dyn)=myTemp;
                end
                output(:,:,z,:,:)=myTemp2;
            end
        else
            parfor dyn=1:ndyn
                myTemp=zeros([ns nl nc]);
                myData=data(:,:,:,:,dyn);
                xj=real(gg.k(:,:,:,dyn));
                yj=imag(gg.k(:,:,:,dyn));
                for c=1:nc
                    cj=myData(:,:,:,c);
                    myTemp(:,:,c)=reshape(nufft2d2(gg.nj,xj(:),yj(:),gg.adjoint,eps,nx,ny,cj),[ns nl]);
                end
                output(:,:,:,:,dyn)=myTemp;
            end
        end
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

