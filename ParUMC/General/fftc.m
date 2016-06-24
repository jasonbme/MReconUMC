function F = fftc(M)

if length(size(M))<3 
    if sum((size(M)-1)==0)>0 % If 1D
        F=fftshift(fft(M));
    else % Else 2D
        F=fftshift(fft2(M));
    end
else
    F=0; % Else doesn't work yet.
end

% END
end