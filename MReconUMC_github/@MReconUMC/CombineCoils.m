function CombineCoils( MR )
%% Performs SOS or Roemer coil combination

if strcmp(MR.UMCParameters.LinearReconstruction.CombineCoils,'yes')
    if isempty(MR.UMCParameters.LinearReconstruction.CombineCoilsOperator)
        CombineCoils@MRecon(MR);
    else
        MR.Data=MR.UMCParameters.LinearReconstruction.CombineCoilsOperator*MR.Data;
    end
end

% END
end