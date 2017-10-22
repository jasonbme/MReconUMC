function SortData( MR )
%Reconframe's sortdata function is executed first. Then the data is transformed 
% into a cell in all cases. For multi-echo data this is required and for the sake
% of generality I decided to process everything in cells. Further the data
% is re-organized for example for golden angle radial acquisitions. The
% data is ordered according to the reconframe dimensions which are up to 12
% D. The structure is [kx/x,ky/y,kz/z,c,dyn,ph,ech,mix,loc,ex1,ex2,avg], with
% kx/x=trajectory or spatial dimensions, c=coils, dyn=dynamics, ph=phases(flow),
% ech=mulitple echoes, mix = ?, loc=locations, ex1=?, ex2=?, avg=averages.
%
% 20170717 - T.Bruijnen

%% Logic & display
% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Sorting imaging and calibration data..............  ');tic

%% SortData
% Run Sort from MRecon
SortData@MRecon(MR);

% If data is not in cell, transform to cell
if ~iscell(MR.Data)
    MR.Data={MR.Data};
end

% Radial specific data organizing steps
radial_data_organizing(MR);

% Fingerprinting specific data organizing steps
fingerprinting_data_organizing(MR);

% EPI reorganizing phase encode lines
epi_data_organizing(MR);

% For cartesian sampling I require an fftshift across the phase encodes
if strcmpi(MR.Parameter.Scan.AcqMode,'Cartesian')
    for n=1:numel(MR.Data);MR.Data{n}=fftshift(MR.Data{n},1);end;end
    
% Prototype mode to reduce number of dynamics retrospectively
if MR.UMCParameters.AdjointReconstruction.PrototypeMode~=0
    num_data=numel(MR.Data);
    for n=1:num_data;MR.Data{n}=MR.Data{n}(:,:,:,:,1:MR.UMCParameters.AdjointReconstruction.PrototypeMode,:,:,:,:,:,:,:);end
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.AdjointReconstruction.PrototypeMode;
    for n=1:num_data;MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;...
            MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=MR.Parameter.Encoding.NrDyn;end
end

% Set geometry related parameters
set_geometry_parameters(MR);

%% Display
% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end

