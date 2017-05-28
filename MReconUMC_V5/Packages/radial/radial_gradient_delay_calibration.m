function radial_gradient_delay_calibration( MR )
%% Process calibration data to determine gradient delays

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'calibration')
    return;end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);

for n=1:num_data

    % Select calibration data
    cdata=MR.UMCParameters.SystemCorrections.CalibrationData{n};

    % Select multiples of four
    if mod(size(cdata,2),4)>0
        cdata=cdata(:,1:size(cdata,2)-mod(size(cdata,2),4),:,:);
    end

    % Get dimensions
    [ns,nl,nz,nc]=size(cdata); 
    dc=ns/2+1; % get DC point of the spoke
    ms=round(nz/2); % get middle slice

    % Arrange 0-180 & 90-270 spokes in matrix
    calispokes=zeros(ns,nl/2,nc,2);
    calispokes(:,:,:,1)=cdata(:,1:2:end,ms,:);
    calispokes(:,:,:,2)=cdata(:,2:2:end,ms,:);

    % Preallocate matrices for shift
    shift=zeros(nl/4,nc,2); 
    L2=zeros(nl/4,nc,2); 

    % Loop over all calibration data to get shifts
    for p=1:size(calispokes,2)/2
        
        % Create an indexer to select pairs
        sp=2*(p-1)+1;
        
        % Select current pair & flip+translate it
        cur_pair=abs(calispokes(:,sp:sp+1,:,:)); 
        cur_pair(:,2,:,:)=flip(cur_pair(:,2,:,:),1); 
        
        % Iterate over all coil for the current pair
        for c=1:nc 

            % Multiply spoke 1 (e.g. 0 deg) with complex conjugate of pair 
            
            % g1 = 0-180 deg
            g1=squeeze(fftshift(fft(permute(cur_pair(:,1,c,1),[1 4 2 3]))).*conj(fftshift(fft(permute(cur_pair(:,2,c,1),[1 4 2 3]))))); 
            
            % g2 = 90 - 270 deg
            g2=squeeze(fftshift(fft(permute(cur_pair(:,1,c,2),[1 4 2 3]))).*conj(fftshift(fft(permute(cur_pair(:,2,c,2),[1 4 2 3]))))); 

            % Determine support area (intensity>0) 
            s1=abs(fftshift(fft(squeeze(cur_pair(:,1,c,1)))));
            s2=abs(fftshift(fft(squeeze(cur_pair(:,1,c,2)))));
            [maxval1,maxpos1]=max(s1); % search from maximum point on
            [maxval2,maxpos2]=max(s2); % search from maximum point on

            st1=maxpos1;fin1=maxpos1;
            st2=maxpos2;fin2=maxpos2;
            while s1(fin1)>0.1*maxval1 && fin1 < ns;fin1=fin1+1;end % find end
            while s2(fin2)>0.1*maxval2 && fin2 < ns;fin2=fin2+1;end % find end
            while s1(st1)>0.1*maxval1 && st1 > 1;st1=st1-1;end % find start
            while s2(st2)>0.1*maxval2 && st2 > 1;st2=st2-1;end % find start
            
            % Update range of g
            g1=angle(g1(st1:fin1)); 
            g2=angle(g2(st2:fin2));
            
            % Solve the inverse problem & compute errors
            [p1,S1]=polyfit((st1:fin1)'-dc,g1,1);
            g1fit=polyval(p1(1),(st1:fin1)'-dc);
            g1res=sum(abs(g1-g1fit))/numel(g1);
            
            [p2,S2]=polyfit((st2:fin2)'-dc,g2,1);
            g2fit=polyval(p2(1),(st2:fin2)'-dc);
            g2res=sum(abs(g2-g2fit))/numel(g2);

            % Save values
            shift(p,c,1)=-p1(1)*(ns/2)/(2*pi);
            shift(p,c,2)=-p2(1)*(ns/2)/(2*pi);
            L2(p,c,1)=sqrt(sum(abs(squeeze(cur_pair(:,1,c,1))).^2));
            L2(p,c,2)=sqrt(sum(abs(squeeze(cur_pair(:,1,c,2))).^2));
        end
    end

    % Make L-2 weighted averages
    L2shift=shift.*L2;
    avg_L2shift=squeeze(sum(L2shift,2))./squeeze(sum(L2,2));

    % Store shifts 
    shift1=mean(avg_L2shift(:,1));
    shift2=mean(avg_L2shift(:,2));

    % Save delays in struct
    MR.UMCParameters.SystemCorrections.GradientDelays{n}=[shift1 shift2];
end

% END
end
