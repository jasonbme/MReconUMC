function SortData( MR )
% Sort data in the right dimensions and remove calibration data

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

% Run Sort from MRecon
SortData@MRecon(MR);

% Seperate noise data if required
if strcmpi(MR.UMCParameters.SystemCorrections.NoisePreWhitening,'yes')
    MR.UMCParameters.SystemCorrections.NoiseData=MR.Data{5};
    MR.Data=MR.Data{1};
    MR.Parameter.Parameter2Read.typ=1;
end

% Radial specific processing steps
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')

        % Remove calibration lines
        if MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes>0
            MR.UMCParameters.SystemCorrections.CalibrationData=permute(MR.Data(:,1:MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes,:,:),[1 2 3 4 5]);
            MR.Data=MR.Data(:,MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes+1:end,:,:,:);
        end
        
        % Get dimensions for data handling
        [ns,nl,nz,nc,ndyn]=size(MR.Data); % n samples, n lines ...

        % Store k-space and image dimensions in struct
        MR.UMCParameters.AdjointReconstruction.KspaceSize=[size(MR.Data,1) size(MR.Data,2) size(MR.Data,3) size(MR.Data,4) size(MR.Data,5)];
        MR.UMCParameters.AdjointReconstruction.IspaceSize=[MR.Parameter.Encoding.XRes(1),MR.Parameter.Encoding.YRes(1),size(MR.Data,3),size(MR.Data,4),size(MR.Data,5)];

        % Golden angle specific operations which uses a single dynamicnoise_prewhitening
        % acquisitions and retrospectively divides readouts across dynamics
        if MR.UMCParameters.AdjointReconstruction.Goldenangle>0 % 0 == uniform angle
            
             % Enforce the retrospective acceleration factor 
             if MR.UMCParameters.AdjointReconstruction.R ~= 1
                 MR.Parameter.Encoding.NrDyn=round(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.AdjointReconstruction.R);
                 ndyn=MR.Parameter.Encoding.NrDyn;
             end

             % Discard obselete spokes
             nl=floor(nl/ndyn); % number of lines per dynamic
             MR.Data=MR.Data(:,1:ndyn*nl,:,:,:);
  
             % Sort data in dynamics
             MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
             
             % Set geometry parameters
             MR=radial_geometry(MR);
             
             % Alternating is no
             MR.Parameter.Gridder.AlternatingRadial='no';
             
        else      % Data is already in right dimensions
             
             % Discard obselete spokes and enforce acceleration factor
             nl=floor(nl/MR.UMCParameters.AdjointReconstruction.R); % number of lines per dynamic
             MR.Data=MR.Data(:,1:MR.UMCParameters.AdjointReconstruction.R:MR.UMCParameters.AdjointReconstruction.R*nl,:,:,:);
             
             % Sort data in dynamics
             MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
             
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

