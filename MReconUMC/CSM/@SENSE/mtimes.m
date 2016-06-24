function output = mtimes(Op,Data) 

S=repmat(Op.S,[1 1 1 1 size(Data,5)]); % Add z=1 dimension

if Op.adjoint==1 % S
	output=sum(Data.*conj(S),4)./sum(abs((S)).^2,4);
else
    output=repmat(Data(:,:,:,1,:),[1 1 1 size(S,4) 1]).*S;
end
    

% END  
end  
