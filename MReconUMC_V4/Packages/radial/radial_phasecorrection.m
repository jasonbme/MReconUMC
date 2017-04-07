function radial_phasecorrection( MR )
% 20160616 - Linear phase correction by fitting a model through the k0
% phase to correct for angular dependance. Alternatively one could simply
% subtract the k0 phase from all spokes.

if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon') || strcmpi(MR.Parameter.Scan.UTE,'yes')
    return
end

% Notification
fprintf('\n              Include radial phase correction.....  ');tic;

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(dims);

if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'no')
    if strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model')
        % Determine psi(x), psi(y) and phi(0) per coil per slice
        for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 2 5:12]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(2)*dims{n}(5) dims{n}(6:11)]),[1 4 2 3 5:12]);end
        [~,cp]=min(MR.Parameter.Gridder.Weights(:,1)); % k0 index
        for n=1:num_data;cph{n}=permute(angle(MR.Data{n}(cp,:,:,:,:,:,:,:,:,:,:,:)),[2 3 4 1 5:12]);end % k0 phases per coil per spoke in radians
        ang=MR.Parameter.Gridder.RadialAngles'; % angles in radians
        for n=1:num_data;parfit{n}=zeros([dims{n}(3),dims{n}(4),dims{n}(6:11),4]);end
        for n=1:num_data;pcmatrix{n}=zeros(dims{n});end
        
        for n=1:num_data
        for k=1:dims{n}(11)
        for h=1:dims{n}(10)
        for g=1:dims{n}(9)
        for f=1:dims{n}(8)
        for e=1:dims{n}(7)
        for d=1:dims{n}(6)
        for z=1:dims{n}(3)
            for c=1:dims{n}(4)
                % Fitting of phi to ang/cph
                phi=@(a,theta)(a(1)*cos(theta)+a(2)*sin(theta)+a(3)); % model
                A0=[1,1,1]; % initial guess
                [A,~,~,~,MSE]=nlinfit(ang,cph{n}(:,z,c,d,e,f,g,h,k),phi,A0);
                if MSE > 0.5
                    cph{n}(:,z,c,d,e,f,g,h,k)=cph{n}(:,z,c,d,e,f,g,h,k)+pi;
                    for s=1:numel(cph{n}(:,z,c))
                        if cph{n}(s,z,c,d,e,f,g,h,k)>pi
                            cph{n}(s,z,c,d,e,f,g,h,k)=-pi+(cph{n}(s,z,c,d,e,f,g,h,k)-pi);
                        end
                    end
                    % Repeat fitting if it was wrapped.
                    A=nlinfit(ang,cph{n}(:,z,c,d,e,f,g,h,k),phi,A0);
                    parfit{n}(z,c,d,e,f,g,h,k,:)=[A 1];
                else
                    parfit{n}(z,c,d,e,f,g,h,k,:)=[A 0];
                end

                % Store in correction matrix
                pcmatrix{n}(:,:,z,c)=repmat(exp(1j*phi(parfit{n}(z,c,d,e,f,g,h,k,1:3),ang(:)))',[dims{n}(1) 1]);

            end
        end
        end
        end
        end
        end
        end
        end
        end
        
        for n=1:num_data;pcmatrix{n}=permute(reshape(permute(pcmatrix{n},[1 3 4 2 5:12]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(2) dims{n}(5:12)]),[1 4 2 3 5:12]);end
        for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 2 5:12]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(2) dims{n}(5:12)]),[1 4 2 3 5:12]);end
    end

    if strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero')
        for n=1:num_data;[~,cp{n}]=min(MR.Parameter.Gridder.Kpos{n}(:,1));end % k0 index
        for n=1:num_data;cph{n}=angle(MR.Data{n}(cp{n},:,:,:,:,:,:,:,:,:,:,:));end % k0 phases per coil per spoke in radians
        for n=1:num_data;pcmatrix{n}=exp(-1j*repmat(cph{n},[dims{n}(1) 1 1 1 1 1 1 1 1 1 1]));end
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

    % If UTE the do no phase correction on first echo
    % Apply phase correction
    for n=1:num_data;MR.Data{n}=MR.Data{n}.*pcmatrix{n};end 
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
