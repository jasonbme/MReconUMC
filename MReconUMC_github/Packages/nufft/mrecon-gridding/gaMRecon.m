function MR = gaMRecon(MR)

% Get object dimensions
nl=size(MR.Data,2);
ndyn=size(MR.Data,5);

% Save complete trajectory, used to re-assign in multiple dynamics
data=single(MR.Data);
traj=MR.Parameter.Gridder.Kpos;
weights=MR.Parameter.Gridder.Weights;
angles=MR.Parameter.Gridder.RadialAngles;

% Loop over all dynamics and assign current Data/Kpos/Weights/Angles
for dyn=1:ndyn
    MR.Data=data(:,:,:,:,dyn);
    MR.Parameter.Gridder.Kpos=traj(:,(nl*(dyn-1)+1):(nl*dyn),:,:);
    MR.Parameter.Gridder.Weights=weights(:,(nl*(dyn-1)+1):(nl*dyn));
    MR.Parameter.Gridder.RadialAngles=angles((nl*(dyn-1)+1):(nl*dyn),:);
    MR.GridData;
    MR.RingingFilter;
    MR.ZeroFill;
    MR.K2I;
    MR.GridderNormalization;
    IM(:,:,:,:,dyn)=MR.Data;
    MR=SetGriddingFlags(MR,0);     
end
MR.Data=IM;
MR=SetGriddingFlags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,0];
MR.Data=flip(MR.Data,3);

% END
end