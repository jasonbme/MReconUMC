function w = radialDCF(ktraj,varargin)
% Function to get analytical density functions for radial acquisitions.
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
[ns,nl,nz,~,ndyn]=size(ktraj);
cp=ns/2+1; % k0

% Reshape to continueos acquisition case
ktraj=reshape(ktraj,[ns,nl*ndyn,nz,1,1]);

if nargin<2
    % Create a Ram-Lak filter
    w=ones(ns,1);
    for i=1:ns
        w(i)=abs(ns/2 - (i - .5));
    end
    w=pi/(nl*ndyn)*w;
    w=w/max(abs(w(:)));

    % Partition into dynamics
    w=repmat(w,[1 nl nz 1 ndyn]);
    
else
    % Create a modified ramp filter
    % d(phi,r)=abs(r) * (0.5*dphi_L*dphi_R)/pi 
    
    % Get radial angles from the trajectory
    angles=angle(ktraj(1,:,1,1,1));
    
    % Create a angle list in range [0 pi]
    for s=1:nl*ndyn % Loop to unwrap the angles
        if angles(s)<0;
            angles(s)=angles(s)+pi;
        end
    end
    
    % Sort all angles so its easy to find neighbouring spokes
    s_angles=sort(angles);
    dphi_L=zeros(nl*ndyn,1);
    dphi_R=zeros(nl*ndyn,1);
    
    % Loop over all spokes and find dphi_L + dphi_R
    for s=1:nl*ndyn
        [~,minpos]=min(abs(angles(s)-s_angles));
        if minpos==1
            dphi_L(s)=abs(pi-s_angles(end));
            dphi_R(s)=abs(s_angles(minpos)-s_angles(2));
        elseif minpos==nl*ndyn
            dphi_L(s)=abs(s_angles(minpos)-s_angles(minpos-1));
            dphi_R(s)=abs(s_angles(minpos)-pi);
        else
            dphi_L(s)=abs(s_angles(minpos)-s_angles(minpos-1));
            dphi_R(s)=abs(s_angles(minpos)-s_angles(minpos+1));
        end
    end
    
    % Fill in the weights for every spoke
     w=zeros(ns,nl*ndyn);
     for s=1:nl*ndyn
     	w(:,s)=abs(ktraj(:,s)) * 0.5 * (dphi_L(s)+dphi_R(s)) / pi;
     end
    
     % Assign center val and take square root.
     w=w/max(w(:));
     w(cp,:)=1/(2*ns);     
     
     % Partition into dynamics
     w=reshape(w,[ns,nl,1,1,ndyn]);
     
     % Copy for nz
     w=repmat(w,[1 1 nz 1 1]);
    
     % Ensure that every dynamic has the same total weight
     for dyn=1:ndyn
         currdyn=w(:,:,:,:,dyn);
         w(:,:,:,:,dyn)=w(:,:,:,:,dyn)/norm(currdyn(:),1);
     end
end

% END
end