function [dicom, dicomvid, inf] = readDicom(npoints,location)
%% Read DICOM files for FFE MRF
%  REQUIREMENTS:
%                  x       
%
%  INPUT: 
%          npoints : number of data points in MRF acquisitions (nRF)
%         location : folder of the .dicom files. See MAINfile for details.
%
%  OUPUT: 
%            dicom : 3D matrix which is composed like [x,y,t].
%         dicomvid : dicom edited to comply with the implay functionality.
%              inf : structure which contains all the sequence information.
%
%% Initiate
if nargin<2
    location = 'D:\Documents\Tom bmt\Stage\Scan results\22052015\MRF scan 6 spiral alpha2 old shim\DICOM\IM_'; %Without the number at the end.
end
inf=dicominfo([location,'0001']);
dimx=inf.Width;
dimy=inf.Height;

%% Create 3D dataset

    dicom=zeros(dimx,dimy,npoints); % Allocate matrix
    for i=1:npoints    % All these loops are basically just for string allignments.
        j=0;
        if i<10
           j=['000',num2str(i)]; 
        end
        if i>=10 && i<100
           j=['00',num2str(i)];
        end
        if i>=100 && i<1000
           j=['0',num2str(i)]; 
        end
        if i>=1000
            j=num2str(i);
        end
        dicom(:,:,i)=dicomread([location,j]);
    end


%% Video mode
dicomvid=dicom/max(max(max(dicom)));

%% END of function.
end
