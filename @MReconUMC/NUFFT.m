function NUFFT( MR )
% 20160615 - General NUFFT script, differentiates between fessler/greengard
% or mrecon gridders. Note that for mrecon the splitting into dynamics is
% performed in here as well. For the other gridders this is done in
% MR.SortData;

switch MR.ParUMC.Gridder
    case 'fessler' % CombineCoils is included in the gridding
        % Notifcation
        fprintf('Perform NUFFT (Fessler) and combine coils.........  ');tic;
        
        FesslerNUFFT(MR);
        
    case 'greengard'
        % Notifcation
        fprintf('Perform NUFFT (Greengard) and combine coils.......  ');tic;
       
        GreengardNUFFT(MR);
        
    case 'mrecon'
        % Notifcation
        fprintf('Split data into dynamics and NUFFT (MRecon) ......  ');tic;
        
        % Get object dimensions
        ns=size(MR.Data,2);
        ndyn=size(MR.Data,5);
        
        % Save complete trajectory, used to re-assign in multiple dynamics
        data=MR.Data;
        traj=MR.Parameter.Gridder.Kpos;
        weights=MR.Parameter.Gridder.Weights;
        angles=MR.Parameter.Gridder.RadialAngles;

        % Loop over all dynamics and assign current Data/Kpos/Weights/Angles
        for dyn=1:ndyn
            MR.Data=data(:,:,:,:,dyn);
            MR.Parameter.Gridder.Kpos=traj(:,(ns*(dyn-1)+1):(ns*dyn),:,:);
            MR.Parameter.Gridder.Weights=weights(:,(ns*(dyn-1)+1):(ns*dyn));
            MR.Parameter.Gridder.RadialAngles=angles((ns*(dyn-1)+1):(ns*dyn),:);
            MR.GridData;
            MR.RingingFilter;
            MR.ZeroFill;
            MR.K2I;
            MR.GridderNormalization;
            MR.CombineCoils;
            MR.GeometryCorrection;
            MR.RemoveOversampling;
            IM(:,:,:,:,dyn)=MR.Data;
            MR=SetGriddingFlags(MR,0);
        end
        MR.Data=IM;
        MR=SetGriddingFlags(MR,1);

end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end