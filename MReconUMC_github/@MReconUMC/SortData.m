function SortData( MR )
% Sort data in the right dimensions and remove calibration data

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

% Run Sort from MRecon
SortData@MRecon(MR);

% Radial specific processing steps
switch lower(MR.Parameter.Scan.AcqMode)
    case 'radial'
        
        % Remove calibration lines
        if MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes>0
            MR.UMCParameters.SystemCorrections.CalibrationData=permute(MR.Data(:,1:MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes,:,:),[1 2 3 4 5]);
            MR.Data=MR.Data(:,MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes+1:end,:,:,:);
        end
        
        % Get dimensions for data handling
        [ns,nl,nz,nc,ndyn]=size(MR.Data); % n samples, n lines ...

        % Golden angle specific operations
        if MR.UMCParameters.LinearReconstruction.Goldenangle>0
            
             % Enforce the acceleration factor
             if MR.UMCParameters.LinearReconstruction.R ~= 1
                 MR.Parameter.Encoding.NrDyn=round(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.LinearReconstruction.R);
             end
             ndyn=MR.Parameter.Encoding.NrDyn;

             % Discard obselete spokes
             nl=floor(nl/ndyn); % number of lines per dynamic
             MR.Data=MR.Data(:,1:ndyn*nl,:,:,:);
  
             % Sort data in dynamics
             MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
             
             % Set geometry parameters
             MR=RadialGeometry(MR);
        end

        % Do 1D fft in z-direction for stack-of-stars & zero padding in z
        if (strcmpi(MR.Parameter.Scan.ScanMode,'3D') && ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon'))
            %npad=(floor(MR.Parameter.Encoding.KzOversampling*nz)-nz)/2;
            %MR.Data=cat(3,zeros(ns,nl,npad,nc,ndyn),MR.Data,zeros(ns,nl,npad,nc,ndyn));
            MR.Data=fft(MR.Data,[],3);
            MR.Parameter.ReconFlags.isimspace=[0,0,1];
            MR.UMCParameters.LinearReconstruction.KspaceSize(3)=size(MR.Data,3);
            MR.UMCParameters.LinearReconstruction.IspaceSize(3)=size(MR.Data,3);
        end

end

% Prototype mode to reduce number of dynamics
if MR.UMCParameters.LinearReconstruction.PrototypeMode~=0
    MR.Data=MR.Data(:,:,:,:,1:MR.UMCParameters.LinearReconstruction.PrototypeMode);
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.LinearReconstruction.PrototypeMode;
    MR.UMCParameters.LinearReconstruction.KspaceSize(5)=MR.Parameter.Encoding.NrDyn;
    MR.UMCParameters.LinearReconstruction.IspaceSize(5)=MR.Parameter.Encoding.NrDyn;
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end

