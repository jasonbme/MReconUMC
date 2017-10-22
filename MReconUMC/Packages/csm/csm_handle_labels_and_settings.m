function store = csm_handle_labels_and_settings(MR,varargin)
%Function that handles label and settings when doing the nufft for the sensitivity mapping
% If nargin==1 then its the forward process, otherwise its the restoring
%
% 20170717 - T.Bruijnen

%% Logic
if strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'refscan')
     return;end
 
%% Handle labels and settings for nufft
if nargin==1 % Forward

	% Store raw data and nufft settings
	store={MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NufftSoftware,...
	    MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights,MR.Parameter.Gridder.Kpos,...
	    MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.Parameter.Scan.Samples,MR.UMCParameters.IterativeReconstruction.IterativeReconstruction};

	% Get dimensions for data handling
	dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;
	n=MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber; % What data chunk you want to use for csm generation
	  
	% Set different nufft settings
	MR.Parameter.Recon.CoilCombination='no';
	MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='no';
	MR.Parameter.Encoding.NrDyn=1;
	MR.Data={permute(reshape(permute(MR.Data{n}(:,:,:,:,:,:,1,:,:,:,:,:),[1 3 4 6:12 2 5]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6) 1 dims{n}(8:12) dims{n}(2)*dims{n}(5) 1]),...
	        [1 11 2 3 4:10 12])};MR.UMCParameters.AdjointReconstruction.KspaceSize={MR.UMCParameters.AdjointReconstruction.KspaceSize{n}};
            MR.UMCParameters.AdjointReconstruction.IspaceSize={MR.UMCParameters.AdjointReconstruction.IspaceSize{n}};
            MR.UMCParameters.AdjointReconstruction.KspaceSize{1}(2)=[dims{n}(2)*dims{n}(5)];
            MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(5)=1;MR.UMCParameters.AdjointReconstruction.KspaceSize{1}(5)=1;
            MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(7)=1;MR.UMCParameters.AdjointReconstruction.KspaceSize{1}(7)=1;

	% Some exceptions for the 'mrecon' gridder
	if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'reconframe')
        kd=size(MR.Parameter.Gridder.Kpos{n});kd(end+1:13)=1;
	    MR.Parameter.Gridder.Weights={ipermute(reshape(permute(MR.Parameter.Gridder.Weights{n}(:,:,:,:,:,:,1,:,:,:,:,:),[1 2 5 3 4 6:12]),[kd(2) kd(3)*kd(6) 1 kd(4) 1 kd(7) 1 kd(9:end)]),[1 2 5 3 4 6:12])};
	    MR.Parameter.Gridder.Kpos={ipermute(reshape(permute(MR.Parameter.Gridder.Kpos{n}(:,:,:,:,:,:,:,1,:,:,:,:,:),[1 2 3 6 4 5 7:13]),[3 kd(2) kd(3)*kd(6) 1 kd(4) 1 kd(7) 1 kd(9:end)]),[1 2 3 6 4 5 7:13])};end
	if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'reconframe');MR.Parameter.Scan.Samples=[dims{n}(1) dims{n}(2) dims{n}(3)];end      

	 % This flag is only important for fprintf notifications
	 MR.UMCParameters.ReconFlags.NufftCsmMapping=1; 

else % restoring operation

	 % This flag is only important for fprintf notifications
	 MR.UMCParameters.ReconFlags.NufftCsmMapping=1; 

	 % If number of dynamics == 1 and multi-echo is zero, we can still use the gridded data
     if varargin{1}{2}==1 && strcmpi(varargin{1}(10),'no') && MR.Parameter.Encoding.NrEchoes==1
     	varargin{1}{1}=MR.Data;MR.Parameter.ReconFlags.isimspace=[1 1 1];
        MR.Parameter.ReconFlags.isoversampled=[1,1,1];
	else; MR=set_gridding_flags(MR,0);end

     % Restore settings
     [MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NufftSoftware,...
        MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights,MR.Parameter.Gridder.Kpos,...
        MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.Parameter.Scan.Samples,MR.UMCParameters.IterativeReconstruction.IterativeReconstruction]=varargin{1}{:};

     % This flag is only important for fprintf notifications
	 MR.UMCParameters.ReconFlags.NufftCsmMapping=0; 
     
	 % Still need an output
	 store={};
end

% END
end