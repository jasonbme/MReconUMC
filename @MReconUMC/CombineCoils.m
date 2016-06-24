function CombineCoils( MR )
% 20160616 - Performs SOS or Roemer coil combination, depending on the
% availability of coil maps.

if strcmp(MR.ParUMC.EnableCombineCoils,'yes')
    if isempty(MR.ParUMC.Sense)
        CombineCoils@MRecon(MR);
    else
        MR.Data=MR.ParUMC.Sense*MR.Data;
    end
end

% END
end