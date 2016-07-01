function LinearPhaseCorrection( MR )
% 20160616 - Linear phase correction by fitting a model through the k0
% phase to correct for angular dependance. Alternatively one could simply
% subtract the k0 phase from all spokes.

% Notification
fprintf('Applying phase correction ........................  ');tic

if strcmpi(MR.ParUMC.PhaseHardSet,'no')
    % Determine psi(x), psi(y) and phi(0) per coil per slice
    dims=size(MR.Data);dims(5)=size(MR.Data,5);
    MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2)*dims(5) 1]),[1 4 2 3]);
    cp=dims(1)/2+1; % k0 index
    cph=permute(angle(MR.Data(cp,:,:,:,:)),[2 3 4 1]); % k0 phases per coil per spoke in radians
    ang=MR.Parameter.Gridder.RadialAngles'; % angles in radians
    parfit=zeros(dims(3),dims(4),4);
    
    for nz=1:dims(3)
        for nc=1:dims(4)
            % Fitting of phi to ang/cph
            phi=@(a,theta)(a(1)*cos(theta)+a(2)*sin(theta)+a(3)); % model
            A0=[1,1,1]; % initial guess
            [A,~,~,~,MSE]=nlinfit(ang,cph(:,nz,nc)',phi,A0);
            if MSE > 0.05
                cph(:,nz,nc)=cph(:,nz,nc)+pi;
                for ns=1:numel(cph(:,nz,nc))
                    if cph(ns,nz,nc)>pi
                        cph(ns,nz,nc)=-pi+(cph(ns,nz,nc)-pi);
                    end
                end
                % Repeat fitting if it was wrapped.
                A=nlinfit(ang,cph(:,nz,nc)',phi,A0);
                A(3)=A(3)-pi;
                parfit(nz,nc,:)=[A 1];
            else
                parfit(nz,nc,:)=[A 0];
            end
        end
    end
    
    pcmatrix=zeros(size(MR.Data));
    for nz=1:dims(3)
        for nc=1:dims(4)
            pcmatrix(:,:,nz,nc)=repmat(exp(1j*phi(parfit(nz,nc,1:3),ang(:)))',[dims(1) 1]);
        end
    end
    
    pcmatrix=permute(reshape(permute(pcmatrix,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2) dims(5)]),[1 4 2 3 5]);
    MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2) dims(5)]),[1 4 2 3 5]);
else
    dims=size(MR.Data);dims(5)=size(MR.Data,5);
    cp=dims(1)/2+1; % k0 index
    cph=angle(MR.Data(cp,:,:,:,:)); % k0 phases per coil per spoke in radians
    pcmatrix=exp(-1j*repmat(cph,[dims(1) 1 1 1 1]));
end

% Apply phase correction
MR.Data=MR.Data.*pcmatrix; 

% Notification    
fprintf('Finished [%.2f sec] \n',toc')

% END
end
