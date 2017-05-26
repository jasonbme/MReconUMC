function res = mtimes(a,bb)
% Perform the 3D NUFFT

for n=1:numel(bb)     % Data chunks
for avg=1:size(bb{n},12) % Averages
for ex2=1:size(bb{n},11) % Extra2
for ex1=1:size(bb{n},10) % Extra1
for mix=1:size(bb{n},9)  % Locations
for loc=1:size(bb{n},8)  % Mixes
for ech=1:size(bb{n},7)  % Phases
for ph=1:size(bb{n},6)   % Echos
for dyn=1:size(bb{n},5)  % Dynamics
for coil=1:size(bb{n},4) % Coils

if a.adjoint 
   
    % Do the nufft
    res{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
        fftshift(single(nufft_adj(matrix_to_vec(bb{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)),...
        a.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(a.imSize{n}))),3);
   
else
    
    % Adjoint operation, havent tried yet
    res{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
        single(nufft(matrix_to_vec(bb{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)),...
        a.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(a.imSize{n}(1:3))));
    
end

end % Coils
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Averages
end % Data chunks

