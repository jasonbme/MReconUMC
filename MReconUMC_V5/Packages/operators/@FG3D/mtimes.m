function res = mtimes(fg,bb)
% Perform the 3D NUFFT

if fg.adjoint 

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
	   
	    % Do the nufft
	    res{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
		reshape(nufft_adj(matrix_to_vec(bb{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)),...
		fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3))),fg.Id{n}(1:3));
	    
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

else

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
	   
	    % Forward operator
	    res_tmp(:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
		nufft(reshape(bb{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg),fg.Id{n}(1:3)),...
		fg.st{n,dyn,ph,ech,loc,mix,ex1,ex2,avg})/sqrt(prod(fg.Id{n}(1:3)));

	end % Coils

	    % Store output from all receivers
	    res{n}(:,:,:,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=reshape(res_tmp,fg.Kd{n}([1:4]));

	end % Dynamics
	end % Echos
	end % Phases
	end % Mixes
	end % Locations
	end % Extra1
	end % Extra2
	end % Averages
	end % Data chunks

end

