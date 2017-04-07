function output = mtimes(dcf,input)

% Multiply k-space data with DCF
for n=1:size(input);
    dims=size(input{n});dims(4)=size(input{n},4);
    W=repmat(dcf.w{n},[1 1 dims(3) dims(4) 1]);
    output{n}=input{n}.*W;
end

% END  
end  
