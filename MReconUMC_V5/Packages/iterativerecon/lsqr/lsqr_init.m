function lsqr_configuration(MR,n,p)
% Generate a structure to feed in the lsqr functions

it_dim=MR.UMCParameters.IterativeReconstruction.JointReconstruction; % Readabillity
MR.UMCParameters.Operators.W=DCF({sqrt(dynamic_indexing(MR.Parameter.Gridder.Weights{n},it_dim,p))});
MR.UMCParameters.Operators.N=
MR.UMCParameters.Operators.S=
MR.UMCParameters.Operators.TV=
MR.UMCParameters.Operators.Id=
MR.UMCParameters.Operators.Kd=
MR.UMCParameters.Operators.N_iter=
MR.UMCParameters.Operators.N_rep=
MR.UMCParameters.Operators.TV=
MR.UMCParameters.Operators.Id=
MR.UMCParameters.Operators.Verbose=



IR.N=MR.UMCParameters.AdjointReconstruction.NUFFTOperator;
IR.S=MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator;
IR.W=MR.UMCParameters.AdjointReconstruction.DensityOperator;
IR.Niter=MR.UMCParameters.IterativeReconstruction.Niter;
IR.Idim=MR.UMCParameters.AdjointReconstruction.IspaceSize;IR.Idim(1:2)=round(IR.Idim(1:2)*MR.Parameter.Encoding.KxOversampling);
IR.Kdim=MR.UMCParameters.AdjointReconstruction.KspaceSize;
IR.lambda=MR.UMCParameters.IterativeReconstruction.Regularization_parameter;
IR.TVflag=0;
IR.Visualization=MR.UMCParameters.IterativeReconstruction.Visualization;

% END
end