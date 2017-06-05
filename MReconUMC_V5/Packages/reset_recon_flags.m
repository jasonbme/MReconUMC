function MR = reset_recon_flags(MR)
% Deal with the reconstruction flags
MR.Parameter.ReconFlags.issorted=0;
MR.Parameter.ReconFlags.isgridded=0;
MR.Parameter.ReconFlags.isimspace=[0 0 0];
MR.Parameter.ReconFlags.iscombined=0;
MR.Parameter.ReconFlags.isoversampled=[1 1 1];
MR.Parameter.ReconFlags.israndphasecorr=0;
MR.Parameter.ReconFlags.ispdacorr=0;
MR.Parameter.ReconFlags.isdcoffsetcorr=0;
MR.Parameter.ReconFlags.isdepicorr=0;
MR.Parameter.ReconFlags.ismeasphasecorr=0;
MR.Parameter.ReconFlags.isunfolded=0;
MR.Parameter.ReconFlags.iszerofilled=0;
MR.Parameter.ReconFlags.isrotated=0;
MR.Parameter.ReconFlags.isconcomcorrected=0;
MR.Parameter.ReconFlags.isgeocorrected=0;
MR.Parameter.ReconFlags.issegmentsdivided=0;
MR.Parameter.ReconFlags.isecc=0;
MR.Parameter.ReconFlags.isaveraged=0;

% END
end