function output = mtimes(dcf,input)

% Multiply k-space data with DCF
dims=size(input);dims(4)=size(input,4);
W=repmat(dcf.w,[1 1 dims(3) dims(4) 1]);
output=input.*W;

% END  
end  
