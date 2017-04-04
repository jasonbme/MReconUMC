function  res = FG(k,w,phase,shift,imSize, mode)
%FT = NUFFT(k,w,phase,shift,imSize,mode)
%	non uniform 2D fourier transform operator, based on 
%	Jeffery Fessler's code.
%
%	Inputs:
%		k - normalized kspace coordinates (complex value between -0.5 to 0.5)
%`		w - density compensation (w=1, means no compensation)
%		phase - phase of the image for phase correction
%		shift - shift the image center
%		imSize - the image size
%		mode - 1 - contrain image to be real, 2 - complex image
%
%	Outputs:
%		FT = the NUFFT operator
%
%	example:
%		% This example computes the ifft of a 2d sinc function
%		[x,y] = meshgrid([-64:63]/128);
%		k = x + i*y;
%		w = 1;
%		phase = 1;
%		imSize = [128,128];
%		shift = [0,0];
%		FT = NUFFT(k,w,phase,shift,imSize);
%
%		data = sinc(x*32).*sinc(y*32);
%		im = FT'*data;
%		figure, subplot(121),imshow(abs(im),[]);
%		subplot(122), imshow(abs(data),[]);
%
% (c) Michael Lustig 2007
%


if exist('nufft') <2
	error('must have Jeffery Fessler''s NUFFT code in the path');
end
    res.dataSize = size(k);

    k = reshape(k,[size(k,1)*size(k,2) size(k,5) 1]);
    Nd = imSize;
    Jd = [5,5];
    Kd = [Nd*2];
    n_shift = Nd/2 + shift;
    for dyn=1:size(k,2)
        om=[real(k(:,dyn)), imag(k(:,dyn))]*2*pi;
        res.st{dyn} = nufft_init(om, Nd, Jd, Kd, n_shift,'minmax:kb');
    end

    res.phase = phase;
    res.adjoint = 0;
    res.imSize = imSize;
    res.w = w;
    res.mode = mode;
    res = class(res,'FG');

