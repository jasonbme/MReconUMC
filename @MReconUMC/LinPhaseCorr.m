function LinPhaseCorr( MR )
% 20160616 - Linear phase correction by fitting a model through the k0
% phase to correct for angular dependance. Alternatively one could simply
% subtract the k0 phase from all spokes.

% Notification
fprintf('Applying phase correction ........................  ');tic

% Determine psi(x), psi(y) and phi(0) per coil
dims=size(MR.Data);dims(5)=size(MR.Data,5);
MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2)*dims(5) 1]),[1 4 2 3]);
cp=dims(1)/2+1; % k0 index
cph=squeeze(angle(MR.Data(cp,:,1,:,:))); % k0 phases per coil per spoke in radians
ang=MR.Parameter.Gridder.RadialAngles'; % angles in radians
parfit=zeros(dims(4),4);

for nc=1:dims(4)
    % Fitting of phi to ang/cph
    phi=@(a,theta)(a(1)*cos(theta)+a(2)*sin(theta)+a(3)); % model
    A0=[1,1,1]; % initial guess
    [A,~,~,~,MSE]=nlinfit(ang,cph(:,nc)',phi,A0);
    if MSE > 0.05
        cph(:,nc)=cph(:,nc)+pi;
        for ns=1:numel(cph(:,nc))
            if cph(ns,nc)>pi
                cph(ns,nc)=-pi+(cph(ns,nc)-pi);
            end
        end
        % Repeat fitting if it was wrapped.
        A=nlinfit(ang,cph(:,nc)',phi,A0);
        A(3)=A(3)-pi;
        parfit(nc,:)=[A 1];
    else
        parfit(nc,:)=[A 0];
    end
end


% Apply phase correction
pcmatrix=zeros(size(MR.Data));

for nc=1:dims(4)
    pcmatrix(:,:,1,nc)=repmat(exp(1j*phi(parfit(nc,1:3),ang(:)))',[dims(1) 1]);
end


MR.Data=permute(reshape(permute(MR.Data.*pcmatrix,[1 3 4 2]),[dims(1) dims(3) dims(4) dims(2) dims(5)]),[1 4 2 3 5]); 

% Notification    
fprintf('Finished [%.2f sec] \n',toc')

% END
end