function output = mtimes(Op,Data) % This is the actual NUFFT operator

dims=size(Data);dims(5)=size(Data,5);
Data=double(Data);
eps=Op.precision; % precision

if Op.adjoint==-1 % inverse fft
    % non-Cartesian k-space to Cartesian image domain || type 1
    output=zeros([Op.Rdims dims(3) dims(4) dims(5)]);
    template_myTemp=zeros([Op.Rdims dims(3) dims(4)]);
    parfor ndyn=1:dims(5)
        myTemp=template_myTemp;
        myData=Data(:,:,:,:,ndyn);
        xj=real(Op.k(:,:,:,ndyn));
        yj=imag(Op.k(:,:,:,ndyn));
        for ncoil=1:dims(4)
            %cj=Data(:,:,:,ncoil,ndyn);
            cj=myData(:,:,:,ncoil);
            %output(:,:,:,ncoil,ndyn)=nufft2d1(Op.nj,xj(:),yj(:),cj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2));
            myTemp(:,:,:,ncoil)=nufft2d1(Op.nj,xj(:),yj(:),cj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2));
        end
        output(:,:,:,:,ndyn)=myTemp;
    end
else
    % Cartesian image domain to non-Cartesian k-space || type 2
    output=zeros([Op.Kdims(1) Op.Kdims(2) dims(3) dims(4) dims(5)]);
    template_myTemp=zeros([Op.Kdims(1) Op.Kdims(2) dims(3) dims(4)]);
    for ndyn=1:dims(5)
        myTemp=template_myTemp;
        myData=Data(:,:,:,:,ndyn);
        xj=real(Op.k(:,:,:,ndyn));
        yj=imag(Op.k(:,:,:,ndyn));
        for ncoil=1:dims(4)
            cj=myData(:,:,:,ncoil);
            myTemp(:,:,:,ncoil)=reshape(nufft2d2(Op.nj,xj(:),yj(:),Op.adjoint,eps,Op.Rdims(1),Op.Rdims(2),cj),[size(Op.k,1) size(Op.k,2)]);
        end
        output(:,:,:,:,ndyn)=myTemp;
    end
end

% END  
end  

