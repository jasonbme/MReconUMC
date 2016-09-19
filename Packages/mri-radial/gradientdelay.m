function delayed_kdata = gradientdelay(kdata,ktraj,varargin)
% Add a sinusoidal varying translation to each spoke in the frequency
% domain. According to "Simple method for adaptive gradient delay compensation
% in radial MRI".

% Get radial angles from the trajectory
angles=angle(ktraj(1,:));
[ns nl]=size(kdata);

% Set parameters for the model according to input or default.
if numel(varargin)>0
    if numel(varargin)==1
        shift_x=varargin{1};
        shift_y=shift_x;
    else
        shift_x=varargin{1};
        shift_y=varargin{2};
    end
else
    shift_x=1.1;
    shift_y=0.6;
end

dk=@(theta)((cos(2*theta)+1)*shift_x+(-1*cos(2*theta)+1)*shift_y)/2;
d_shift=dk(angles);

% Apply shift in time domain
img=ifft2c(kdata);

%% Applying this shift part

% Create matrix to do correction with
for l=1:nl
    shift=d_shift(l);
    pcmatrix(:,l)=exp(2*1i*(polyval([-1*shift*pi/ns 0],-ns/2+1:ns/2)/2)');
end

% Apply correction
img=img.*pcmatrix;
delayed_kdata=fft2c(img);

% END
end