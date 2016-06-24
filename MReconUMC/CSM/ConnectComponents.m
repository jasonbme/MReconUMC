function M_CSM = ConnectComponents(I,CSM)
% function to get background from fully sampled image

% Normalize intensities
I=abs(I/max(I(:)));

% Make image binary & blur
gI=imgaussfilt(I,2);gI=gI/max(gI(:));
bwI=im2bw(gI,.05);

% Connected components alghoritm
dims=size(bwI);

labels=zeros(dims);
curlab=1;
bglab=[];
for x=1:dims(1)
    for y=1:dims(2)
        if labels(x,y)==0 && bwI(x,y)==0 % if not labeled and foreground
            
            % Manage borders 
            if x==1
                xn=x:x+1;
            elseif x==dims(1)
                xn=x-1:x;
            else
                xn=x-1:x+1;
            end
            if y==1
                yn=y:y+1;
            elseif y==dims(2)
                yn=y-1:y;
            else
                yn=y-1:y+1;
            end
            
            % Get nhood
            nhood=labels(xn,yn);
            
            % Find other labels in neighborhood
            flab=sum(nhood(:));
            if flab>0 
                i=0;
                while labels(x,y)==0
                    i=i+1;
                    if nhood(i)>0
                        labels(x,y)=nhood(i);
                    end
                end
                if x==1 || x==dims(1) || y==1 || y==dims(2)
                    bglab(nhood(i))=1;
                end
            else
                labels(x,y)=curlab;
                if x==1 || x==dims(1) || y==1 || y==dims(2)
                    bglab(curlab)=1;
                end
                curlab=curlab+1;
            end

        end
    end
end

% Loop over all pixels and make those labels which are "1" in bglab black.
% Rest White
corrlabels=[];
for j=1:numel(bglab)
    if bglab(j)==1
        corrlabels=[corrlabels j];
    end
end

M=ones(dims);
M_rand=rand([dims,1,size(CSM,4)]);
for x=1:dims(1)
    for y=1:dims(2)
        if sum(labels(x,y)==corrlabels)>0
            M(x,y)=0;
        else
            M_rand(x,y,:,:)=0;
        end
    end
end

% Apply mask on CSM
M_CSM=CSM.*repmat(M,[1 1 1 size(CSM,4)])+M_rand;
% END
end