function kn = radial_trajectory(angles,dims,goldenangle,varargin)
% Input: Cell of angles and dimensions
% Output: Cell of k-space trajectory
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Get number of data chunks
num_data=numel(dims);

% Set parameters from input
for n=1:num_data
    if isempty(varargin{1})
        dk{n}=0;
    else
        dk{n}=repmat(((cos(2*(angles{n}+pi/2))+1)*varargin{1}(1)+(-cos(2*(angles{n}+pi/2))+1)*varargin{1}(2))/2,[dims{n}(1) 1]);
    end
end

if goldenangle==0  
    for n=1:num_data;
        % Calculate sampling point on horizontal spoke
        x=linspace(0,dims{n}(1)-1,dims{n}(1))'-(dims{n}(1)-1)/2;

        % Modulate the phase of all the successive spokes
        k{n}=zeros(dims{n}(1),dims{n}(2));
        for l=1:dims{n}(2)
            if mod(l,2) == 0 % iseven for alternating angles
                k{n}(1,:,l)=x*exp(1j*(angles{n}(l)+pi));
            else
                k{n}(:,l)=x*exp(1j*angles{n}(l));
            end
        end
        
        % Add correction
        k{n}=k{n}+(-1)*dk{n};
        
        % Normalize
        k{n}=k{n}/dims{n}(1);
        
        % Partition into dynamics and deal with nz
        k{n}=single(repmat(k{n},[1 1 1 1 dims{n}(5)]));
    end
             
end

if goldenangle>0     
    for n=1:num_data
        % Calculate sampling point on horizontal spoke
        x=linspace(0,dims{n}(1)-1,dims{n}(1))'-(dims{n}(1)-1)/2 ;
        
        % Modulate the phase of all the successive spokes
        k{n}=zeros(dims{n}(1),dims{n}(2)*dims{n}(5));
        for l=1:dims{n}(2)*dims{n}(5)
            k{n}(:,l)=x*exp(1j*angles{n}(l));
        end
        
        % Add correction
        k{n}=k{n}+(-1)*dk{n};
        
        % Normalize
        k{n}=k{n}/dims{n}(1);
        
         % Partition into dynamics
        k{n}=reshape(k{n},[dims{n}(1),dims{n}(2),1,1,dims{n}(5)]);      
        
        % Copy for nz
        k{n}=repmat(k{n},[1 1 1 1 1]);
    end
end

% Split real and imaginary parts into channels
for n=1:num_data;kn{n}(1,:,:,:,:,:,:,:,:,:,:,:)=real(k{n});...
        kn{n}(2,:,:,:,:,:,:,:,:,:,:,:)=imag(k{n});...
        kn{n}(3,:,:,:,:,:,:,:,:,:,:,:)=zeros([size(k{n})]);
end

% END
end