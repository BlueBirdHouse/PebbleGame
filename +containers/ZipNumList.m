classdef ZipNumList < containers.ArrayList
    %ZipNumList ר���ڴ洢���ֵ��б�. 
    %����б�ֻ�ܹ������洢���֡�
    %����һ�������ZipList���������Ժϲ��洢�����ݡ�
    %ʹ�ò�����rows���������в�����
    
    properties
    end
    
    methods
        function obj = ZipNumList(initialCapacity)
            obj = obj@containers.ArrayList(initialCapacity);
        end
        
        function appendElement(obj,Arrays,varargin)
            if(isa(Arrays,'numeric') ~= true)
                error('ֻ�ܽ����������롣');
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
                    error('����rows���в�����');
                end
            end
        end
        
        function ZipList(obj,varargin)
            % ѹ��List�ڵ��ظ�Ԫ��
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
                    error('����rows���в�����');
                end
            end
        end
    end
    methods(Hidden = true)
        function insertAtIndex(obj,Arrays, index)
            %��������ڻ����ڶ���������⡣
            if(isa(Arrays,'numeric') ~= true)
                error('ֻ�ܽ������顣');
            end
            for Printer = Arrays(1:end)
                 %insertAtIndex@containers.ArrayList(obj,{Printer},index);
            end
        end
    end
    
end

