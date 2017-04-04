function radial_phasecorrection( MR )
% 20160616 - Linear phase correction by fitting a model through the k0
% phase to correct for angular dependance. Alternatively one could simply
% subtract the k0 phase from all spokes.

if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon') || strcmpi(MR.Parameter.Scan.UTE,'no')
    return
end

if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'no')
    if strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model')
        % Determine psi(x), psi(y) and phi(0) per coil per slice
        [ns,nl,nz,nc,ndyn]=size(MR.Data);
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl*ndyn 1]),[1 4 2 3]);
        [~,cp]=min(MR.Parameter.Gridder.Weights(:,1)); % k0 index
        cph=permute(angle(MR.Data(cp,:,:,:,:)),[2 3 4 1]); % k0 phases per coil per spoke in radians
        ang=MR.Parameter.Gridder.RadialAngles'; % angles in radians
        parfit=zeros(nz,nc,4);

        for z=1:nz
            for c=1:nc
                % Fitting of phi to ang/cph
                phi=@(a,theta)(a(1)*cos(theta)+a(2)*sin(theta)+a(3)); % model
                A0=[1,1,1]; % initial guess
                [A,~,~,~,MSE]=nlinfit(ang,cph(:,z,c),phi,A0);
                if MSE > 0.5
                    cph(:,z,c)=cph(:,z,c)+pi;
                    for s=1:numel(cph(:,z,c))
                        if cph(s,z,c)>pi
                            cph(s,z,c)=-pi+(cph(s,z,c)-pi);
                        end
                    end
                    % Repeat fitting if it was wrapped.
                    A=nlinfit(ang,cph(:,z,c),phi,A0);
                    A(3)=A(3);
                    parfit(z,c,:)=[A 1];
                else
                    parfit(z,c,:)=[A 0];
                end
            end
        end
        pcmatrix=zeros(size(MR.Data));
        for z=1:nz
            for c=1:nc
                pcmatrix(:,:,z,c)=repmat(exp(1j*phi(parfit(z,c,1:3),ang(:)))',[ns 1]);
            end
        end

        pcmatrix=permute(reshape(permute(pcmatrix,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
    end

    if strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero')
        [ns,nl,nz,nc,ndyn]=size(MR.Data);
        [~,cp]=min(MR.Parameter.Gridder.Kpos(:,1)); % k0 index
        cph=angle(MR.Data(cp,:,:,:,:)); % k0 phases per coil per spoke in radians
        pcmatrix=exp(-1j*repmat(cph,[ns 1 1 1 1]));
        %% Alternative way to do phase correction by interpolation
%         cph=zeros(1,nl,nz,nc,ndyn);
%         [~,minpos]=min(abs(MR.Parameter.Gridder.Kpos));
%         for dyn=1:ndyn
%             for l=1:nl
%                 cph=angle(MR.Data(minpos(1,l,dyn),l,:,:,dyn));
%                 pcmatrix(:,l,:,:,dyn)=single(exp(-1j*repmat(cph,[ns 1 1 1 1])));
%             end
%         end
    end

    % Apply phase correction
    MR.Data=MR.Data.*pcmatrix; 
end

% END
end
