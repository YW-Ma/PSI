%1. Read File with UI

[fileName,filePath] = uigetfile({'*.tif';'*.*'},'Please Select Input Image');
fileNamePath=[filePath,fileName]; %acquire absolute dir
tic
raw_img=imread(fileNamePath);
disp('Size of input image:');
[row,col,band]=size(raw_img);
disp([row,col,band]);
%2. Calculate PSI
%2.1 Set Parameters

%     Two extend conditions:
%     -   PHi is less than  T1.    &&
%     -- Number of pixels in this direction line is less than T2.
T1=110;  %Default spactral threshold
T2=50;    %Default spatial threshold
D = 20;%D indicates the total number of direction lines
T1_str = inputdlg('The spectral homogeneity threshold','Set T1');
if(size(T1_str,1)~=0)
    T1 = str2double(T1_str{1});
end
T2_str = inputdlg('Number of pixels in each direction line','Set T2');
if(size(T2_str,1)~=0)
    T2 = str2double(T2_str{1});
end
D_str = inputdlg('Number of directions','Set D');
if(size(D_str,1)~=0)
    D= str2double(D_str{1});
end

%2.2 Calculate PSI
PSIndex=zeros(row,col,D,'double');
%NOTICE: Prof. X. Huang said we should output a D bands data instead of add them up.
%                  Output cannot be sum(PSIndex) or mean(PSIndex), since
%                  they will lose useful information.

%2.2.1 Create a templet for Dirction Lines in advance.
%from 0-180 degree [but it seems to be 0-90 in an image of the paper]
degree=linspace(0,3.14159/2,D);
ratio_col=cos(degree);  %  ---> right
ratio_row=sin(degree); %  | up
length=1:T2;
templet_offset_col=fix(length'*ratio_col);
templet_offset_row=fix(length'*ratio_row);
%example: templet_offset_col(5,15)-> Offset value in Col of direction No.15 & length No.5


for pi=1:row    % pixel (i,j)
    for pj=1:col
        
        %each pixel:
        for dir=1:D
            ending_point=zeros(2);
            %2.2.2 Using templet to extend the direction line
            %each direction line:
            for length=1:T2
                diff_col=templet_offset_col(length,dir);
                diff_row=templet_offset_row(length,dir);
                %1. exist
                if((pi+diff_row)<1||(pi+diff_row)>row||(pj+diff_col)<1||(pj+diff_col)>col)
                    break;
                else
                    PH=0;
                    for dim=1:band
                        PH=PH+abs(raw_img(pi,pj,dim)-raw_img(pi+diff_row,pj+diff_col,dim));
                    end%for dim
                end% if-else
                %2. Spactral limitation
                if(PH<T1)
                    ending_point=[diff_row,diff_col];
                else
                    break
                end
            end%end length (line)
            %2.2.3 City-block Distance
            PSIndex(pi,pj,dir)=sum(sum(abs(ending_point)));
        end%for dir (pixel)
    end%for pj
    disp(['Finish line No.',num2str(pi)]);
end%for pi

%3. Mapping double to uint8
% PSIndex_uint8=uint8(255 * mat2gray(PSIndex));
for i=1:D
    fileName=['PSI',num2str(i),'.tif'];
%     temp=squeeze(PSIndex_uint8(:,:,i));
    temp=imadjust(PSIndex(:,:,i));
    imwrite(temp,fileName);
end
temp=imadjust(sum(PSIndex,3));
imwrite(temp,'PSI.tif');

% MBIndex=uint8(MBIndex/(D*(S-1)));
% imwrite(MBIndex,'MBI.tif');
%
% eimg=imadjust(MBIndex);
% imshow(eimg,'Colormap',jet(255));
% t=toc;
% display(t);