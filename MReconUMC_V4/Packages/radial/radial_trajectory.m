function k = radial_trajectory(angles,dims,goldenangle,varargin)

% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
if isempty(varargin{1})
    dk=0;
else
    dk=repmat(((cos(2*(angles+pi/2))+1)*varargin{1}(1)+(-cos(2*(angles+pi/2))+1)*varargin{1}(2))/2,[dims(1) 1]);
end

if goldenangle==0  
        % Calculate sampling point on horizontal spoke
        x=linspace(0,dims(1)-1,dims(1))'-(dims(1)-1)/2;

        % Modulate the phase of all the successive spokes
        k=zeros(dims(1),dims(2));
        for l=1:dims(2)
            if mod(l,2) == 0 % iseven for alternating angles
                k(:,l)=x*exp(1j*(angles(l)+pi));
            else
                k(:,l)=x*exp(1j*angles(l));
            end
        end
        
        % Add correction
        k=k+(-1)*dk;
        
        % Normalize
        k=k/dims(1);
        
        % Partition into dynamics and deal with nz
        k=repmat(k,[1 1 1 1 dims(5)]);
               
end

if goldenangle>0        
        % Calculate sampling point on horizontal spoke
        x=linspace(0,dims(1)-1,dims(1))'-(dims(1)-1)/2 ;
        
        % Modulate the phase of all the successive spokes
        k=zeros(dims(1),dims(2)*dims(5));
        for l=1:dims(2)*dims(5)
            k(:,l)=x*exp(1j*angles(l));
        end
        
        % Add correction
        k=k+(-1)*dk;
        
        % Normalize
        k=k/dims(1);
        
         % Partition into dynamics
        k=reshape(k,[dims(1),dims(2),1,1,dims(5)]);      
        
        % Copy for nz
        k=repmat(k,[1 1 1 1 1]);
end

% END
end