function res = mtimes(tv,x)
% Function to calculate finite temporal differences and deal with
% boundaries. Adapted from Ricardo Ortazo
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

if numel(size(x)) < 5
    fprintf('Input has to be a 5D matrix, with time in the 5th dimensions\n')
    res=[];
    return
end

if tv.adjoint
    res = adjDz(x);
else
    res = x(:,:,:,:,[2:end,end]) - x;
end

function y = adjDz(x)
y=x(:,:,:,:,[1,1:end-1]) - x; 
y(:,:,:,:,1) = -x(:,:,:,:,1); 
y(:,:,:,:,end) = x(:,:,:,:,end-1);
end

% END
end