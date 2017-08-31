function RemoveOversampling( MR )
% Overload removeoversampling function

if iscell(MR.Data)
    if size(MR.Data{1},1) > MR.Parameter.Encoding.XRes
        RemoveOversampling@MRecon(MR);
    end
else
    if size(MR.Data,1) > MR.Parameter.Encoding.XRes
        RemoveOversampling@MRecon(MR);
    end
end

% END
end
