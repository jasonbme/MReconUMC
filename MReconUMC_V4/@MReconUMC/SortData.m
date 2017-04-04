function SortData( MR )
% Sort data in the right dimensions and remove calibration data
% Data is structured as nx/ny/nz/nc/ndyn/echos/?/?/stacks/?/?

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

% Run Sort from MRecon
SortData@MRecon(MR);

% Radial specific processing steps
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')

        % Remove calibration lines
        if MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes>0
            MR.UMCParameters.SystemCorrections.CalibrationData=permute(MR.Data(:,1:MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes,:,:),[1 2 3 4 5 6 7 8 9 10 11]);
            MR.Data=MR.Data(:,MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes+1:end,:,:,:,:,:,:,:,:,:);
        end
        
        % Get dimensions for data handling
        dims=size(MR.Data);dims(end+1:12)=1; % Data can be up to 11D

        % Store k-space and image dimensions in struct
        MR.UMCParameters.AdjointReconstruction.KspaceSize=dims;
        MR.UMCParameters.AdjointReconstruction.IspaceSize=[MR.Parameter.Encoding.XRes(1),MR.Parameter.Encoding.YRes(1),dims(3:11)];

        % Golden angle specific operations which uses a single dynamicnoise_prewhitening
        % acquisitions and retrospectively divides readouts across dynamics
        if MR.UMCParameters.AdjointReconstruction.Goldenangle>0 % 0 == uniform angle
            
             % Enforce the retrospective acceleration factor 
             if MR.UMCParameters.AdjointReconstruction.R ~= 1
                 MR.Parameter.Encoding.NrDyn=round(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.AdjointReconstruction.R);
                 dims(5)=MR.Parameter.Encoding.NrDyn;
             end

             % Discard obselete spokes
             dims(2)=floor(dims(2)/dims(5)); % number of lines per dynamic
             MR.Data=MR.Data(:,1:dims(5)*dims(2),:,:,:);
  
             % Sort data in dynamics
             MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5 6 7 8 9 10 11]),[dims(1) dims(3) dims(4) dims(2) dims(5:11)]),[1 4 2 3 5:11]);
             
             % Set geometry parameters
             MR=radial_geometry(MR);
             
             % Alternating is no
             MR.Parameter.Gridder.AlternatingRadial='no';
             
        else      % Data is already in right dimensions
             
             % Discard obselete spokes and enforce acceleration factor
             dims(2)=floor(dims(2)/MR.UMCParameters.AdjointReconstruction.R); % number of lines per dynamic
             MR.Data=MR.Data(:,1:MR.UMCParameters.AdjointReconstruction.R:MR.UMCParameters.AdjointReconstruction.R*dims(2),:,:,:);
             
             % Sort data in dynamics
             MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5:11]),[dims(1) dims(3:4) dims(2) dims(5:11)]),[1 4 2 3 5:11]);
             
             % Set geometry parameters
             MR=radial_geometry(MR);
        end

        % Do 1D fft in z-direction for stack-of-stars & zero padding in z
        if (strcmpi(MR.Parameter.Scan.ScanMode,'3D') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon'))
            MR.Data=fft(MR.Data,[],3);
            MR.Parameter.ReconFlags.isimspace=[0,0,1]; 
            MR.UMCParameters.AdjointReconstruction.KspaceSize(3)=size(MR.Data,3);
            MR.UMCParameters.AdjointReconstruction.IspaceSize(3)=size(MR.Data,3);
        end

end

% Prototype mode to reduce number of dynamics retrospectively
if MR.UMCParameters.AdjointReconstruction.PrototypeMode~=0
    MR.Data=MR.Data(:,:,:,:,1:MR.UMCParameters.AdjointReconstruction.PrototypeMode);
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.AdjointReconstruction.PrototypeMode;
    MR.UMCParameters.AdjointReconstruction.KspaceSize(5)=MR.Parameter.Encoding.NrDyn;
    MR.UMCParameters.AdjointReconstruction.IspaceSize(5)=MR.Parameter.Encoding.NrDyn;
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end

