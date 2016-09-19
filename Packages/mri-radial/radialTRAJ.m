function k = radialTRAJ(angles,Rdim,distribution,varargin)
% Input: R = Acceleration factor
%        Rdim = Size of the image in image domain
%        distribution = 'uniform' or 'golden'
% Output: k  = Complex valued trajectory in dimensions [samples spokes]
%              normalised in [0.5 -0.5]
%
% Notes: ky=0 & kx~=0 is defined as angle 0 [deg]. Ky is imaginary
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
ns=Rdim(1);nl=Rdim(2);ndyn=Rdim(5);

if strcmpi(distribution,'uniform')   
        % Calculate sampling point on horizontal spoke
        d_x=-1/(ns);
        x=complex([(.5:d_x:0), (d_x:d_x:-.5-d_x)]);

        % Modulate the phase of all the successive spokes
        k=zeros(ns,nl);
        for l=1:nl
            if mod(l,2) == 0 % iseven for alternating angles
                k(:,l)=x*exp(1j*(angles(l)+pi));
            else
                k(:,l)=x*exp(1j*angles(l));
            end
        end
        
        % Partition into dynamics
        k=repmat(k,[1 1 1 1 ndyn]);
end

if strcmpi(distribution,'golden')         
        % Calculate sampling point on horizontal spoke
        d_x=-1/(ns);
        x=complex([(.5:d_x:0), (d_x:d_x:-.5-d_x)])';
        
        % Modulate the phase of all the successive spokes
        k=zeros(ns,nl*ndyn);
        for l=1:nl*ndyn
            k(:,l)=x*exp(1j*angles(l));
        end

         % Partition into dynamics
        k=reshape(k,[ns,nl,1,1,ndyn]);      
end

% END
end