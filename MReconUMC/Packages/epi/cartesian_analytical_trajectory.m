function cartesian_analytical_trajectory(MR)

dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;

for n=1:numel(dims)
    kx=linspace(-.5,.5,dims{n}(1)+1);kx(end)=[];
    ky=linspace(-.5,.5,dims{n}(2)+1);ky(end)=[];
    kz=linspace(-.5,.5,dims{n}(3)+1);kz(end)=[];
    if numel(kz)==1;kz=0;end
    [KX,KY,KZ]=meshgrid(kx,ky,kz);
    kn{n}=repmat(permute(cat(3,KX,KY,KZ),[3 2 1]),[1 1 1 1 1 dims{n}(5:end)]);    
end

MR.Parameter.Gridder.Weights=cellfun(@(x) ones([x(1:3) 1 x(5:end)]),dims,'UniformOutput',false);
MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,...
    kn,'UniformOutput',false);
    
% END
end