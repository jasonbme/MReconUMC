function NonLinearReconstruction( MR )
% 20160516 - Overarching file for the Non linear recons. All operators and
% parameters are stored in the NLR structure. If MR.ParUMC.lambda has more
% then 1 input, multiple reconstructions will be performed and individual
% datasets will be saved.

% Checks
if strcmpi(MR.ParUMC.CS,'yes') && ~strcmpi(MR.ParUMC.GetCoilMaps,'no') && strcmpi(MR.ParUMC.Gridder,'mrecon')~=1
    fprintf('Non linear reconstruction.........................  ');tic;

    %% Initiate operators
    % Total Variation in time dimension
    NLR.TV=TV_Temp();
    
    % NUFFT
    NLR.NUFFT=GG(MR.Parameter.Gridder.Kpos,MR.ParUMC.Rdims(1:2),MR.ParUMC.Kdims(1:2));
    
    % Roemer coil combination with remove oversampled coil maps
    MR.ParUMC.Sense=SENSE(crop(MR.Parameter.Recon.Sensitivities,MR.Parameter.Encoding.XRes,MR.Parameter.Encoding.YRes,MR.Parameter.Encoding.ZRes,size(MR.Parameter.Recon.Sensitivities,4)));
    NLR.S=MR.ParUMC.Sense;
    
    % Density compensation 
    NLR.W=MR.ParUMC.W;
    
    %% Set parameters into struct
    % Raw phase corrected data
    NLR.y=double(MR.ParUMC.Rawdata);
    
    % Number of iterations
    NLR.nite=MR.ParUMC.NLCG{2};
    
    % Gridder type (greengard or fessler)
    NLR.gridder=MR.ParUMC.Gridder;
    
    % Step size parameter for the line search
    NLR.beta=MR.ParUMC.Beta;   
    
    % Save reconstruction sizes for remove oversampling
    NLR.rdims=size(MR.Data);NLR.rdims(4)=size(NLR.y,4);
    
    % Set first element of the objective (L-curve generation)
    MR.ParUMC.Objective(1)=Objective(NLR.TV*MR.Data);
    
    %% Perform compressed sensing
    % Loop over all lambdas
    for l=1:numel(MR.ParUMC.lambda)
        % Parameter to control regularization (don't change)
        NLR.adjust=0;
        
        % Set regularization parameter(s)
        NLR.lambda=MR.ParUMC.lambda(l);
        
        % The procedure is distributed over NLCG{1} segments with NLCG{2} iterations
        MR.ParUMC.CSData=MR.Data;
        for n=1:MR.ParUMC.NLCG{1}
            [MR.ParUMC.CSData,MR.ParUMC.Cost(l,n),NLR]=CGsolve(MR.ParUMC.CSData,NLR);
        end
        
        % Display current lambda
        fprintf('\nl=%d/%d\n',l,numel(MR.ParUMC.lambda))
        
        % Save results in the right directory
        cd(MR.ParUMC.TWD);
        filename=['CS_' num2str(size(MR.Parameter.Gridder.Kpos,2)) '_L_' num2str(MR.ParUMC.lambda(l))];
        filename(filename=='.')=[];
        feval(@()assignin('caller',filename,MR.ParUMC.CSData));
        save(filename,filename)
        clear CS_*
        cd(MR.ParUMC.PWD);
        
        % Update objective function
        MR.ParUMC.Objective(l+1)=Objective(NLR.TV*MR.ParUMC.CSData);
    end

    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end

% END
end
