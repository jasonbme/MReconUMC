function w = DensityCompensation(MR)
% Input: ns  = number of radial spokes
%        dim = size of the matrix, 1 number suffices
% Output: w  = Real valued density compensation [samples nspokes] with
%              values between 0 and 1.

dims=size(MR.Data);dims(5)=size(MR.Data,5); 
nsamples=dims(1);
ns=dims(2);
nz=dims(3);
tns=dims(2)*dims(5);
ndyn=dims(5);

w=zeros(nsamples,ns,nz,ndyn);
cp=nsamples/2+1;
%ktraj=reshape(MR.Parameter.Gridder.Kpos,[nsamples,tns,nz]);
ktraj=MR.Parameter.Gridder.Kpos;

switch MR.ParUMC.DCF
    case 'ram-lak'
        % Create a Ram-Lak filter
        w=zeros(nsamples,ns,nz,ndyn);
        for dyn=1:ndyn
            for s=1:ns
                w(:,s,nz,dyn)=2*abs(ktraj(:,s,1,dyn))/nsamples;
            end
        end
        
        % Normalize and deal with centerpoint (not equals 0)
        w=w/max(w(:));
        w(cp,:,1)=1/(2*nsamples);
        
    case 'ram-lak adaptive'
    % Create a modified ramp filter
    % d(phi,r)=abs(r) * (0.5*dphi_L*dphi_R)/pi 
    
    % Get radial angles from the trajectory
    angles=reshape(MR.Parameter.Gridder.RadialAngles,[ns ndyn]);
    
    % Create a angle list in range [0 pi]
    for dyn=1:ndyn
        for s=1:ns % Loop to unwrap the angles
            if angles(s,dyn)>pi;
                angles(s,dyn)=angles(s,dyn)-pi;
            end
        end
    end
    
    % Sort all angles so its easy to find neighbouring spokes
    s_angles=sort(angles);
    dphi_L=zeros(ns,ndyn);
    dphi_R=zeros(ns,ndyn);
    
    % Loop over all spokes per dynamic and find dphi_L / dphi_R
    for dyn=1:ndyn
        for s=1:ns
            [~,minpos]=min(abs(angles(s,dyn)-s_angles(:,dyn)));
            if minpos==1
                dphi_L(s,dyn)=abs(pi-s_angles(end,dyn));
                dphi_R(s,dyn)=abs(s_angles(minpos,dyn)-s_angles(2,dyn));
            elseif minpos==ns
                dphi_L(s,dyn)=abs(s_angles(minpos,dyn)-s_angles(minpos-1,dyn));
                dphi_R(s,dyn)=abs(s_angles(minpos,dyn)-pi);
            else
                dphi_L(s,dyn)=abs(s_angles(minpos,dyn)-s_angles(minpos-1,dyn));
                dphi_R(s,dyn)=abs(s_angles(minpos,dyn)-s_angles(minpos+1,dyn));
            end
        end
    end
    
    % Fill in the weights for every spoke
     w=zeros(nsamples,ns,nz,ndyn);
     for dyn=1:ndyn
         for s=1:ns
             w(:,s,nz,dyn)=abs(ktraj(:,s,nz,dyn)) * (0.5 * (dphi_L(s,dyn)+dphi_R(s,dyn)) / pi);
         end
     end
     
     % Assign center val and take square root.
     w=w/max(w(:));
     w(cp,:,1)=1/(2*nsamples);
     
     % Partition into dynamics
     w=reshape(w,[nsamples,ns,nz,ndyn]);
     
     % Ensure that every dynamic has the same total weight
    for dyn=1:ndyn
        currdyn=w(:,:,:,dyn);
        w(:,:,:,dyn)=w(:,:,:,dyn)/norm(currdyn(:),1);
    end
    w=w/max(w(:));
     
end

% END
end