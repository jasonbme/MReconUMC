function MR = radial_geometry( MR )

% Reset geometry parameters for various spatial resolutions
if MR.UMCParameters.AdjointReconstruction.SpatialResolution==0 
   MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.AcqVoxelSize)/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   MR.Parameter.Scan.RecVoxelSize=MR.Parameter.Scan.AcqVoxelSize;
   MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio=1;
else
   MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio=MR.UMCParameters.AdjointReconstruction.SpatialResolution/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   [tmp_z,idx]=max(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Scan.RecVoxelSize=repmat(MR.UMCParameters.AdjointReconstruction.SpatialResolution,[3 1]);
   MR.Parameter.Scan.RecVoxelSize(idx)=tmp_z;
   MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.RecVoxelSize)/min(MR.Parameter.Scan.AcqVoxelSize);
end

% Set reconstruction parameters accordingly
MR.Parameter.Scan.Samples(2)=size(MR.Data{1},2);
MR.Parameter.Parameter2Read.ky=(0:size(MR.Data{1},2)-1)';
MR.Parameter.Encoding.KyRange=[0 size(MR.Data{1},2)-1];
MR.Parameter.Parameter2Read.dyn=(0:size(MR.Data{1},5)-1)';

% Store k-space and image dimensions in struct and gridder outputsize
for n=1:numel(MR.Data);MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=[MR.Parameter.Encoding.XRes(n),MR.Parameter.Encoding.YRes(n),MR.Parameter.Encoding.ZRes(n)];end
for n=1:numel(MR.Data);MR.Parameter.Gridder.OutputMatrixSize{n}=[round(MR.Parameter.Encoding.XRes(n).*MR.Parameter.Encoding.KxOversampling(n)) ...
        round(MR.Parameter.Encoding.YRes(n).*MR.Parameter.Encoding.KyOversampling(n)) round(MR.Parameter.Encoding.ZRes(n).*MR.Parameter.Encoding.KzOversampling(n))];end

% END
end