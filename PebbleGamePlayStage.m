classdef PebbleGamePlayStage < handle
    %PebbleGamePlayStage ������Ϸ���ֳ�
    %   ��������������������Ϸ������࣬���Ƶ�ʱ��ҪС��Ŷ��
    %  1.��ʼ��UserInPut_Group
    
    properties
        %������
        UserInPut;
        Operation;
        Result;
        
        %�й�Rigidity�Ĺ���
        Rigidity;
    end
    
    methods
        function obj = PebbleGamePlayStage(varargin)
            obj.UserInPut = UserInPut_Group(varargin{1,:});
            
            %��ȡ��ͼ��Ϣ
            obj.UserInPut.Show(); 
            
            %����Operation_Group
            obj.Operation = Operation_Group(obj.UserInPut.Graph.Nodes,obj.UserInPut.GraphPlot.XData,obj.UserInPut.GraphPlot.YData,obj.UserInPut.Graph.Edges);
            
            %����Rigidity_Tools
            obj.Rigidity = Rigidity_Tools(obj.UserInPut.Graph.Nodes,obj.UserInPut.GraphPlot.XData,obj.UserInPut.GraphPlot.YData,obj.UserInPut.Graph.Edges);
            
        end
    end
    
end

