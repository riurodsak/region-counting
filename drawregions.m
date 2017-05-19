function drawregions(img1,img2)
    global Regions;
    a = subplot(1,2,1);
    imshow(img1);
    
    b = subplot(1,2,2);
    imshow(img2);
    regionsize = length(Regions);
    for i = 1:regionsize
        %not yet implemented
        %text(Regions(i).center(1),Regions(i).center(2),str(Regions(i).id));
    end
    
    title(a,'Original image');
    title(b,'Regioned image');
end

