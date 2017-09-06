function estimate_density_arbitrary_trajectory_3D(MR)
%Iteratively estimate density for arbitrary k-spaces in 3D. This code is
%downloaded from the ismrm-unbound website and written by Nick Zwart.


% Dont execute if 3D gridding is selected
if strcmpi(MR.UMCParameters.AdjointReconstruction.IterativeDensityEstimation,'no')
    return;
end

% Recompute density function per data chunk
num_data=numel(MR.Parameter.Gridder.Kpos);
for n=1:num_data
    
    % Sometimes kpos is not scaled between -.5 and .5 for different
    % resolutions. However for the density function this is required.
    ratio=max(abs(MR.Parameter.Gridder.Kpos{n}(:)))/.5;

    Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};Kd(end+1:13)=1;
    for ex2=1:Kd(11) % Extra2
    for ex1=1:Kd(10) % Extra1
    for mix=1:Kd(9)  % Locations
    for loc=1:Kd(8)  % Mixes
    for ech=1:Kd(7)  % Phases
    for ph=1:Kd(6)   % Echos
    for dyn=1:Kd(5)  % Dynamics
        
        tmp_weights=sdc3_MAT(MR.Parameter.Gridder.Kpos{n}(:,:,:,:,1,dyn,ph,ech,loc,mix,ex1,ex2)/ratio,...
            5,max(MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)),0);
        
        % Scale adequatly
        MR.Parameter.Gridder.Weights{n}(:,:,:,1,dyn,ph,ech,loc,mix,ex1,ex2)=tmp_weights/prctile(tmp_weights(:),98);
        
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
end

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
    %subplot(338);for n=1:num_data;plot(1:numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),abs(MR.Parameter.Gridder.Weights{n}(:,1)),'Linewidth',2);hold on;end;grid on;box on;...
    %title('Estimated density function');xlabel('Samples [-]');ylabel('Density [a.u.]');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

% END
end