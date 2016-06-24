function k = RadialTrajectory(MR,varargin)

if nargin>1
    vis=1;
else
    vis=0;
end

switch lower(MR.ParUMC.ProfileSpacing)
    case 'uniform'
        dims=size(MR.Data);
        dims(5)=size(MR.Data,5); 
        ns=dims(2);
        nz=dims(3);
        nsamples=dims(1);
        ndyn=dims(5);
        d_angle=pi/(ns);

        % Calculate angles
        angles=pi/2:d_angle:pi-d_angle+pi/2;

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
        
        if vis==1
            if ns > 25
                factor=floor(ns/25);
                ns=25;
            end
            f1=figure;
            set(f1,'position',[1 527 636 418])
            for j=1:ns
                scatter(real(k(:,1+j*(factor-1))),imag(k(:,1+j*(factor-1))));hold on;
                title('Uniform k-space traj (not all spokes)');
                xlabel('kx');ylabel('ky')
            end
        end
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
        %samples=complex([(.5-d_samples:d_samples:0), (d_samples:d_samples:-.5)]);
        samples=complex([(.5:d_samples:0), (d_samples:d_samples:-.5-d_samples)]);
        
        % Modulate the phase of all the successive spokes
        k=zeros(nsamples,tns,nz); 
        for j=1:tns
            k(:,j,1)=samples*exp(1j*angles(j));
        end

         % Partition into dynamics
        k=reshape(k,[nsamples,ns,nz,ndyn]);
        
end


% END
end