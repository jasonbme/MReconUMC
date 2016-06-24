function GetCoilMaps( MR )
% 20160616 - Estimate coil sensitivity maps by reconstructing a single
% dynamics from all the data, for simplicity this is always done by the 
% mrecon gridder. Subsequentially applying ESPIRiT to acquire the coil
% maps. Alternatively estimate the maps via sense ref scans.


if strcmpi(MR.ParUMC.GetCoilMaps,'espirit')
    ESPIRiT(MR);
end

if strcmpi(MR.ParUMC.GetCoilMaps,'mrsense')
    MRSenseUMC(MR);
end

% END
end