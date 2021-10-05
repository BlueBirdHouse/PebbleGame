classdef ZipNumList < containers.ArrayList
    %ZipNumList 专用于存储数字的列表. 
    %这个列表只能够用来存储数字。
    %带有一个特殊的ZipList方法，可以合并存储的内容。
    %使用参数‘rows’来按照行操作。
    
    properties
    end
    
    methods
        function obj = ZipNumList(initialCapacity)
            obj = obj@containers.ArrayList(initialCapacity);
        end
        
        function appendElement(obj,Arrays,varargin)
            if(isa(Arrays,'numeric') ~= true)
                error('只能接受数组输入。');
            end
            [m, n] = size(Arrays);
            if(nargin == 2)
                m = m * n;
                for i = 1:1:m
                    appendElement@containers.ArrayList(obj,{Arrays(i)});
                end
            end
            if(nargin == 3)
                if(strcmp(varargin,'rows'))
                    for i = 1:1:m
                        appendElement@containers.ArrayList(obj,{Arrays(i,:)});
                    end
                else
                    error('输入rows按行操作。');
                end
            end
        end
        
        function ZipList(obj,varargin)
            % 压缩List内的重复元素
            if(obj.Count > 0)
                Temp = cell2mat(obj.removeLast());
            else
                return;
            end
            n = obj.Count;
            for i = 1:1:n
                Temp = [Temp(1:end,:) ; cell2mat(obj.removeLast())];
            end
            
            if(nargin == 1)
                Temp = unique(Temp);
                obj.appendElement(Temp);
            end
            if(nargin == 2)
                if(strcmp(varargin,'rows'))
                    Temp = unique(Temp,'rows');
                    obj.appendElement(Temp,'rows');
                else
                    error('输入rows按行操作。');
                end
            end
        end
    end
    methods(Hidden = true)
        function insertAtIndex(obj,Arrays, index)
            %这个函数在基类内定义的有问题。
            if(isa(Arrays,'numeric') ~= true)
                error('只能接受数组。');
            end
            for Printer = Arrays(1:end)
                 %insertAtIndex@containers.ArrayList(obj,{Printer},index);
            end
        end
    end
    
end

