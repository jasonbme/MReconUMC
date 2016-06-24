function Data = mtimes(Op,Data) % This is the actual NUFFT operator

dims=size(Data);

if Op.adjoint==-1 % inverse DCF
    % Multiply k-space data with 1/DCF
    W=repmat(permute(1/Op.w,[1 2 3 5 4]),[1 1 1 dims(4) 1]);
    Data=Data.*W;
else
    % Multiply k-space data with DCF
    W=repmat(permute(Op.w,[1 2 3 5 4]),[1 1 1 dims(4) 1]);
    Data=Data.*W;
end

% END  
end  
