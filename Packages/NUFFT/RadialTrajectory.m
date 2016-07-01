function k = RadialTrajectory(MR)

switch lower(MR.ParUMC.ProfileSpacing)
    
    case 'golden'
        dims=size(MR.Data);dims(5)=size(MR.Data,5); 
        tns=dims(2)*dims(5);
        ns=dims(2);
        nz=dims(3);
        nsamples=dims(1);
        ndyn=dims(5);
        
        % Get angle increment, (tiny) golden angle
        GA=@(n)(pi/((1+sqrt(5))/2+n-1));
        d_angle=GA(MR.ParUMC.Goldenangle);
        
        % Calculate angles
        angles=-pi/2:d_angle:(tns-1)*d_angle-pi/2;
        
        % Calculate sampling point on horizontal spoke
        d_samples=-1/(nsamples);
        samples=complex([(.5:d_samples:0), (d_samples:d_samples:-.5-d_samples)]);
        
        % Modulate the phase of all the successive spokes
        k=zeros(nsamples,tns); 
        for s=1:tns
            k(:,s)=samples*exp(1j*angles(s));
        end

         % Partition into dynamics
        k=permute(reshape(permute(repmat(k,[1 1 nz ]),[1 3 2]),[nsamples,nz,ns,ndyn]),[1 3 2 4]);
        
    case 'uniform'
        dims=size(MR.Data);dims(5)=size(MR.Data,5); 
        ns=dims(2);
        nz=dims(3);
        nsamples=dims(1);
        ndyn=dims(5);
        
        % Calculate angles
        d_angle=pi/(ns);
        angles=0:d_angle:pi-d_angle;
        
        % Calculate sampling point on horizontal spoke
        d_samples=-1/(nsamples);
        samples=complex([(.5:d_samples:0), (d_samples:d_samples:-.5-d_samples)]);
        
        % Modulate the phase of all the successive spokes
        k=zeros(nsamples,ns,nz);
        for j=1:ns
            if mod(j,2) == 0 % iseven for alternating angles
                k(:,j,1)=samples*exp(1j*(angles(j)+pi));
            else
                k(:,j,1)=samples*exp(1j*angles(j));
            end
        end
        
        % Partition into dynamics, all dynamics are equal
        k=repmat(k,[1 1 1 ndyn]);
end

% END
end