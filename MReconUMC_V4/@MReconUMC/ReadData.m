function ReadData( MR )

% Seperate noise data if required
if strcmpi(MR.UMCParameters.SystemCorrections.NoisePreWhitening,'yes')
    % Read & save noise data
    MR.Parameter.Parameter2Read.typ=5;
    ReadData@MRecon(MR);
    MR.UMCParameters.SystemCorrections.NoiseData=MR.Data;
end

% Run Sort from MRecon
MR.Parameter.Parameter2Read.typ=1;
ReadData@MRecon(MR);

% END
end

