function GradDelayCorr( MR )
% 20160616 - Perform gradient delay correction, two different methods
% available. 1) uses calibration spokes and 2) uses the complete ensemble
% of spokes. Note that the 'sweep' approach requires a lot of RAM. These
% functions are definitely not optimised yet.

%% Check for conflicts
if (MR.ParUMC.NumCalibrationSpokes < 4 && strcmp(MR.ParUMC.GradDelayCorrMethod,'smagdc'))
    fprintf('No gradient delay correction possible with < 4 calibration spokes\n');
    return
end

% Notification
fprintf('Applying k-space shift ...........................  ');tic

%% Simple Method for Adaptive Gradient Delay Compensation
switch MR.ParUMC.GradDelayCorrMethod
    case 'smagdc'
        % Get dimensions and arrange calibration data
        [nx,ns,nz,ncoils,ndyn]=size(MR.Data); % get data dimensions
        cdata=MR.ParUMC.CalibrationData; % calibration data
        ncs=size(cdata,2); % number of calibration spokes
        calispokes=[cdata(:,1:2:end,:,:) cdata(:,2:2:end,:,:)]; % Arrange 0-180 & 90-270 spokes in matrix
        dc=nx/2+1; % get DC point of the spoke
        shift=zeros(ncs/2,ncoils); % preallocate matrix for the desired shifts
        L2=zeros(ncs/2,ncoils); % preallocate matrix for L2 weighting
        
        % Loop over all calibration data and obtain shifts along the spoke directions from cross-correlations
        parfor pair=1:ncs/2 % loop over all pairs
            s=pair*2-1; % index for selecting proper calibration spokes
            cur_pair=calispokes(:,s:s+1,:,:); % select current pair of spokes.
            cur_pair(:,2,:,:)=flipud(cur_pair(:,2,:,:)); % flip second spoke 
            cur_pair(2:nx,2,:,:)=cur_pair(1:nx-1,2,:,:); % translate 1 point
            
            % Create temporary variables to store shifts for paralell computing
            cur_shift=zeros(ncoils,1);
            cur_L2=zeros(ncoils,1);
            
            for nc=1:ncoils % loop over coils
                % Multiply spoke 1 (e.g. 0 deg) with complex conjugate of pair (e.g. 180 deg)
                g=squeeze(fftc(abs(cur_pair(:,1,:,nc))).*conj(fftc(abs(cur_pair(:,2,:,nc))))); 
                
                % Determine support area (intensity>0)
                s1=squeeze(abs(fftshift(ifft(cur_pair(:,1,:,nc)))));
                [maxval,maxpos]=max(s1); % search from maximum point on
                st=maxpos;fin=maxpos;
                while s1(fin)>0.1*maxval && fin < nx;fin=fin+1;end % find end
                while s1(st)>0.1*maxval && st > 1;st=st-1;end % find start
                g=unwrap(angle(g(st:fin))); % update range of g
                
                % Solve the inverse problem
                p=polyfit((st:fin)'-dc,g,1);
                
                % Save values in temporary variable for paralell computing
                cur_shift(nc)=-p(1)*nx/(2*pi);
                cur_L2(nc)=norm(s1(st:fin),2);
            end
            
            % Store temporary variables into permanent ones
            shift(pair,:)=cur_shift;
            L2(pair,:)=cur_L2;
        end

        % Calculate the equilibrium shift & L2 per coil per direction
        for nc=1:ncoils
            x_shift(nc)=mean(shift(1:ncs/4,nc));
            x_L2(nc)=mean(L2(1:ncs/4,nc));
            y_shift(nc)=mean(shift(ncs/4+1:ncs/2,nc));
            y_L2(nc)=mean(L2(ncs/4+1:ncs/2,nc));
        end

        % Calculate coil average by L2 weighting
        shiftx=x_shift*x_L2'/sum(x_L2(:));
        shifty=y_shift*y_L2'/sum(y_L2(:));

        % Interpolate phase shift for the actual imaging spokes
        % Interpolation model
        dk=@(theta)((cos(2*theta)+1)*shiftx+(-1*cos(2*theta)+1)*shifty)/2;
        
        % Fill phase correction matrix
        phase_correction_matrix=zeros([nx,ns,nz,ncoils,ndyn]); 
        for dyn=1:ndyn % loop over all dynamics
            for s=1:ns % loop over all spokes
                % Get predicted shift from the model
                shift=dk(MR.Parameter.Gridder.RadialAngles(s+((dyn-1)*ns)));
                phase_correction_matrix(:,s,:,:,dyn)=repmat(exp(-2*1i*(polyval([-1*shift*2*pi/nx 0],-nx/2+1:nx/2)/2)'),[1 1 1 ncoils 1]);
            end
        end
        
        % Apply phase correction in image domain
        fft_mrdata=fftshift(fft(MR.Data));
        fft_pcdata=fft_mrdata.*phase_correction_matrix; 
        
        % Return to frequency domain and save corrected data
        MR.Data=ifft(ifftshift(fft_pcdata));
        

    case 'sweep' 
        % Find closest matching pairs (opposite spokes) 
        curr_angles= MR.Parameter.Gridder.RadialAngles;
        idx1=find(curr_angles<=pi);
        idx2=find(curr_angles>pi);

        % find matching pairs to all angles <= pi
        pair_idx=zeros(length(curr_angles),1);
        for tnd=1:length(idx1)
            dist=abs(curr_angles(idx1(tnd))-(curr_angles(idx2)-pi));
            [~,final_idx]=min(dist);
            pair_idx(idx1(tnd))=idx2(final_idx);
        end

        % find matching pairs to all angles > pi
        for tnd=1:length(idx2)
            dist=abs((curr_angles(idx2(tnd))-pi)-curr_angles(idx1));
            [~,final_idx]=min(dist);
            pair_idx(idx2(tnd))=idx1(final_idx);
        end

        % Get data dimensions 
        [nx,ns,nz,ncoils,ndyn]=size(MR.Data); % get data dimensions
        dc=nx/2+1; % get DC point of the spoke
        shift=zeros(ns*ndyn,ncoils); % preallocate matrix for the desired shifts
        L2=zeros(ns*ndyn,ncoils); % preallocate matrix for L2 weighting

        % Reshape MR.Data to for easier handling --> [nx ns*ndyn nz ncoils 1]
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[nx nz ncoils ns*ndyn 1]),[1 4 2 3 5]);
        
        % Loop over all spokes and find the shift
        parfor s=1:length(curr_angles) 
            if pair_idx(s) > s % if spoke or its partner is not filled yet
                cur_pair=MR.Data(:,[s pair_idx(s)],:,:); % select current set of spokes.
                cur_pair(:,2,:,:)=flipud(cur_pair(:,2,:,:)); % flip second spoke.
                cur_pair(2:nx,2,:,:)=cur_pair(1:nx-1,2,:,:); % translate 1 point
                
                % Create temporary variables to store shifts for paralell computing
                cur_shift=zeros(ncoils,1);
                cur_L2=zeros(ncoils,1);
            
                % Loop over all coils
                for nc=1:ncoils
                    % Multiply spoke 1 (e.g. 0 deg) with complex conjugate of pair (e.g. 180 deg)
                    g=fftc(abs(cur_pair(:,1,:,nc))).*conj(fftc(abs(cur_pair(:,2,:,nc)))); 
                    
                    % Determine support area (intensity>0)
                    s1=abs(fftc(abs(cur_pair(:,1,:,nc))));
                    [maxval,maxpos]=max(s1); % search from maximum point on
                    st=maxpos;fin=maxpos;
                    while s1(fin)>0.1*maxval && fin < nx;fin=fin+1;end % find end
                    while s1(st)>0.1*maxval && st > 1;st=st-1;end % find start
                    g=unwrap(angle(g(st:fin))); % update range of g
                    
                    % Solve the inverse problem
                    p=polyfit((st:fin)'-dc,g,1);
                    
                    % Save values in temporary variable for paralell computing
                    cur_shift(nc)=-p(1)*nx/(2*pi);
                    cur_L2(nc)=norm(s1(st:fin),2);
                end
                
                 % Store temporary variables into permanent ones
                shift(s,:)=cur_shift;
                L2(s,:)=cur_L2; 
            end
        end
        
        % Loop over shifts/L2 to fill in the partners
        for s=1:length(curr_angles)
            if shift(s,1)==0
                shift(s,:)=shift(pair_idx(s),:);
                L2(s,:)=L2(pair_idx(s),:);
            end
        end
        
        % Calculate coil average by L2 weighting
        L2_shift=zeros(numel(curr_angles),1);
        for s=1:numel(curr_angles)
            L2_shift(s)=L2(s,:)*shift(s,:)'/sum(L2(s,:));
        end
        
        % Fill phase correction matrix
        phase_correction_matrix=zeros(size(MR.Data));       
        for s=1:numel(curr_angles) % loop over all spokes
                phase_correction_matrix(:,s,:,:)=repmat(exp(-2*1i*(polyval([-1*L2_shift(s)*pi/nx 0],-nx/2+1:nx/2)/2)'),[1 1 1 ncoils]);
        end
        
        % Apply phase correction in image domain
        fft_mrdata=fftshift(fft(MR.Data));
        fft_pcdata=fft_mrdata.*phase_correction_matrix; 
        
        % Return to frequency domain & reshape back 
        MR.Data=ifft(ifftshift(fft_pcdata));
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[nx nz ncoils ns ndyn]),[1 4 2 3 5]);
end


% Notification
fprintf('Finished [%.2f sec] \n',toc')


% END
end