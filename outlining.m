clear;
clc;
close all;

%% Load original file
filenameindex = 3;

filenames = {'1a.png','1b.png','2a.png','2b.png','3a.png','3b.png','4a.png','4b.png'};
filename = filenames{filenameindex};
o = imread(strcat('original/',filename));
o = rgb2gray(o);

%% Value fitting
% set sigma and filter sizes manually and choose the best fitting
% values
sigmavalues = [5,7,9,11];
filtersizes = [21,23,25,27];

%sigma = 7;
filtersize = 25;
i = 1;
for sigma = sigmavalues
%for filtersize = filtersizes
    
    %Gauss filter
    %subplottight(2,4,i);
    gauss = imgaussfilt(o,sigma,'FilterSize',filtersize);
    %imshow(gauss,'border','tight');
    
    %Canny edge of gaussian filtered
    %subplottight(2,4,i);
    %canny = edge(gauss,'canny');
    %imshow(canny,'border','tight');
    
    %Canny edge directly with gaussian filter (no option for filtersize)
    subplottight(2,4,i);
    canny2 = edge(o,'canny',[],sigma);
    imshow(canny2,'border','tight');
    
    %Thicken the lines
    subplottight(2,4,i+4);
    se = strel('disk',1);
    dilatedcanny = imdilate(canny2,se);
    imshow(dilatedcanny,'border','tight');
    
    i = i+1;
end

%% Ask for values and save the filtered image with those values
fsigma = input('Enter the desired sigma value: [7]');
if isempty(fsigma)
    fsigma = 7;
end
ffiltersize = input('Enter the desired filtersize. If set to 0, perform only canny with built in gaussian blur: [25]');
if isempty(ffiltersize)
    ffiltersize = 25;
end
dilate = input('Dilate? 1/0 [1]');
if isempty(dilate)
    dilate = 1;
end

if( ffiltersize ~= 0)
    finalgauss = imgaussfilt(o,fsigma,'FilterSize',ffiltersize);
    finalcanny = edge(finalgauss,'canny');
else
    finalcanny = edge(o,'canny',[],sigma);
end

if(dilate)
    se = strel('disk',1);
    finalcanny = imdilate(finalcanny,se);
end

figure('Name','Saved image');
imshow(finalcanny);
imwrite(finalcanny,strcat('outlined/',filename));
