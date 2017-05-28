function stores = csm_handle_labels_and_settings(MR,varargin)
% Function that handles label and settings when doing the nufft for the sensitivity mapping
% If nargin==1 then its the forward process, otherwise its the restoring

% Logic
if strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'refscan')
     return;end

if nargin==1 % Forward

	% Store raw data and nufft settings
	store={MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
	    MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights,MR.Parameter.Gridder.Kpos,...
	    MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples,MR.UMCParameters.IterativeReconstruction.IterativeReconstruction};

	% Get dimensions for data handling
	dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);
	necho=MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber; % What echo you want to use for csm generation
	  
	% Set different nufft settings
	MR.Parameter.Recon.CoilCombination='no';
	MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='no';
	MR.Parameter.Encoding.NrDyn=1;
	for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6:12 2 5]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6:12) dims{n}(2)*dims{n}(5) 1]),...
	        [1 11 2 3 4:10 12]);MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(2)=[dims{n}(2)*dims{n}(5)];MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=1;end

	% Some exceptions for the 'mrecon' gridder
	if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
	    MR.Parameter.Gridder.Weights={permute(reshape(permute(MR.Parameter.Gridder.Weights{necho},[1 2 5 3 4]),[dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};
	    MR.Parameter.Gridder.Kpos={permute(reshape(permute(MR.Parameter.Gridder.Kpos{necho},[1 2 3 6 4 5]),[3 dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};end
	if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Scan.Samples=[dims{necho}(1) dims{necho}(2) dims{necho}(3)];end      

	 % This flag is only important for fprintf notifications
	 MR.UMCParameters.ReconFlags.nufft_csmapping=1; 

else % restoring operation

	 % This flag is only important for fprintf notifications
	 MR.UMCParameters.ReconFlags.nufft_csmapping=1; 

	 % If number of dynamics == 1, we can still use the gridded data
     if store{2}==1 
     	store{1}=MR.Data;MR.Parameter.ReconFlags.isimspace=[1 1 1];
        MR.Parameter.ReconFlags.isoversampled=[1,1,1];
	else; MR=set_gridding_flags(MR,0);end

     % Restore settings
     [MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
        MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights,MR.Parameter.Gridder.Kpos,...
        MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples,MR.UMCParameters.IterativeReconstruction.IterativeReconstruction]=store{:};

	 % Still need an output
	 store={};
end

% END
end