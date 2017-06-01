function fingerprinting_data_organizing( MR )
% Function to facilitate data organizing for fingerprinting sequences
% Perform undersampling adequatly

% Logic
if ~strcmpi(MR.Parameter.AdjointReconstruction.Fingerprinting,'yes')
	return;end

% Get dimensions for data handling 
dims=cellfun(@size,MR.Data,'UniformOutput',false);num_data=numel(dims);
for n=1:num_data;dims{n}(numel(size(MR.Data{n}))+1:12)=1;end % Up to 12D

% Radial undersampling for each timepoint
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
	 for n=1:num_data;dims{n}(2)=floor(dims{n}(2)/MR.UMCParameters.AdjointReconstruction.R); % number of lines per dynamic
     	MR.Data{n}=MR.Data{n}(:,1:size(MR.Data{n},2)/(dims{n}(2)-1):end,:,:,:,:,:,:,:,:,:,:);end;
end

% Reduction in number of timepoints
if numel(MR.UMCParameters.AdjointReconstruction.R)>1
	 for n=1:num_data;dims{n}(5)=MR.UMCParameters.AdjointReconstruction.R(2);
     	MR.Data{n}=MR.Data{n}(:,:,:,:,1:dims{n}(5),:,:,:,:,:,:,:);end;
end

% END
end