function ress = mtimes(a,bb)
% performs the normal nufft
for dyn=1:size(bb,5)
for c=1:size(bb,4)
for z=1:size(bb,3)
b = bb(:,:,z,c,dyn);

if a.adjoint
   
	b = b(:).*a.w(:);
	res = nufft_adj(b, a.st{dyn})/sqrt(prod(a.imSize));
	res = reshape(res, a.imSize(1), a.imSize(2));
	res = res.*conj(a.phase);
	if a.mode==1
		res = real(res);
    end
    

else
	b = reshape(b,a.imSize(1),a.imSize(2));
	if a.mode==1
		b = real(b);
	end
	b = b.*a.phase;
	res = nufft(b, a.st)/sqrt(prod(a.imSize));
	res = reshape(res,a.dataSize(1),a.dataSize(2));
end
ress(:,:,z,c,dyn) = res;
end
end
end

