function  fg = FG2D(k,Id,Kd,varargin)
% Modified for 12D reconframe data
% Based on Miki Lustig his nufft operator

% Verbose options
if nargin < 4
    fg.verbose=0;
else
    fg.verbose=1;
end

% Number of data chunks
num_data=numel(k);   

% Image space dimensions
fg.Id=Id;

% K-space dimensions
fg.Kd=Kd;

% Mix the readouts and samples in advance
for n=1:num_data;fg.k{n}=reshape(k{n},[3 Kd{n}(1)*Kd{n}(2) 1 1 1 Kd{n}(5:12)]);end;clear k 

% Input for nufft_init
Jd = [3,3];     % Kernel width of convolution
for n=1:num_data
    Nd{n}=Id{n}(1:2);
    Gd{n} = [Nd{n}*2];    % Overgridding ratio
    n_shift{n} = Nd{n}/2;
end

% Create a seperate struct for all the dimensions that need seperate trajectories
for n=1:num_data % Data chunks
for avg=1:Kd{n}(12) % Averages
for ex2=1:Kd{n}(11) % Extra2
for ex1=1:Kd{n}(10) % Extra1
for mix=1:Kd{n}(9)  % Locations
for loc=1:Kd{n}(8)  % Mixes
for ech=1:Kd{n}(7)  % Phases
for ph=1:Kd{n}(6)   % Echos
for dyn=1:Kd{n}(5)  % Dynamics
    om=[fg.k{n}(1,:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg); fg.k{n}(2,:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)]'*2*pi;
    fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg} = nufft_init(om, Nd{n}, Jd, Gd{n}, n_shift{n},'minmax:kb');
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Averages
end % Data chunks

fg.phase = 1;
fg.w=1;
fg.adjoint = 0;
fg.mode = 2;   % 2= complex image
fg=class(fg,'FG2D');

% end
end

