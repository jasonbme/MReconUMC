function epi_data_organizing(MR)
% Invert even/odd phase encode lines to allign with GIRF trajectory

% Logic
if ~strcmpi(MR.Parameter.Scan.Technique,'FEEPI')  
	return;end

% Flip samples on readouts for every odd line
num_data=numel(MR.Data);
for n=1:num_data
   MR.Data{n}(:,1:2:end,:,:,:,:,:,:,:,:,:,:)=flip(MR.Data{n}(:,1:2:end,:,:,:,:,:,:,:,:,:,:),1); 
end

% END
end