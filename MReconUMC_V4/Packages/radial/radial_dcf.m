function w = radial_dcf(dims,varargin)
% Function to get analytical density functions for radial acquisitions.
% Input: Cell of k-space trajectory
% Output: Cell of density weights
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Set parameters from input
num_data=numel(dims);
for n=1:num_data;cp{n}=dims{n}(1)/2+1;end % k0

for n=1:num_data;
    % Create a Ram-Lak filter
    w{n}=ones(dims{n}(1),1);
    for i=1:dims{n}(1)
        w{n}(i)=abs(dims{n}(1)/2 - (i - .5));
    end
    w{n}=pi/(dims{n}(2)*dims{n}(5))*w{n};
    w{n}=w{n}/max(abs(w{n}(:)));
    
    % Partition into dynamics
    w{n}=single(repmat(w{n},[1 dims{n}(2) 1 1 dims{n}(5)]));
    
end

% END
end