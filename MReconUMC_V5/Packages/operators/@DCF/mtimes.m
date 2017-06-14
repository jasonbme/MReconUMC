function output = mtimes(dcf,input)

% If input is not a cell make it a call
if ~iscell(input);input={input};end

% Loop over all data chunks to apply DCF
for n=1:numel(input);
    % Data dimensions for reshape
    dims=size(input{n});
    
    % Examine dimensions of dcf
    for j=1:numel(size(input{n}))
        if size(dcf.w{n},j)==size(input{n},j)
            dims(j)=1;
        end
    end

    % Multiply k-space data with DCF
    W=repmat(dcf.w{n},dims);
    output{n}=input{n}.*W;
end

% END  
end  
