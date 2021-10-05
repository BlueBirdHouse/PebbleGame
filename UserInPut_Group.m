classdef UserInPut_Group < handle
    %UserInPut 用于存储并显示用户的初始输入
    %   1.存储并显示用户的初始输入
    %   2.初始化Operation组
    %   3.初始化EdgeReadForAdd表
    
    properties
        Graph = graph(); 
        GraphPlot;%是handle，显示内容的句柄。
        GraphFigure; %是handle,绘图窗口的句柄。
    end
    
    methods
        function obj = UserInPut_Group(varargin)
            obj.Graph = graph(varargin{1,:});
            %obj.GraphPlot = obj.Graph.plot();
        end
        
        function Show(obj,varargin)
            %显示图
            obj.GraphFigure = figure('Name','用户输入图','NumberTitle','on');
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

