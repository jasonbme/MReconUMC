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

% Get dimensions for data handling
dims=cellfun(@size,MR.Data,'UniformOutput',false);num_data=numel(dims);
for n=1:num_data;dims{n}(numel(size(MR.Data{n}))+1:12)=1;end % Up to 12D

% Radial specific processing steps
radial_data_organizing(MR);

% Store k-space and image dimensions in struct
MR.UMCParameters.AdjointReconstruction.KspaceSize=dims;
MR.UMCParameters.AdjointReconstruction.IspaceSize=dims;
for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=[MR.Parameter.Encoding.XRes(n),MR.Parameter.Encoding.YRes(n),MR.Parameter.Encoding.ZRes(n)];end

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

