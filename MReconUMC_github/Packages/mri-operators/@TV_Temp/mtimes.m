function res = mtimes(a,b)

if a.adjoint
    res = adjDz(b);
else
    res = b(:,:,:,:,[2:end,end]) - b;
end

function y = adjDz(x)
y= x(:,:,:,:,[1,1:end-1]) - x; % Dtf operator, takes first entry double to correct with last one. So the last frame is disregarded
y(:,:,:,:,1) = -x(:,:,:,:,1); 
y(:,:,:,:,end) = x(:,:,:,:,end-1);