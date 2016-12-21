function MR = RadialGeometry( MR )
% Reset geometry parameters for various spatial resolutions
if MR.UMCParameters.LinearReconstruction.SpatialResolution==0 
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.AcqVoxelSize)/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   MR.Parameter.Scan.RecVoxelSize=MR.Parameter.Scan.AcqVoxelSize;
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=1;
else
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=MR.UMCParameters.LinearReconstruction.SpatialResolution/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   [tmp_z,idx]=max(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Scan.RecVoxelSize=repmat(MR.UMCParameters.LinearReconstruction.SpatialResolution,[3 1]);
   MR.Parameter.Scan.RecVoxelSize(idx)=tmp_z;
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.RecVoxelSize)/min(MR.Parameter.Scan.AcqVoxelSize);
end

% Set reconstruction parameters accordingly
MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1];

% Store k-space and image dimensions in struct
MR.UMCParameters.LinearReconstruction.KspaceSize=size(MR.Data);
MR.UMCParameters.LinearReconstruction.IspaceSize=[MR.Parameter.Encoding.XRes,MR.Parameter.Encoding.YRes,size(MR.Data,3),size(MR.Data,4),size(MR.Data,5)];

% END
end