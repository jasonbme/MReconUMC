function qmaps=generate_maps(img,dic,matchmap,T1list,T2list,B1list,threshold,mask)
%%  METHODOLOGY:
%   This function creates T1/T2/M0/B1 maps, from the matchmap made in the 
%   previous Block. If Golden Radial acquisition is used you can use a 
%   MASK, reconstructed using all spokes, to filter out the background pixels.
%   It uses the T1/T2/B1 list to fill in the T1/T2/B1 values in the maps. 
%
%   INPUT:      - IM:       Images stack straight from Block 4.
%               - dict:     Dictionary filled with the simulations.
%               - matchmap: 2D matrix filled with dictionary entry matches.
%               - mask:     The image reconstructed with all spokes.
%               - Nspokes:  Number of spokes used for Radial.
%               - T1list
%               - T2list
%               - B1list
%               - threshold: Fraction of maximal intensity used for the masking.
%
%   OUTPUT:     - T1map
%               - T2map
%               - M0map
%               - B1map
%
% Version 2015/08/17 || Tom Bruijnen @ King's college London || t.bruijnen@student.tue.nl

if isempty(threshold)
    threshold=.1;end

% Preallocate memory
dim=size(img);
T1map=zeros(dim(1),dim(2));
T2map=zeros(dim(1),dim(2));
M0map=zeros(dim(1),dim(2));
B1map=zeros(dim(1),dim(2));

% Define loop counters. 
nT1=length(T1list);
nT2=length(T2list);
nRF=size(img,3);

% Loop over image dimensions to fill in the maps.
% So basically translate a "match-number" to a T1/T2/B1 value.
for i=1:dim(1)
    for j=1:dim(2)
        n_B1=floor((matchmap(i,j)-1)/(nT1*nT2));
        B1map(i,j)=B1list(n_B1+1);
        n_T1=floor((matchmap(i,j)-1-n_B1*nT1*nT2)/nT2);
        T1map(i,j)=T1list(n_T1+1);
        T2map(i,j)=T2list(matchmap(i,j)-floor((matchmap(i,j)-1)/nT2)*nT2);
        M0map(i,j)=sum(reshape(abs(img(i,j,:)),1,nRF))/sum(abs(dic(matchmap(i,j),:)));
    end 
end
        
% If a mask image is provided (MASK is not empty), it uses this.
% Otherwise it uses the proton density map ask a mask, less reliable.
if isempty(mask)
    % Find 10 largest values in M0map and average them.
    s_M0map=sort(reshape(M0map,[size(M0map(:,:),1)*size(M0map(:,:),2),1]));
    maxval=sum(s_M0map(end-9:end))/10;
    for j=1:dim(1)
        for k=1:dim(2)
            if (M0map(j,k)<threshold*maxval || T2map(j,k)>800)
                T1map(j,k)=0;
                T2map(j,k)=0;
                M0map(j,k)=0;
                B1map(j,k)=0;
            end
        end
    end 
else
    % Find 10 largest values in MASK and average them.
    s_mask=sort(reshape(mask,[size(mask(:,:),1)*size(mask(:,:),2),1]));
    maxval=sum(s_mask(end-9:end))/10;
    for j=1:dim(1)
        for k=1:dim(2)
            if (abs(mask(j,k))<threshold*maxval)
                T1map(j,k)=0;
                T2map(j,k)=0;
                M0map(j,k)=0;
                B1map(j,k)=0;
            end
        end
    end
end

% Save all maps in qmaps
qmaps=zeros([size(T1map) 4]);
qmaps(:,:,1)=T1map;
qmaps(:,:,2)=T2map;
qmaps(:,:,3)=B1map;
qmaps(:,:,4)=M0map;

% END
end