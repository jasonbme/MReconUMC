function res = mtimes(a,b)
% Modified wavelet operator to apply on ND-matrices

if isa(a,'Wavelet2D') == 0
    error('In  A.*B only A can be Wavelet operator');
end

% Dimensionality
Id=size(b);

% Make dyadic
b=zpad2(b,[makedyadic(Id(1)) makedyadic(Id(2)) Id(3:end)]);

% Preallocate output
res=zeros(makedyadic(Id(1)),makedyadic(Id(2)),prod(Id(3:end)));

% Loop over all 2D matrices
for n=1:prod(Id(3:end))
    if a.adjoint
        res(:,:,n)=IWT2_PO(real(b(:,:,n)),a.wavScale,a.qmf)+i*IWT2_PO(imag(b(:,:,n)),a.wavScale,a.qmf);
    else
        res(:,:,n)=FWT2_PO(real(b(:,:,n)),a.wavScale,a.qmf)+i*FWT2_PO(imag(b(:,:,n)),a.wavScale,a.qmf);
    end
end

% Crop
res=crop(res,Id(1));

% Reshape output
res=reshape(res,Id);

% END
end
