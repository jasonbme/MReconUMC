function output = mtimes(Op,Data) % This is the actual NUFFT operator

dims=size(Data);dims(5)=size(Data,5);
Data=double(Data);
eps=Op.precision; % precision

if Op.adjoint==-1 % inverse fft
    % non-Cartesian k-space to Cartesian image domain || type 1
    output=zeros([Op.Rdims dims(4) dims(5)]);
    if dims(3) > 1
        parfor nz=1:Op.Rdims(3) % loop over slices
            myTemp2=zeros([Op.Rdims(1) Op.Rdims(2) dims(4) dims(5)]);
            for ndyn=1:dims(5)
                myTemp=zeros([Op.Rdims(1) Op.Rdims(2) dims(4)]);
                myData=Data(:,:,nz,:,ndyn);
                xj=real(Op.k(:,:,nz,ndyn));
                yj=imag(Op.k(:,:,nz,ndyn));
                for ncoil=1:dims(4)
                    cj=myData(:,:,ncoil);
                    myTemp(:,:,ncoil)=nufft2d1(Op.nj,xj(:),yj(:),cj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2));
                end
                myTemp2(:,:,:,ndyn)=myTemp;
            end
            output(:,:,nz,:,:)=myTemp2;
        end
    else
        parfor ndyn=1:dims(5)
            myTemp=zeros([Op.Rdims(1) Op.Rdims(2) dims(4)]);
            myData=Data(:,:,:,:,ndyn);
            xj=real(Op.k(:,:,:,ndyn));
            yj=imag(Op.k(:,:,:,ndyn));
            for ncoil=1:dims(4)
                cj=myData(:,:,ncoil);
                myTemp(:,:,ncoil)=nufft2d1(Op.nj,xj(:),yj(:),cj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2));
            end
            output(:,:,:,:,ndyn)=myTemp;
        end
    end
else
    % Cartesian image domain to non-Cartesian k-space || type 2
    output=zeros([Op.Kdims(1) Op.Kdims(2) dims(3) dims(4) dims(5)]);
    if dims(3) > 1
        parfor nz=1:Op.Rdims(3)
            myTemp2=zeros([Op.Kdims(1) Op.Kdims(2) 1 dims(4) dims(5)]);
            for ndyn=1:dims(5)
                myTemp=zeros([Op.Kdims(1) Op.Kdims(2) dims(4)]);
                myData=Data(:,:,nz,:,ndyn);
                xj=real(Op.k(:,:,nz,ndyn));
                yj=imag(Op.k(:,:,nz,ndyn));
                for ncoil=1:dims(4)
                    cj=myData(:,:,:,ncoil);
                    myTemp(:,:,ncoil)=reshape(nufft2d2(Op.nj,xj(:),yj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2),cj),[size(Op.k,1) size(Op.k,2)]);
                end
                myTemp2(:,:,:,:,ndyn)=myTemp;
            end
            output(:,:,nz,:,:)=myTemp2;
        end
    else
        parfor ndyn=1:dims(5)
            myTemp=zeros([Op.Kdims(1) Op.Kdims(2) dims(4)]);
            myData=Data(:,:,:,:,ndyn);
            xj=real(Op.k(:,:,:,ndyn));
            yj=imag(Op.k(:,:,:,ndyn));
            for ncoil=1:dims(4)
                cj=myData(:,:,:,ncoil);
                myTemp(:,:,ncoil)=reshape(nufft2d2(Op.nj,xj(:),yj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2),cj),[size(Op.k,1) size(Op.k,2)]);
            end
            output(:,:,:,:,ndyn)=myTemp;
        end
    end
end

% END  
end  

