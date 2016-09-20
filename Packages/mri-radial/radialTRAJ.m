function k = radialTRAJ(angles,Kdim,distribution,varargin)

% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
dim=num2cell(Kdim);
[ns,nl,nz,~,ndyn]=deal(dim{:});

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
        
        % Partition into dynamics and deal with nz
        k=repmat(k,[1 1 nz 1 ndyn]);
               
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
        
        % Copy for nz
        k=repmat(k,[1 1 nz 1 1]);
end

% END
end