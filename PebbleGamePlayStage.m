classdef PebbleGamePlayStage < handle
    %PebbleGamePlayStage 泡泡游戏娱乐场
    %   用这个类生成你的泡泡游戏。句柄类，复制的时候要小心哦！
    %  1.初始化UserInPut_Group
    
    properties
        %三大组
        UserInPut;
        Operation;
        Result;
        
        %有关Rigidity的工具
        Rigidity;
    end
    
    methods
        function obj = PebbleGamePlayStage(varargin)
            obj.UserInPut = UserInPut_Group(varargin{1,:});
            
            %获取绘图信息
            obj.UserInPut.Show(); 
            
            %生成Operation_Group
            obj.Operation = Operation_Group(obj.UserInPut.Graph.Nodes,obj.UserInPut.GraphPlot.XData,obj.UserInPut.GraphPlot.YData,obj.UserInPut.Graph.Edges);
            
            %生成Rigidity_Tools
            obj.Rigidity = Rigidity_Tools(obj.UserInPut.Graph.Nodes,obj.UserInPut.GraphPlot.XData,obj.UserInPut.GraphPlot.YData,obj.UserInPut.Graph.Edges);
            
        end
    end
    
end

