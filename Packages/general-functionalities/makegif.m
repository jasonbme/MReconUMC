function makegif(img,filename,fps,varargin)
% Transform a 3D matrix into an image based GIF file
% Note that computer vision toolbox is required for the counter (varargin).
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Handle input
if nargin < 4
    counter=0;
else
    counter=1;
end

img=abs(squeeze(img));
scrsz = get(0,'ScreenSize');
for j=1:size(img,3);
    I=img(:,:,j);
    if counter == 1
        text_str={['Iter: ' num2str(j)]};
        I=insertText(I,[0 0],text_str,'FontSize',18,'BoxColor',{'blue'},'BoxOpacity',0.4,'TextColor','white');
    end
    imshow(I)
    set(gcf,'position',scrsz);
    A = getframe();
    im=frame2im(A);
    [A,map]=rgb2ind(im,256);
    if ~exist(filename,'file')
        imwrite(A,map,filename,'gif','WriteMode','overwrite','delaytime',1/fps, 'LoopCount', 65535);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','delaytime',1/fps);    
    end
end


% END
end