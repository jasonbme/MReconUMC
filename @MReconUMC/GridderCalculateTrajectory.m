function GridderCalculateTrajectory( MR )
% Calculate k-space trajectory for the mrecon gridder and this is also used for the phase corrections. 
% For the greengard/fessler gridder another trajectory calculation will be
% performed, they require different properties.

if strcmpi(MR.ParUMC.ProfileSpacing,'golden')
    % For RECFRAME trajectory calculations dynamics are considered
    % equal, so we have to reshape it to [nr ns+ndyn z coils 1].
    dims=size(MR.Data);dims(5)=size(MR.Data,5);
    MR.Data=reshape(MR.Data,[dims(1) dims(2)*dims(5) dims(3) dims(4) 1]);

    % Set golden angles
    GA=@(n)(pi/(((1+sqrt(5))/2)+n-1)); 
    nGA=MR.ParUMC.Goldenangle; 
    MR.Parameter.Gridder.RadialAngles=mod((0:GA(nGA):(size(MR.Data,2)-1)*GA(nGA)),2*pi);
end

% Calculate trajectory (Kpos, Weights)
GridderCalculateTrajectory@MRecon(MR)

% Reshape data back in [nr ns z coils ndyn]
if strcmpi(MR.ParUMC.ProfileSpacing,'golden')
    MR.Data=reshape(MR.Data,dims);
end

% END
end