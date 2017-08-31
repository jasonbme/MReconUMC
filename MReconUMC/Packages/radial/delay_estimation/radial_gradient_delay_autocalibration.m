function radial_gradient_delay_autocalibration( MR )

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'autocalibration')
    return;end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);

% Select middle slice slice if 3D stack of stars
z=ceil(size(MR.Data,3)/2);

for n=1:num_data

    % Find closest matching pairs (opposite spokes) 
    curr_angles= MR.Parameter.Gridder.RadialAngles{n};
    idx1=find(curr_angles<=pi);
    idx2=find(curr_angles>pi);

    % Find matching pairs to all angles <= pi
    pair_idx=zeros(length(curr_angles),1);
    for tnd=1:length(idx1)
        dist=abs(curr_angles(idx1(tnd))-(curr_angles(idx2)-pi));
        [~,final_idx]=min(dist);
        pair_idx(idx1(tnd))=idx2(final_idx);
    end

    % Find matching pairs to all angles > pi
    for tnd=1:length(idx2)
        dist=abs((curr_angles(idx2(tnd))-pi)-curr_angles(idx1));
        [~,final_idx]=min(dist);
        pair_idx(idx2(tnd))=idx1(final_idx);
    end

    % Get data dimensions 
    [nx,ns,nz,ncoils,ndyn]=size(MR.Data{n}); % get data dimensions
    dc=nx/2+1; % get DC point of the spoke

    % Preallocate matrices for shift
    shift=zeros(ns*ndyn,ncoils);
    error=zeros(ns*ndyn,ncoils);

    % Reshape MR.Data to for easier handling --> [nx ns*ndyn nz ncoils 1]
    MR.Data=permute(reshape(permute(MR.Data{n},[1 3 4 2 5]),[nx nz ncoils ns*ndyn 1]),[1 4 2 3 5]);

    % Compute L2 per coil
    L2=squeeze(sqrt(squeeze(sum(sum(abs(MR.Data{n}).^2,1),2)))); 

    % Loop over all spokes and find the shift
    for s=1:length(curr_angles) 
        %if pair_idx(s) > s % if spoke or its partner is not filled yet
            cur_pair=MR.Data(:,[s pair_idx(s)],z,:); % select current set of spokes.
            cur_pair(:,2,:,:)=flip(cur_pair(:,2,:,:),1); % flip second spoke.

            % Create temporary variables to store shifts for paralell computing
            cur_shift=zeros(ncoils,1);
            cur_error=zeros(ncoils,1);

            % Loop over all coils
            for nc=1:ncoils
                % Multiply spoke 1 (e.g. 0 deg) with complex conjugate of pair (e.g. 180 deg)
                g=fftshift(fft(abs(cur_pair(:,1,:,nc)))).*conj(fftshift(fft(abs(cur_pair(:,2,:,nc))))); 

                % Determine support area (intensity>0)
                s1=abs(fftshift(fft(abs(cur_pair(:,1,:,nc)))));
                [maxval,maxpos]=max(s1); % search from maximum point on
                st=maxpos;fin=maxpos;
                while s1(fin)>0.1*maxval && fin < nx;fin=fin+1;end % find end
                while s1(st)>0.1*maxval && st > 1;st=st-1;end % find start
                g=angle(g(st:fin)); % update range of g

                % Solve the inverse problem
                [p,S]=polyfit((st:fin)'-dc,g,1);
                gfit=polyval(p,(st:fin)'-dc);
                yresid=sum(abs(g-gfit))/numel(g);

                % Save values in temporary variable for paralell computing
                cur_shift(nc)=-p(1)*(nx/2)/(2*pi);
                cur_error(nc)=yresid;
            end

             % Store temporary variables into permanent ones
            shift(s,:)=cur_shift;
            error(s,:)=cur_error;
        %end
    end

    % Loop over shifts/L2 to fill in the partners
    for s=1:length(curr_angles)
        if shift(s,1)==0
            shift(s,:)=shift(pair_idx(s),:);
        end
    end

    % Select four coils with the lowest error 
    [~,idx]=sort(sum(error,1));

    % Compute coil average shift per line
    cshift=zeros(ns,1);
    for s=1:length(curr_angles)
        cshift(s)=sum(shift(s,[idx(1:4)]))/4;
    end

    %model=@(a,theta)((cos(2*theta)+1)*a(1)+(-cos(2*theta)+1)*a(2))/2;
    model=@(a,theta)(a(1).*cos(theta).^2+a(2).*sin(theta).^2);
    A0=[1 1];
    MR.UMCParameters.SystemCorrections.GradientDelays{n}=nlinfit(MR.Parameter.Gridder.RadialAngles',cshift,model,A0);

    % Reshape MR.Data to for easier handling --> [nx ns*ndyn nz ncoils 1]
    MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 2 5]),[nx nz ncoils ns*ndyn 1]),[1 4 2 3 5]);
end

% END
end