function RemoveOversampling( MR )
% Overload removeoversampling function

% Own removeoversampling function to perform after reconstruction
if sum(MR.Parameter.ReconFlags.isimspace)>0
    MR.Data=cellfun(@(x) crop3D(x,[MR.Parameter.Encoding.XRes(1),MR.Parameter.Encoding.YRes(1),...
        MR.Parameter.Encoding.ZRes(1)]),MR.Data,'UniformOutput',false);
end
    
RemoveOversampling@MRecon(MR);

% END
end
