function MR = set_gridding_flags(MR,sign)
%% Deal with the reconstruction flags
if sign==0 % Unset gridding pars
    MR.Parameter.ReconFlags.isgridded=0;
    MR.Parameter.ReconFlags.isimspace=[0 0 0];
    MR.Parameter.ReconFlags.isoversampled=[1 1 1];
    MR.Parameter.ReconFlags.iszerofilled=[0 0];
    MR.Parameter.ReconFlags.isunfolded=0;
else
    MR.Parameter.ReconFlags.isgridded=1;
    MR.Parameter.ReconFlags.isimspace=[1 1 1];
    MR.Parameter.ReconFlags.isoversampled=[1 1 0];
    MR.Parameter.ReconFlags.iszerofilled=[1 1];
    MR.Parameter.ReconFlags.isunfolded=1;
end
% END
end