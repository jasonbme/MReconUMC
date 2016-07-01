function GradientDelayCorrection( MR )
% 20160616 - Perform gradient delay correction, two different methods
% available. 1) uses calibration spokes and 2) uses the complete ensemble
% of spokes. Note that the 'sweep' approach requires a lot of RAM. These
% functions are definitely not optimised yet.

% Check for conflicts
if (MR.ParUMC.NumCalibrationSpokes < 4 && strcmp(MR.ParUMC.GradDelayCorrMethod,'smagdc'))
    fprintf('No gradient delay correction possible with < 4 calibration spokes\n');
    return
end

if (MR.ParUMC.Goldenangle > 1 && strcmpi(MR.ParUMC.GradDelayCorrMethod,'smagdc'))
    fprintf('\nWarning: smagdc does not work very will for tiny golden angle data.\n')
end

% Notification
fprintf('Applying gradient delay correction................  ');tic

% Select methodology
switch MR.ParUMC.GradDelayCorrMethod
    
    case 'smagdc'
        
        % Get dimensions 
        [nx,ns,nz,ncoils,ndyn]=size(MR.Data); 
        
        % Get shifts
        [shiftx,shifty]=SMAGDC(MR.ParUMC.CalibrationData);
        
        % Interpolation model
        dk=@(theta)((cos(2*theta)+1)*shiftx+(-1*cos(2*theta)+1)*shifty)/2;
        
        % Fill phase correction matrix
        correction_matrix=zeros([nx,ns,nz,ncoils,ndyn]); 
        for dyn=1:ndyn 
            for s=1:ns 
                % Get predicted shift from the model
                shift=dk(MR.Parameter.Gridder.RadialAngles(s+((dyn-1)*ns)));
                correction_matrix(:,s,:,:,dyn)=repmat(exp(-2*1i*(polyval([-1*shift*pi/nx 0],-nx/2+1:nx/2)/2)'),[1 1 1 ncoils 1]);
            end
        end
        
        % Apply phase correction in image domain
        fft_mrdata=fftshift(fft(MR.Data));
        fft_pcdata=fft_mrdata.*correction_matrix; 
        
        % Return to frequency domain and save corrected data
        MR.Data=ifft(ifftshift(fft_pcdata));
        

    case 'sweep' 
        
        % Get data dimensions 
        [nx,ns,nz,ncoils,ndyn]=size(MR.Data); % get data dimensions
        
        % Get coil averaged shift per readout
        cshift=SWEEP(MR);

        % Fill phase correction matrix
        correction_matrix=zeros(size(MR.Data));       
        for s=1:ns*ndyn 
            correction_matrix(:,s,:,:)=repmat(exp(-2*1i*(polyval([-1*cshift(s)*pi/nx 0],-nx/2+1:nx/2)/2)'),[1 1 nz ncoils]);
        end
        
        % Apply phase correction in image domain
        fft_mrdata=fftshift(fft(MR.Data));
        fft_pcdata=fft_mrdata.*correction_matrix; 
        
        % Return to frequency domain & reshape back 
        MR.Data=ifft(ifftshift(fft_pcdata));
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[nx nz ncoils ns ndyn]),[1 4 2 3 5]);
end


% Notification
fprintf('Finished [%.2f sec] \n',toc')


% END
end