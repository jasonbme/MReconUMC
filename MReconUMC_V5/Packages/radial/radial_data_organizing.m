function radial_data_organizing( MR )
% Function to organize in particular golden angle radial data

% Logic
if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.UMCParameters.Fingerprinting.Fingerprinting,'yes')
	return;end

% Remove calibration lines from all echos
if MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes>0
    MR.UMCParameters.SystemCorrections.CalibrationData=MR.Data{:}(:,1:MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes,:,:,:,:,:,:,:,:,:,:);
    MR.Data=cellfun(@(x) x(:,MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes+1:end,:,:,:,:,:,:,:,:,:,:),MR.Data,'UniformOutput',false);end

% Get dimensions for data handling (repeated after remove calibration)
dims=cellfun(@size,MR.Data,'UniformOutput',false);num_data=numel(dims);
for n=1:num_data;dims{n}(numel(size(MR.Data{n}))+1:12)=1;end % Up to 12D

% Golden angle radial specific operations 
if MR.UMCParameters.AdjointReconstruction.Goldenangle > 0  

	 % Reorganize dynamics and ky dimensions due to the continues acquisition scheme and do undersampling (R)
	 for n=1:num_data;dims{n}(5)=floor(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.AdjointReconstruction.R);
     	dims{n}(2)=floor(dims{n}(2)/dims{n}(5)); % number of lines per dynamic
     	MR.Data{n}=MR.Data{n}(:,1:dims{n}(5)*dims{n}(2),:,:,:,:,:,:,:,:,:);end 

     % Sort data in dynamics
     for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6 7 8 9 10 11 12 2 5]),...
             [dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6:12) dims{n}(2) dims{n}(5)]),[1 11 2 3 12 4:10]);end
          
     % Alternating is no, hardcoded in ppe
     MR.Parameter.Gridder.AlternatingRadial='no';
end

% Undersampling for uniform radial
if MR.UMCParameters.AdjointReconstruction.Goldenangle==0 && MR.UMCParameters.AdjointReconstruction.R>1
     for n=1:num_data;dims{n}(2)=floor(dims{n}(2)/MR.UMCParameters.AdjointReconstruction.R); % number of lines per dynamic
     	MR.Data{n}=MR.Data{n}(:,1:size(MR.Data{n},2)/(dims{n}(2)-1):end,:,:,:,:,:,:,:,:,:,:);end;
end
 
% END
end