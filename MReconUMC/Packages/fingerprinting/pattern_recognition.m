function matchmap = pattern_recognition(dic,img)
%%  METHODOLOGY:
%   3D image stack is reshaped into a 2D matrix to allow vector based
%   operations with the 2D dictionary. Normalise both the dictionary and the
%   images so that they all havw AUC =1. Calculate the dot product of every 
%   pixel with every dictionary entry. Selected the dictionary entry with 
%   the maximum value on a pixel by pixel basis. Everything is performed in 
%   vector operations to enhance speed.
%
% Version 2015/08/17 || Tom Bruijnen @ King's college London || t.bruijnen@student.tue.nl


if nargin<2
    display('Not sufficient input\n.');return;end

% Save dimensionality
img=squeeze(img);
dims_img=size(img);
dims_dic=size(dic);
    
% Reshape the images to a 1D format (entry x timepoints). 
% This is required for the vector based pattern recognition operation.
sig=reshape(img,[prod(dims_img(1:2)),dims_img(3)])';

% Normalise the dictionary and the signal.
% Give all curves the same Area Under the Curve.
for i=1:dims_dic(1)
    dic(i,:)=dic(i,:)./norm(dic(i,:));
end

for i=1:size(sig(:,:),2)
    sig(:,i)=sig(:,i)./norm(sig(:,i));
end

% Match on magnitude
norm_dic=abs(dic);
sig=abs(sig);

% Pattern recognition
innerproduct=norm_dic(:,:)*sig(:,:);
[~,inprod]=max(abs(innerproduct));

% Matchmap is an image matrix with the "number" match for every pixel.
matchmap=reshape(inprod,[size(img,1), size(img,2)]);

%% END of function.
end