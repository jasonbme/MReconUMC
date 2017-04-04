function output = mtimes(cc,Data) 

% Deal with multiple temporal frames.
%S=repmat(cc.S,[1 1 1 1 size(Data,5)]);
cc.S=double(cc.S);
if cc.adjoint==1 % S
    for dyn=1:size(Data,5)
        output(:,:,:,:,dyn)=sum(Data(:,:,:,:,dyn).*conj(cc.S),4);%./sum(abs(cc.S).^2,4);
    end
    %output=sum(Data.*conj(S),4)./sum(abs(S).^2,4);
else % S^-1
    for dyn=1:size(Data,5)
        output(:,:,:,:,dyn)=repmat(Data(:,:,:,1,dyn),[1 1 1 size(cc.S,4) 1]).*cc.S;
    end
    %output=repmat(Data(:,:,:,1,:),[1 1 1 size(S,4) 1]).*S;
end
    
% END  
end  
