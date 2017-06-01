function SortData( MR )
% Sort data in the right dimensions and remove calibration data
% Data is structured as nx/ny/nz/nc/ndyn/ph/echos/loc/ex1/ex2/avg/?

% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

% Run Sort from MRecon
SortData@MRecon(MR);

% If data is not in cell, transform to cell
if ~iscell(MR.Data)
    MR.Data={MR.Data};
end

% Radial specific data organizing  steps
radial_data_organizing(MR);

% Fingerprinting specific data organizing steps
fingerprinting_data_organizing(MR);

% Set geometry related parameters
set_geometry_parameters(MR);

% Prototype mode to reduce number of dynamics retrospectively
if MR.UMCParameters.AdjointReconstruction.PrototypeMode~=0
    num_data=numel(MR.Data);
    for n=1:num_data;MR.Data{n}=MR.Data{n}(:,:,:,:,1:MR.UMCParameters.AdjointReconstruction.PrototypeMode,:,:,:,:,:,:,:);end
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.AdjointReconstruction.PrototypeMode;
    for n=1:num_data;MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;...
            MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;end
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end

