function [shiftx, shifty] = SMAGDC(cdata)
% 20160629 -- Seperate function to process the calibration spokes
% Returns the coil L2-weighted shift for both directions

% Get dimensions
[nx,ncs,~,ncoils]=size(cdata); 
dc=nx/2+1; % get DC point of the spoke

% Arrange 0-180 & 90-270 spokes in matrix
calispokes=zeros(nx,ncs/2,ncoils,2);
calispokes(:,:,:,1)=cdata(:,1:2:end,:,:);
calispokes(:,:,:,2)=cdata(:,2:2:end,:,:);

% Preallocate matrices for shift
shift=zeros(ncs/4,ncoils,2); 
err=zeros(ncs/4,ncoils,2); 

% Compute L2 per coil
L2=squeeze(sum(sqrt(squeeze(sum(abs(calispokes).^2,1))),1)); 

% Loop over all calibration data to get shifts
for p=1:size(calispokes,2)/2
    % Create an indexer to select pairs
    sp=2*(p-1)+1;
    % Select current pair & flip+translate it
    cur_pair=calispokes(:,sp:sp+1,:,:); 
    cur_pair(:,2,:,:)=flip(cur_pair(:,2,:,:),1); 

    % Create temporary variables to store shifts for paralell computing
    tmp_shift=zeros(ncoils,2);
    tmp_err=zeros(ncoils,2);

    % Iterate over all coil for the current pair
    for nc=1:ncoils 

        % Multiply spoke 1 (e.g. 0 deg) with complex conjugate of pair (e.g. 180 deg)
        g=squeeze(fftc(permute(abs(cur_pair(:,1,nc,:)),[1 4 2 3])).*conj(fftc(permute(abs(cur_pair(:,2,nc,:)),[1 4 2 3])))); 

        % Determine support area (intensity>0) in s1
        s1=squeeze(abs(fftshift(ifft(cur_pair(:,1,nc,:)))));
        [maxval,maxpos]=max(s1); % search from maximum point on
        st=maxpos;fin=maxpos;
        while s1(fin(1),1)>0.1*maxval(1) && fin(1) < nx;fin(1)=fin(1)+1;end % find end
        while s1(fin(2),2)>0.1*maxval(2) && fin(2) < nx;fin(2)=fin(2)+1;end % find end
        while s1(st(1),1)>0.1*maxval(1) && st(1) > 1;st(1)=st(1)-1;end % find start
        while s1(st(2),2)>0.1*maxval(2) && st(2) > 1;st(2)=st(2)-1;end % find start
        
        % Update range of g
        g1=unwrap(angle(g(st(1):fin(1),1))); 
        g2=unwrap(angle(g(st(2):fin(2),2)));
        
        % Solve the inverse problem & compute errors
        [p1,S1]=polyfit((st(1):fin(1))'-dc,g1,1);
        g1fit=polyval(p1(1),(st(1):fin(1))'-dc);
        g1res=sum(abs(g1-g1fit))/numel(g1);
        
        [p2,S2]=polyfit((st(2):fin(2))'-dc,g2,1);
        g2fit=polyval(p2(1),(st(2):fin(2))'-dc);
        g2res=sum(abs(g2-g2fit))/numel(g2);

        % Save values in temporary variable for paralell computing
        tmp_shift(nc,1)=-p1(1)*nx/(2*pi);
        tmp_shift(nc,2)=-p2(1)*nx/(2*pi);
        tmp_err(nc,1)=g1res;
        tmp_err(nc,2)=g2res;
    end

    % Store temporary variables into permanent ones
    shift(p,:,:)=tmp_shift;
    err(p,:,:)=tmp_err;
end

% Calculate the equilibrium shift & standard deviation per coil
for nc=1:ncoils
    x_shift(nc)=median(shift(:,nc,1));
    y_shift(nc)=median(shift(:,nc,2));
    x_sd(nc)=std(shift(:,nc,1));
    y_sd(nc)=std(shift(:,nc,2));
end

% Select five coils with the lowest error & which SD is low
[~,idx]=sort(sum(err,1));
idx=squeeze(idx);

canx=[];
cany=[];
for c=1:5
    if x_sd(idx(c,1))<median(x_sd)
        canx=[canx idx(c,1)];
    end
    if y_sd(idx(c,2))<median(y_sd)
        cany=[cany idx(c,2)];
    end
end

% Compute coil average shift per line
shiftx=sum(x_shift(:,canx))/numel(canx);
shifty=sum(y_shift(:,cany))/numel(cany);

% END
end