function w = radial_dcf(ktraj,varargin)
% Function to get analytical density functions for radial acquisitions.
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
dims=size(ktraj);dims(end+1:12)=1;
cp=dims(1)/2+1; % k0

% Reshape to continueos acquisition case
ktraj=reshape(ktraj,[dims(1),dims(2)*dims(5),dims(3),1,1]);

if nargin<2
    % Create a Ram-Lak filter
    w=ones(dims(1),1);
    for i=1:dims(1)
        w(i)=abs(dims(1)/2 - (i - .5));
    end
    w=pi/(dims(2)*dims(5))*w;
    w=w/max(abs(w(:)));

    % Partition into dynamics
    w=repmat(w,[1 dims(2) 1 1 dims(5)]);
    
else
    % Create a modified ramp filter
    % d(phi,r)=abs(r) * (0.5*dphi_L*dphi_R)/pi 
    
    % Get radial angles from the trajectory
    angles=angle(ktraj(1,:,1,1,1));
    
    % Create a angle list in range [0 pi]
    for s=1:dims(2)*dims(5) % Loop to unwrap the angles
        if angles(s)<0;
            angles(s)=angles(s)+pi;
        end
    end
    
    % Sort all angles so its easy to find neighbouring spokes
    s_angles=sort(angles);
    dphi_L=zeros(dims(2)*dims(5),1);
    dphi_R=zeros(dims(2)*dims(5),1);
    
    % Loop over all spokes and find dphi_L + dphi_R
    for s=1:dims(2)*dims(5)
        [~,minpos]=min(abs(angles(s)-s_angles));
        if minpos==1
            dphi_L(s)=abs(pi-s_angles(end));
            dphi_R(s)=abs(s_angles(minpos)-s_angles(2));
        elseif minpos==dims(2)*dims(5)
            dphi_L(s)=abs(s_angles(minpos)-s_angles(minpos-1));
            dphi_R(s)=abs(s_angles(minpos)-pi);
        else
            dphi_L(s)=abs(s_angles(minpos)-s_angles(minpos-1));
            dphi_R(s)=abs(s_angles(minpos)-s_angles(minpos+1));
        end
    end
    
    % Fill in the weights for every spoke
     w=zeros(dims(1),dims(2)*dims(5));
     for s=1:nl*ndyn
     	w(:,s)=abs(ktraj(:,s)) * 0.5 * (dphi_L(s)+dphi_R(s)) / pi;
     end
    
     % Assign center val and take square root.
     w=w/max(w(:));
     w(cp,:)=1/(2*dims(1));     
     
     % Partition into dynamics
     w=reshape(w,dims);
    
     % Ensure that every dynamic has the same total weight
     for dyn=1:dims(5)
         currdyn=w(:,:,:,:,dyn);
         w(:,:,:,:,dyn)=w(:,:,:,:,dyn)/norm(currdyn(:),1);
     end
end

% END
end