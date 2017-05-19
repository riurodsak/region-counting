classdef Linregion < handle
    %LINREGION linear region of image
    %   blablabla
    
    properties ( GetAccess = 'public', SetAccess = 'private' )
        coord % array [row, number of region in that row]
        id
        row % or is it a column ??
        lborder %only 1 coordinate
        rborder %only 1 coordinate
        d
        connected %id of linregions to which this one is connected
    end
    
    methods
        function obj = Linregion(id_, coord_, lborder_)
            if nargin > 0
                obj.id = id_;
                obj.coord = coord_;
                obj.row = obj.coord(2); %obj.coord(2) is the row, so the y coordinate.
                obj.lborder = lborder_; 
                obj.rborder = -1;
                obj.d = NaN;
                obj.connected = [];
            end
        end
        
        function obj = close(obj,rborder_)
            obj.rborder = rborder_;
            obj.d = obj.rborder-obj.lborder;
        end
        
        function out = isClosed(obj)
            if obj.rborder == -1
                out = false;
            else
                out = true;
            end
        end
        
        function out = isInRow(obj,i)
            if (obj.row == i)
                out = true;
            else
                out = false;
            end
        end
        
        function out = isConnectedTo(obj,obj2)
            deltal = obj2.lborder-obj.lborder;
            d1 = obj.d;
            d2 = obj2.d;
            if (((deltal > 0) && (deltal <= d1)) || ((deltal < 0)&&(abs(deltal) <= d2))) || (deltal == 0)
                out = true;
            else
                out = false;
            end
        end
        
        function out = isInBorder(obj,height)
            if obj.lborder == 1
                out = true;
            elseif obj.rborder == height-1
                out = true;
            else
                out = false;
            end
        end
        
        function obj = addConnection(obj,obj2)
            if(~ismember(obj2.id,obj.connected))
                obj.connected = [obj.connected, obj2.id];
            end
        end
        
        function img = draw(obj, img)
            color = floor(255*rand(1,3));
            for x = obj.lborder:obj.rborder
                img(x,obj.row,1) = color(1);
                img(x,obj.row,2) = color(2);
                img(x,obj.row,3) = color(3);
            end
        end
    end
end

