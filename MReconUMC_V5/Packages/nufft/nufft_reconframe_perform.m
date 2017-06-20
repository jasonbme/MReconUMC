function nufft_reconframe_perform( MR )
%Function to use the reconframe gridding functionality, it doesnt have an
% forward operator so it does not work for iterative reconstructions.

% Dimensionality
num_data=numel(MR.Data);

% Save complete trajectory, used to re-assign in multiple dynamics
data=MR.Data;
traj=MR.Parameter.Gridder.Kpos;
weights=MR.Parameter.Gridder.Weights;
angles=MR.Parameter.Gridder.RadialAngles;

MR.GridderCalculateTrajectory;
% Preallocate cell
IM={};

% Iterate over all data chunks
for n=1:num_data
    nl=size(data{n},2);
    ndyn=size(data{n},5);

    % Loop over all dynamics and assign current Data/Kpos/Weights/Angles
    for dyn=1:ndyn
        MR.Data=single(data{n}(:,:,16,:,dyn));
        MR.Parameter.Gridder.Kpos=permute(traj{n}(:,:,:,:,dyn),[2 3 4 1]);
        MR.Parameter.Gridder.Weights=weights{n}(:,:,:,:,dyn);
        MR.Parameter.Gridder.RadialAngles=permute(angles{n}(:,:,:,:,dyn),[2 1]);
        MR.GridData;
        MR.RingingFilter;
        MR.ZeroFill;
        MR.K2I;
        MR.GridderNormalization;
        IM{n}(:,:,:,:,dyn)=MR.Data;
        MR=set_gridding_flags(MR,0);     
    end
end

MR=set_gridding_flags(MR,1);
MR.Data=IM;

if ~MR.UMCParameters.ReconFlags.NufftCsmMapping && ~strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'no');
    MR.Data=ifftshift(MR.Data,3);end % Temporarily fix, i dont know what goes wrong    

% END
end