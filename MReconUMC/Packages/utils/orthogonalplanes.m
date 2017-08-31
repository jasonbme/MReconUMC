function orthogonalplanes(I)
% Function to plot three orthogonal planes of a 3D matrix

if numel(size(I))~=3
    fprintf('Wrong input, matrix must be MxNxZ');return
end


I=zpad2((I),max(size(I)),max(size(I)),max(size(I)));
[X,Y,Z]=size(I);
A=cat(4,I(:,:,ceil(Z/2)),flip(permute(I(:,ceil(Y/2),:),[3 1 2]),1),flip(permute(I(ceil(X/2),:,:),[3 2 1]),1));
figure,imshow3(A,[],[1 3]);

% END
end