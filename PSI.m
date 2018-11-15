%1. Read File with UI

[fileName,filePath] = uigetfile({'*.tif';'*.*'},'Please Select Input Image');
fileNamePath=[filePath,fileName]; %acquire absolute dir
tic
raw_img=imread(fileNamePath);
disp('Size of input image:');
[row,col,band]=size(raw_img);
disp([row,col,band]);

%2. Calculate PSI
%     Extend conditions:
% -- PHi is less than  T1.
% -- Number of pixels in this direction line is less than T2.

T1=110;  %Default value
T2=50;    %Default value
D = 20;%D indicates the total number of direction lines
T1_str = inputdlg('The spectral homogeneity threshold','Set T1');
if(size(T1_str,1)~=0)
    T1 = STR2DOUBLE(T1_str{1});
end
T2_str = inputdlg('Number of pixels in each direction line','Set T2');
if(size(T2_str,1)~=0)
    T2 = STR2DOUBLE(T2_str{1});
end



% MBIndex=uint8(MBIndex/(D*(S-1)));
% imwrite(MBIndex,'MBI.tif');
% 
% eimg=imadjust(MBIndex);
% imshow(eimg,'Colormap',jet(255));
% t=toc;
% display(t);