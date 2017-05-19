close all
clear global Linregions
clear global Regions
clear
clc
%% Load and mask image
filenameindex = 8;

filenames = {'1a.png','1b.png','2a.png','2b.png','3a.png','3b.png','4a.png','4b.png'};
proportionalities = [39.7,41.1,42.8,40.5,39.2,39.5,39.2,39.2]; %number of pixels per mm in each image
pixelspermm = proportionalities(filenameindex);
filename = filenames{filenameindex};

outlined = imread(strcat('outlined/',filename));
original = imread(strcat('original/',filename));

[h, w, c] = size(outlined); % matrix: height*width
% outlined: 0-no edge, 255-edge


%% Find linear regions
global Linregions;
index = 1; %master index of linregions
closed = true;
%tempimg = filtered;
for i = 2:(w-1) %interation through columns
    % start with a region with a border on the left
    regioncol = 1; %the first region of the line
    if(~closed)
        error('New line started and last Linregion isnt closed');
    end
    Linregions = [Linregions, Linregion(index,[regioncol,i],1)];
    closed = false;
    for j = 2:h-1
        if(~closed) %if(~Linregions(index).isClosed())
            if((~filtered(j,i) && filtered(j+1,i)) || (j == h-1)) %end of a region
                Linregions(index).close(j); %set the right border and close the linregion
                closed = true;
                index = index + 1;
                regioncol = regioncol + 1;
            end
        else %the previous Linregion closed, so start a new one
            if(filtered(j-1,i) && ~filtered(j,i)) %start of a region
                Linregions(index) = Linregion(index,[regioncol,i],j);
                closed = false;
                if(filtered(j+1,i)) %this is a special case: a linregion with only 1 pixel
                    Linregions(index).close(j);
                    closed = true;
                    index = index + 1;
                    regioncol = regioncol + 1;
                end
            end
        end
    end
end

%% Find connected linregions and add that info TO THE linregions
linregionsize = length(Linregions);
for i = 2:w-2
    %Compare the linregions in col i with the linregions in col (i+1) and
    %if connected, add that info to the later
    
    %find linregions in col i
    iIndex = []; %indices of linregions in col i
    found = false;
    for ii = 1:linregionsize
        if(Linregions(ii).isInRow(i))
            iIndex = [iIndex, ii];
            found = true; %found at least 1. If the next one is not in col i, you can stop searching
        elseif(found == true)
            break %get out of the for loop, and ii is now the first index from where to start searching the linregions in row i+1
        end
    end
    
    %find linregions in col i+1. Start search from the last index in col i
    %up until one doesn't belong to col i+1. It can stop there because
    %linregions are ordered
    i1Index = [];
    found = false;
    for ii1 = ii:linregionsize
        if(Linregions(ii1).isInRow(i+1))
            i1Index = [i1Index, ii1];
            found = true;
        elseif(found == true)
            break
        end
    end
    %compare them and if connected, add reference to both in both (by adding the id to the connection array)
    for a = 1:length(iIndex)
        for b = 1:length(i1Index)
            ia = iIndex(a); %indices of linregions to compare
            ib = i1Index(b);
            if (Linregions(ia).isConnectedTo(Linregions(ib)))
                Linregions(ia).addConnection(Linregions(ib));
                Linregions(ib).addConnection(Linregions(ia));
            end
        end
    end
end

%% Combine linregions to regions
% Regions in general can also be calculated with bwconncomp
global Regions;
for i = 1:linregionsize
    %search for current linregion in region array
    iscontained = 0;
    regionsize = length(Regions); %needs to be checked every interation because it changes when new regions are created
    for j = 1:length(Regions)
        if(Regions(j).contains(i)) %for speed, only pass the index
            iscontained = iscontained + 1; %the Linregion i is cointained at least in Region j
            container = j;
        end
    end
    
    if(~iscontained)
        %if Linregion(i) is not found in any Region, then create a new one, and
        %add ALL THE CONNECTED from Linregion(i) RECURSIVELY
        Regions = [Regions, Region(regionsize+1,i,Linregions(i))];
        %Regions(regionsize+1) = Region(regionsize+1,i,Linregions(i));
        %the constructor for Region finds all connected Linregions to
        %Linregions(i) and adds them to itself
    end
end

%% Calculate Regions area and center

%Generally Regions(1) is the outer region, which is not wanted
Regions(1) = []; %delete it

areas = zeros(1,length(Regions));
for i = 1:length(Regions)
    Regions(i).calcArea(pixelspermm);
    areas(i) = Regions(i).area;
    %Regions(i).calcCenter();
    
end
meanarea = mean(areas);
%% Ignore border linregions and get lengths
lengths = [];
lengthsindex = 1;
for i = 1:length(Linregions)
    if(~Linregions(i).isInBorder(h))
        lengths(lengthsindex) = Linregions(i).d/pixelspermm;
        lengthsindex = lengthsindex + 1;
    end
end
meanlength = mean(lengths);
[meanlength,meanarea] % Print mean length and meanarea of the total of regions
%% Draw regions

regiononly = zeros(h,w,3);
regiononly(:,:,1) = filtered;
regiononly(:,:,2) = filtered;
regiononly(:,:,3) = filtered;
regiononly = uint8(regiononly); %without this, it only displays black and white
regionedimg = outlined;

regionsize = length(Regions);
for i = 1:regionsize
    regionedimg = Regions(i).draw(regionedimg);
    regiononly = Regions(i).draw(regiononly);
end
figure('Name',filename);
drawregions(original,regionedimg);
[histlength,histarea] = hists(lengths,areas,filename);

% Save images to files
imwrite(regionedimg,strcat('regioned/',filename));
imwrite(regiononly,strcat('regionsonly/',filename));

reducedname = filename(1:end-4); %remove the .png ending
histlengthname = strcat('Histograms/',reducedname,'-length.png');
histareaname = strcat('Histograms/',reducedname,'-area.png');
print(histlength,histlengthname,'-dpng');
print(histarea,histareaname,'-dpng');

