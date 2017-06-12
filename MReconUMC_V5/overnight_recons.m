
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/2DGA/';
scan=2;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=5;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,250]};
MR.UMCParameters.AdjointReconstruction.R=9.8;
MR.PerformUMC;

cd(root);cd('Scan2');
nlcg_tv_13spokes_40ms=MR.Data;save('nlcg_tv_13spokes_40ms.mat','nlcg_tv_13spokes_40ms');

%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/2DGA/';
scan=2;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=400;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,250]};
MR.UMCParameters.AdjointReconstruction.R=16;
MR.PerformUMC;

cd(root);cd('Scan2');
nlcg_tv_8spokes_24ms=MR.Data;save('nlcg_tv_8spokes_24ms.mat','nlcg_tv_8spokes_24ms');

%% 13 Spokes T1-weighted abdominal 3D recon. Slice-by-slice
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/4DGA/';
scan=2;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=10;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.IterativeReconstruction.JointReconstruction=3;
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,250]};
MR.UMCParameters.AdjointReconstruction.R=13.5;
MR.PerformUMC;

cd(root);cd('Scan3');
nlcg_tv_13spokes=MR.Data;save('nlcg_tv_13spokes.mat','nlcg_tv_13spokes');


%% 13 Spokes T1-weighted abdominal 3D recon. 3D recon
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/4DGA/';
scan=3;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=10;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 3 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,5,0,250]};
MR.UMCParameters.AdjointReconstruction.R=13.5;
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.PerformUMC;

cd(root);cd('Scan3');
nlcg_tv_13spokes=MR.Data;save('nlcg_tv_13spokes.mat','nlcg_tv_13spokes');

%% 13 Spokes T1-weighted abdominal balanced 3D recon. 3D recon
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/4DGA/';
scan=4;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=10;
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 3 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,5,0,250]};
MR.UMCParameters.AdjointReconstruction.R=13.5;
MR.PerformUMC;

cd(root);cd('Scan4');
nlcg_tv_13spokes=MR.Data;save('nlcg_tv_13spokes.mat','nlcg_tv_13spokes');

%% 13 Spokes balanced 3D phantom recon. 3D recon
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/4DGA/';
scan=2;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=10;
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.IterativeReconstruction.JointReconstruction=3;
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 3 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,5,0,250]};
MR.UMCParameters.AdjointReconstruction.R=13.5;
MR.PerformUMC;

cd(root);cd('Scan2');
nlcg_tv_13spokes=MR.Data;save('nlcg_tv_13spokes.mat','nlcg_tv_13spokes');


