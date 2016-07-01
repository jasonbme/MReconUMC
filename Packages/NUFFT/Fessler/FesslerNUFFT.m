function FesslerNUFFT( MR )
% 20160701 - Jeff Fesslers nufft_toolbox package.
% Different weights/kpos are computed to match the properties required for
% the Fessler gridding. Note that the MR.ParUMC.NUFFT contains the coil
% combination function as well, unlike gaussian gridding. Not 3D compatible
% yet!!
% http://web.eecs.umich.edu/~fessler/irt/irt/

% Dimensionality
dims=size(MR.Data);
Rdims=round(MR.Parameter.Gridder.OutputMatrixSize);

% Generate input in appropriate dimensions.
% Coil Sensitivity Maps =[XRes YRes NCoils]
if isempty(MR.Parameter.Recon.Sensitivities)% If no csm make all ones.
    MR.Parameter.Recon.Sensitivities=ones([Rdims(1) Rdims(2) dims(3) dims(4)]); 
end

% Save raw data for iterative reconstruction & apply DCF
if strcmp(MR.ParUMC.CS,'yes')
    MR.ParUMC.Rawdata=MR.Data.*repmat(permute(sqrt(MR.Parameter.Gridder.Weights),[1 2 3  5 4]),[1 1 1 dims(4) 1]);
end

% Define the multicoil NUFFT operator
param.E=MCNUFFT(-1*MR.Parameter.Gridder.Kpos,MR.Parameter.Gridder.Weights,MR.Parameter.Recon.Sensitivities); 
MR.ParUMC.NUFFT=param.E;
param.y=double(MR.Data.*repmat(permute(sqrt(MR.Parameter.Gridder.Weights),[1 2 3 5 4]),[1 1 1 dims(4) 1]));

% Do the gridding
MR.Data=param.E'*param.y;
MR.Parameter.ReconFlags.isimspace=[1 1 1];
MR.Parameter.ReconFlags.iscombined=[1 1 1];
MR.GeometryCorrection;
MR.RemoveOversampling;
MR=SetGriddingFlags(MR,1);

% END
end