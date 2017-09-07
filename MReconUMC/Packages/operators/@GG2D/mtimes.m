function res = mtimes(gg,data) 
% Greengard 2D NUFFT operator working on 12D reconframe data
% Data and kspace come in as cells, which represent different data chunks
% Try indexing in parfor loop only on first entry, probably saves speed
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 


% Set parameters
num_data=numel(gg.k);
eps=gg.precision; 

% Preallocate response cell
res={};
        
% Define number of gridding steps
n_steps=0;
for n=1:num_data;n_steps=n_steps+prod(gg.Kd{n}(3:end));end

% Track progress
if gg.verbose;parfor_progress(n_steps);end

% Loop over the data chunks
for n=1:num_data;
    
    % Check what dimensions require new trajectory coordinates
    Id=gg.Id{n};
    Kd=gg.Kd{n};

    if gg.adjoint==-1 % NUFFT^(-1)
        % non-Cartesian k-space to Cartesian image domain || type 1
        
        % Reshape data that goes together into the nufft operator
        data{n}=reshape(data{n},[Kd(1)*Kd(2) Kd(3:end)]);

        % Get number of k-space points per chunk
        nj=gg.nj{n};
        
        % Loop over all dimensions and update k if required
        % For now I assumed that different Z always has the same trajectory
        for avg=1:Kd(12) % Averages
        for ex2=1:Kd(11) % Extra2
        for ex1=1:Kd(10) % Extra1
        for mix=1:Kd(9)  % Locations
        for loc=1:Kd(8)  % Mixes
        for ech=1:Kd(7)  % Phases
        for ph=1:Kd(6)   % Echos
        for dyn=1:Kd(5)  % Dynamics
        for z=1:Kd(3)    % Slices (2D)

            % Convert data to doubles, required for the function
            data_tmp=double(data{n}(:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));

            % Select k-space trajectory
            k_tmp=gg.k{n}(1:2,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

            % Preallocate res_tmp
            res_tmp=zeros(prod(gg.Id{n}(1:2)),gg.Id{n}(4));
            
            % Parallize over the receivers (always has same traj)
            if ~gg.parfor
                for coil=1:Kd(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft2d1(nj,k_tmp(2,:),...
                        k_tmp(1,:),data_tmp(:,:,coil),-1,eps,Id(1),Id(2)))*sqrt(prod(gg.Id{n}(1:2)));
                    
                    % Track progrss
                    if gg.verbose;parfor_progress;end
                end
            else
                parfor coil=1:Kd(4)
                    % Save in temporarily matrix, saves indexing time
                    res_tmp(:,coil)=matrix_to_vec(nufft2d1(nj,k_tmp(2,:),...
                        k_tmp(1,:),data_tmp(:,:,coil),-1,eps,Id(1),Id(2)))*sqrt(prod(gg.Id{n}(1:2)));
                    
                    % Track progrss
                    if gg.verbose;parfor_progress;end
                end
            end

            % Store output from all receivers
            res{n}(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,Id([1:2 4]));
            
        end % Slices
        end % Dynamics
        end % Echos
        end % Phases
        end % Mixes
        end % Locations
        end % Extra1
        end % Extra2
        end % Averages
        
    else         % Cartesian image domain to non-Cartesian k-space || type 2

        % Preallocate response cell
        res={};

        % Get number of k-space points per chunk
        nj=gg.nj{n};
        
        % Loop over all dimensions and update k if required
        % For now I assumed that different Z always has the same trajectory
        for avg=1:Kd(12) % Averages
        for ex2=1:Kd(11) % Extra2 
        for ex1=1:Kd(10) % Extra1
        for mix=1:Kd(9)  % Locations
        for loc=1:Kd(8)  % Mixes
        for ech=1:Kd(7)  % Phases
        for ph=1:Kd(6)   % Echos
        for dyn=1:Kd(5)  % Dynamics
        for z=1:Kd(3)    % Slices (2D)

                % Convert data to doubles, required for the function
                data_tmp=double(data{n}(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));

                % Select k-space trajectory
                k_tmp=gg.k{n}(1:2,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

                % Preallocate res_tmp
                res_tmp=zeros(prod(gg.Kd{n}(1:2)),gg.Id{n}(4));
            
                % Parallize over the receivers (always has same traj)
                if ~gg.parfor
                    for coil=1:Kd(4)
                        % Save in temporarily matrix, saves indexing time
                        res_tmp(:,coil)=matrix_to_vec(nufft2d2(nj,k_tmp(2,:),...
                            k_tmp(1,:),1,eps,Id(1),Id(2),data_tmp(:,:,:,coil)))/sqrt(prod(gg.Id{n}(1:2)));
                    end
                else
                    parfor coil=1:Kd(4)
                        % Save in temporarily matrix, saves indexing time
                        res_tmp(:,coil)=matrix_to_vec(nufft2d2(nj,k_tmp(2,:),...
                            k_tmp(1,:),1,eps,Id(1),Id(2),data_tmp(:,:,:,coil)))/sqrt(prod(gg.Id{n}(1:2)));
                    end
                end

                % Store output from all receivers
                res{n}(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,Kd([1:2 4]));
                
        end % Slices
        end % Dynamics
        end % Echos
        end % Phases
        end % Mixes
        end % Locations
        end % Extra1
        end % Extra2
        end % Averages
    end
end

% Reset progress file
if gg.verbose;parfor_progress(0);end

% END  
end  

