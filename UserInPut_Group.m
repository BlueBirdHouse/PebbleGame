classdef UserInPut_Group < handle
    %UserInPut ���ڴ洢����ʾ�û��ĳ�ʼ����
    %   1.�洢����ʾ�û��ĳ�ʼ����
    %   2.��ʼ��Operation��
    %   3.��ʼ��EdgeReadForAdd��
    
    properties
        Graph = graph(); 
        GraphPlot;%��handle����ʾ���ݵľ����
        GraphFigure; %��handle,��ͼ���ڵľ����
    end
    
    methods
        function obj = UserInPut_Group(varargin)
            obj.Graph = graph(varargin{1,:});
            %obj.GraphPlot = obj.Graph.plot();
        end
        
        function Show(obj,varargin)
            %��ʾͼ
            obj.GraphFigure = figure('Name','�û�����ͼ','NumberTitle','on');
            if(length(varargin)==3)
                if(strcmp(varargin{1},'position'))
                    XDATA = varargin{2};
                    YDATA = varargin{3};
                    obj.GraphPlot = obj.Graph.plot('XData',XDATA,'YData',YDATA);
                end
            else
                obj.GraphPlot = obj.Graph.plot();
            end
        end
    end
    
end

