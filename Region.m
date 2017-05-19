classdef Region < handle
    %REGION 2D Region, created by connecting linregions
    %   blablabla
    
    properties ( GetAccess = 'public', SetAccess = 'private' )
        id %index in the array Regions
        indices %all indices of Linregions which are part of the Region (NOTE: INDICES, not IDs!!!)
        mass %total number of pixels
        area %translated pixel area to mm^2
        border %all border coordinates (doesn't care for left or right border)
        center %mass center of the region (point where to write the text)
    end
    
    methods
        function obj = Region(id_,i_,lobj) %lobj is the Linregion class instance passed as argument
            obj.id = id_;
            obj.indices = []; %indices of Linregions contained in this Region
            obj.mass = 0;
            obj.area = 0;
            obj.border = [];
            if nargin > 0
                obj.addLinregion(i_, lobj);
                obj.addConnected(lobj);
            end
        end
        
        function out = contains(obj, i)
            if(any(obj.indices == i)) %if indices contains the index i, return true
                out = true;
            else
                out = false;
            end
        end
        
        function obj = addConnected(obj,lobj)
            global Linregions;
            numberconnections = length(lobj.connected);
            if(numberconnections > 0) %if there's connections
                for i = 1:numberconnections
                    %check if the connection alredy exists by checking if
                    %the index is in the indices array
                    lobji = Linregions(lobj.connected(i));
                    if(~obj.contains(lobji.id))
                        obj.addLinregion(lobji.id, lobji);
                        obj.addConnected(lobji); %important to call these two functions IN THIS ORDER
                    end
                end
            end
        end
        
        function obj = addLinregion(obj, i_, lobj)
            obj.indices = [obj.indices, i_];
            obj.mass = obj.mass + lobj.d;
            obj.border = [obj.border; lobj.lborder,lobj.row; lobj.rborder,lobj.row];
            %fprintf('Added Linregion %i to Region %i\n',i_, obj.id);
        end
        
        function img = draw(obj,img)
            color = floor(255*rand(1,3));
            %number of border points
            nborder = length(obj.border); %this gives the number of rows of the x times 2 matrix border.
            for j = 1:2:nborder
                lborderx = obj.border(j,1);
                lbordery = obj.border(j,2);
                rborderx = obj.border(j+1,1);
                %rbordery = obj.border(j+1,2); is the same as lbordery,
                %because they are in the same row
                %add with transparency
                img(lborderx:rborderx,lbordery,1) = 0.5*img(lborderx:rborderx,lbordery,1)+0.5*color(1); %the 3 long array of color maps to regionedimg
                img(lborderx:rborderx,lbordery,2) = 0.5*img(lborderx:rborderx,lbordery,2)+0.5*color(2);
                img(lborderx:rborderx,lbordery,3) = 0.5*img(lborderx:rborderx,lbordery,3)+0.5*color(3);
            end
        end
        
        function obj = calcArea(obj,pixelspermm)
            obj.area = obj.mass/(pixelspermm)^2;
        end
        
        function obj = calcCenter(obj) %approximate solution, not weighted sum over all pixels
            %not yet implemented
        end
    end
end

