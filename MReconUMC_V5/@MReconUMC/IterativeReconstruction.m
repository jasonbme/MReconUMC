function IterativeReconstruction( MR )


if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'no');
    return
end

% Perform nonlinear reconstructions
fprintf('Iterative reconstruction..........................  ');tic;

% Nonlinear conjugate gradient method for CS (potential_function=1)
if MR.UMCParameters.IterativeReconstruction.Potential_function==1
    
    % Initialize dedicated NLCG struct
    IR=NLCGstruct(MR);

    % Fill in operators
    IR.NUFFT=MR.UMCParameters.AdjointReconstruction.NUFFTOperator;
    IR.S=MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator;
    IR.W=MR.UMCParameters.AdjointReconstruction.DensityOperator;
    IR.y=double(IR.W*MR.UMCParameters.IterativeReconstruction.RawData);MR.UMCParameters.IterativeReconstruction.RawData=[];

    % Define TV operator
    IR.TV=TV_Temp();
    
    % Iterative reconstruction
    NUFFTiter=0; % Count number of nufft operations
    IR.CGruns=0;  
    
    % Perform the recon
    while IR.CGruns<MR.UMCParameters.IterativeReconstruction.Niter && IR.quit==0
        [MR.Data,NUFFTi,IR]=NLCGsolve(MR.Data,IR);
        NUFFTiter=NUFFTiter+NUFFTi;
        IR.CGruns=IR.CGruns+1;
    end
end

% LSQR methods
if MR.UMCParameters.IterativeReconstruction.Potential_function==2
    
    % Fill in operators
    IR.N=MR.UMCParameters.AdjointReconstruction.NUFFTOperator;
    IR.S=MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator;
    IR.W=MR.UMCParameters.AdjointReconstruction.DensityOperator;
    IR.Niter=MR.UMCParameters.IterativeReconstruction.Niter;
    IR.Idim=MR.UMCParameters.AdjointReconstruction.IspaceSize;IR.Idim(1:2)=round(IR.Idim(1:2)*MR.Parameter.Encoding.KxOversampling);
    IR.Kdim=MR.UMCParameters.AdjointReconstruction.KspaceSize;
    IR.lambda=MR.UMCParameters.IterativeReconstruction.Regularization_parameter;
    IR.TVflag=0;
    IR.Visualization=MR.UMCParameters.IterativeReconstruction.Visualization;

    if strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'none')
        
        % Joint itSense
        [MR.Data, MR.UMCParameters.IterativeReconstruction.LSQR_resvec]=config_itSense_Joint_2D(double(IR.W*MR.UMCParameters.IterativeReconstruction.RawData),IR);
        
    elseif strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'temporal')
            
        % Define the right TV operator (5th dim is temporal)
        IR.TV=TV_5_full(size(MR.Data,1),size(MR.Data,2),size(MR.Data,3),size(MR.Data,5),MR.UMCParameters.IterativeReconstruction.TVorder);
        %IR.TV=TV_5(size(MR.Data,1),size(MR.Data,2),size(MR.Data,3),size(MR.Data,5),MR.UMCParameters.IterativeReconstruction.TVorder);

        % Reduced dimensions for TV operator
        IR.TVdim=[IR.Idim(1) IR.Idim(2) IR.Idim(3) 1 IR.Idim(5)];%-MR.UMCParameters.IterativeReconstruction.TVorder];
        
        % Joint regularized yemporal (TV) Sense
        [MR.Data, MR.UMCParameters.IterativeReconstruction.LSQR_resvec]=config_reg_itSense_Joint_2D(double(IR.W*MR.UMCParameters.IterativeReconstruction.RawData),IR);
        
    elseif strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'spatial')
        
        % Define the right TV operator (1+2 are spatial dimensions
        IR.TV=TV_1_full(size(MR.Data,1),size(MR.Data,2),size(MR.Data,3),size(MR.Data,5),MR.UMCParameters.IterativeReconstruction.TVorder);
        IR.TV1=TV_2_full(size(MR.Data,1),size(MR.Data,2),size(MR.Data,3),size(MR.Data,5),MR.UMCParameters.IterativeReconstruction.TVorder);
        IR.TVflag=1;
        
        % Reduced dimensions for TV operator
        IR.TVdim=[IR.Idim(1) IR.Idim(2) IR.Idim(3) 1 IR.Idim(5)];
        
        % Joint regularized yemporal (TV) Sense
        [MR.Data, MR.UMCParameters.IterativeReconstruction.LSQR_resvec]=config_reg_itSense_Joint_2D(double(IR.W*MR.UMCParameters.IterativeReconstruction.RawData),IR);
       
    end

end
    
% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end