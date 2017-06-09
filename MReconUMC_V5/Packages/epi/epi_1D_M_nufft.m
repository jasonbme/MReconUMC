function res = epi_1D_M_nufft(MR,calib_data,adj)
% Perform 1D Nufft or adjoint nufft for epi phase correction

% Dimensionality
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{1};
Id=MR.UMCParameters.AdjointReconstruction.IspaceSize{1};

% Initiate nufft for even and uneven lines
d1=nufft_init(MR.Parameter.Gridder.Kpos{1}(1,:,1)',Kd(1),5,2*Kd(1));
d2=nufft_init(MR.Parameter.Gridder.Kpos{1}(1,:,2)',Kd(1),5,2*Kd(1));

% Create function handles
u_adj=@(y)(nufft_adj(y,d1));
e_adj=@(y)(nufft_adj(y,d2));
u_for=@(y)(nufft(y,d1));
e_for=@(y)(nufft(y,d2));

if adj==1 % K-space --> Image space
    for c=1:Kd(4)
        for z=1:Kd(3)
            for ro=1:Kd(2)
                if mod(ro,2)>0 % is uneven
                    res(:,ro,z,c)=u_adj(calib_data(:,ro,z,c));
                else
                    res(:,ro,z,c)=e_adj(calib_data(:,ro,z,c));
                end
            end
        end
    end
else
     for c=1:Kd(4)
        for z=1:Kd(3)
            for ro=1:Kd(2)
                if mod(ro,2)>0 % is uneven
                    res(:,ro,z,c)=u_for(calib_data(:,ro,z,c));
                else
                    res(:,ro,z,c)=e_for(calib_data(:,ro,z,c));
                end
            end
        end
    end   
end

% END
end