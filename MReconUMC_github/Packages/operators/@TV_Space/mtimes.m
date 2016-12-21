function res = mtimes(a,b)
% Take finite differences of complex coil combined images (x,y,z,1,t) in both the y and x
% directions. Only uses first order-finite differences. 

if a.adjoint
    res = (real(b([1:1,1:end-1],:,:,:,:)) - real(b)) + ... x real
        1j*(imag(b([1,1:end-1],:,:,:,:)) - imag(b)) + ... x imag
        (real(b(:,[1,1:end-1],:,:,:)) - real(b)) + ... y real
        1j*(imag(b(:,[1,1:end-1],:,:,:)) - imag(b)); % y imag
else
    res = (real(b([2:end,end],:,:,:,:)) - real(b)) + ... x real
        1j*(imag(b([2:end,end],:,:,:,:)) - imag(b)) + ... x imag
        (real(b(:,[2:end,end],:,:,:)) - real(b)) + ... y real
        1j*(imag(b(:,[2:end,end],:,:,:)) - imag(b)); % y imag
end
