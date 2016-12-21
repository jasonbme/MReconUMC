%% Text the Walsh csm method
close all;clear all;clc
load('try_img.mat');
tic;[~,csm]=openadapt(permute(try_img(:,:,:,:,3),[4 1 2 3]));toc
close all;imshow3(abs(permute(csm,[2 3 1])),[],[1,size(csm,1)]);title('Coil sensitivity magnitude')
figure,imshow3(angle(permute(csm,[2 3 1])),[],[1,size(csm,1)]);title('Coil sensitivity phase')
