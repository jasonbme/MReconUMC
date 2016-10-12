function output = mtimes(cc,Data) 

% Deal with multiple temporal frames.
S=repmat(cc.S,[1 1 1 1 size(Data,5)]);

if cc.adjoint==1 % S
    output=sum(Data.*conj(S),4)./sum(abs(S).^2,4);
else % S^-1
    output=repmat(Data(:,:,:,1,:),[1 1 1 size(S,4) 1]).*S;
end
    
% END  
end  
