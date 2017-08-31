function GR = extract_gradient_info(MR,gradient)
% Extract set of attributes and store to struct
    
% Add brackets for correct nomenclature, i.e. m0 --> m[0]
if ~isempty(str2num(gradient(end)))
    gradient(end+1)=gradient(end);
    gradient(end+1)=']';
    gradient(end-2)='[';
end

% Get attributes
if MR.Parameter.IsObject(['GR`',gradient])==1;
    GR.ref=MR.Parameter.GetValue(['GR`',gradient,':ref'])*10^(-3);
    GR.time=MR.Parameter.GetValue(['GR`',gradient,':time'])*10^(-3);
    GR.offset=GR.time-GR.ref;
    GR.str=MR.Parameter.GetValue(['GR`',gradient,':str']);
    if GR.str==0
        GR.str=MR.Parameter.GetValue(['GR`',gradient,':str_step'])*MR.Parameter.GetValue(['GR`',gradient,':str_factor_max']);
    end
    GR.lenc=MR.Parameter.GetValue(['GR`',gradient,':lenc'])*10^(-3);
    GR.slope1=MR.Parameter.GetValue(['GR`',gradient,':slope1'])*10^(-3);
    GR.slope2=MR.Parameter.GetValue(['GR`',gradient,':slope2'])*10^(-3);
    GR.dur=GR.lenc+GR.slope1+GR.slope2;
    GR.ori=MR.Parameter.GetValue(['GR`',gradient,':ori']);
    GR.sq=MR.Parameter.GetValue(['GR`',gradient,':SQ']);
else
    GR.ref=0;
    GR.time=0;
    GR.offset=0;
    GR.str=0;
    GR.lenc=0;
    GR.slope1=0;
    GR.slope2=0;
    GR.dur=0;
    GR.ori=0;
    GR.sq='base';
end

end
% END