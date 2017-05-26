function SortData( MR )
% Sort data in the right dimensions and remove calibration data
% Data is structured as nx/ny/nz/nc/ndyn/echos/?/?/stacks/?/?

% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

% Run Sort from MRecon
SortData@MRecon(MR);

% If data is not in cell, transfer to cell
if ~iscell(MR.Data)
    MR.Data={MR.Data};
end

% Get dimensions for data handling
dims=cellfun(@size,MR.Data,'UniformOutput',false);num_data=numel(dims);
for n=1:num_data;dims{n}(numel(size(MR.Data{n}))+1:12)=1;end % Up to 12D

% Radial specific processing steps
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')

        % Remove calibration lines from all echos
        if MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes>0
            MR.UMCParameters.SystemCorrections.CalibrationData=MR.Data{:}(:,1:MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes,:,:,:,:,:,:,:,:,:,:);
            MR.Data=MR.Data{:}(:,MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes+1:end,:,:,:,:,:,:,:,:,:,:);
        end
        
        % Get dimensions for data handling (repeated after remove calibration
        dims=cellfun(@size,MR.Data,'UniformOutput',false);num_data=numel(dims);
        for n=1:num_data;dims{n}(numel(size(MR.Data{n}))+1:12)=1;end % Up to 12D

        % Golden angle specific operations 
        if MR.UMCParameters.AdjointReconstruction.Goldenangle>0 % 0 == uniform angle
            
             % Enforce the retrospective acceleration factor 
             MR.Parameter.Encoding.NrDyn=round(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.AdjointReconstruction.R);
             for n=1:num_data;dims{n}(5)=MR.Parameter.Encoding.NrDyn;end

             % Discard obselete spokes
             for n=1:num_data;dims{n}(2)=floor(dims{n}(2)/dims{n}(5));end % number of lines per dynamic
             for n=1:num_data;MR.Data{n}=MR.Data{n}(:,1:dims{n}(5)*dims{n}(2),:,:,:,:,:,:,:,:,:);end
  
             % Sort data in dynamics
             for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6 7 8 9 10 11 12 2 5]),...
                     [dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6:12) dims{n}(2) dims{n}(5)]),[1 11 2 3 12 4:10]);end
                  
             % Set geometry parameters
             MR=radial_geometry(MR);
             
             % Alternating is no
             MR.Parameter.Gridder.AlternatingRadial='no';
             
        else      % Data is already in right dimensions
             
             % Discard obselete spokes and enforce acceleration factor
             for n=1:num_data;dims{n}(2)=floor(dims{n}(2)/MR.UMCParameters.AdjointReconstruction.R); % number of lines per dynamic
             MR.Data{n}=MR.Data{n}(:,1:MR.UMCParameters.AdjointReconstruction.R:MR.UMCParameters.AdjointReconstruction.R*dims{n}(2),:,:,:,:,:,:,:,:,:,:);end
             
             % Sort data in dynamics
             for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6:12 2 5]),[dims{n}(1) dims{n}(3:4) dims{n}(6:12) dims{n}(2) dims{n}(5)]),[1 11 2 3 12 4:10]);end
             
             % Set geometry parameters
             MR=radial_geometry(MR);
        end
        
        % Store k-space and image dimensions in struct
        MR.UMCParameters.AdjointReconstruction.KspaceSize=dims;
        MR.UMCParameters.AdjointReconstruction.IspaceSize=dims;
        for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=[MR.Parameter.Encoding.XRes(n),MR.Parameter.Encoding.YRes(n),MR.Parameter.Encoding.ZRes(n)];end

        % Do 1D fft in z-direction for stack-of-stars & zero padding in z
        if (strcmpi(MR.Parameter.Scan.ScanMode,'3D') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon') && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'2D'))
            MR.Data=cellfun(@(v) fft(v,[],3),MR.Data,'UniformOutput',false);
            MR.Parameter.ReconFlags.isimspace=[0,0,1]; 
        end

end

% Prototype mode to reduce number of dynamics retrospectively
if MR.UMCParameters.AdjointReconstruction.PrototypeMode~=0
    for n=1:num_data;MR.Data{n}=MR.Data{n}(:,:,:,:,1:MR.UMCParameters.AdjointReconstruction.PrototypeMode,:,:,:,:,:,:,:);end
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.AdjointReconstruction.PrototypeMode;
    for n=1:num_data;MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;...
            MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;end
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end

