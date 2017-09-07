function res = mtimes(fg,data)
% Perform the 3D NUFFT

% Set parameters
num_data=numel(data);

% Define number of gridding steps
n_steps=0;
for n=1:num_data;n_steps=n_steps+prod(fg.Kd{n}(4:end));end

% Track progress
if fg.verbose;parfor_progress(n_steps);end
        
% Preallocate response cell
res={};

if fg.adjoint 
	for n=1:num_data           % Data chunks
        
    % Check what dimensions require new trajectory coordinates
    Id=fg.Id{n};
    Kd=fg.Kd{n};

	for avg=1:size(data{n},12) % Averages
	for ex2=1:size(data{n},11) % Extra2
	for ex1=1:size(data{n},10) % Extra1
	for mix=1:size(data{n},9)  % Locations
	for loc=1:size(data{n},8)  % Mixes
	for ech=1:size(data{n},7)  % Phases
	for ph=1:size(data{n},6)   % Echos
	for dyn=1:size(data{n},5)  % Dynamics
        
        % Convert data to doubles, required for the function
        data_tmp=double(data{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        
        % Preallocate temporary matrix
        res_tmp=zeros([Id(1:3) Id(4)]);
        
        % Parallize over the receivers (always has same traj)
        if ~fg.parfor
            for coil=1:size(data{n},4) % Coils
                % Do the nufft
                res_tmp(:,:,:,coil)=...
                    nufft_adj(matrix_to_vec(data_tmp(:,:,:,coil)),...
                    fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3)));
                
                    % Track progress
                    if fg.verbose;parfor_progress;end
                        
            end % Coils
        else
            parfor coil=1:size(data{n},4) % Coils
                % Do the nufft
                res_tmp(:,:,:,coil)=...
                    nufft_adj(matrix_to_vec(data_tmp(:,:,:,coil)),...
                    fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3)));
                
                     % Track progress
                    if fg.verbose;parfor_progress;end
            end % Coils
        end
    
        % Store output from all receivers   
        res{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=res_tmp;
        
	end % Dynamics
	end % Echos
	end % Phases
	end % Mixes
	end % Locations
	end % Extra1
	end % Extra2
	end % Averages
	end % Data chunks

else

	for n=1:numel(data)     % Data chunks
            % Check what dimensions require new trajectory coordinates
            Id=fg.Id{n};
            Kd=fg.Kd{n};
	for avg=1:size(data{n},12) % Averages
	for ex2=1:size(data{n},11) % Extra2
	for ex1=1:size(data{n},10) % Extra1
	for mix=1:size(data{n},9)  % Locations
	for loc=1:size(data{n},8)  % Mixes
	for ech=1:size(data{n},7)  % Phases
	for ph=1:size(data{n},6)   % Echos
	for dyn=1:size(data{n},5)  % Dynamics
        
         % Convert data to doubles, required for the function
        data_tmp=double(data{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        
        % Preallocate temporary matrix
        res_tmp=zeros([prod(Kd(1:3)) Id(4)]);
        
        % Parallize over the receivers (always has same traj)
        if ~fg.parfor
            for coil=1:size(data{n},4) % Coils
                % Forward operator
                res_tmp(:,coil)=...
                    nufft(reshape(data_tmp(:,:,:,coil),fg.Id{n}(1:3)),...
                    fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3))); 
            end % Coils
        else
            parfor coil=1:size(data{n},4) % Coils
                % Forward operator
                res_tmp(:,coil)=...
                    nufft(reshape(data_tmp(:,:,:,coil),fg.Id{n}(1:3)),...
                    fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3))); 
            end % Coils
        end

	    % Store output from all receivers
	    res{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,fg.Kd{n}([1:4]));

	end % Dynamics
	end % Echos
	end % Phases
	end % Mixes
	end % Locations
	end % Extra1
	end % Extra2
	end % Averages
	end % Data chunks

% Reset progress file
if fg.verbose;parfor_progress(0);end

end

