classdef Rigidity_Tools < handle        
%Rigidity_Tools 刚性工具箱
%本工具箱包含有关一个图的Rigidity属性的相关工具和方法。

    properties
        %从用户输入的图直接导出的节点表对象
        Nodes;
        
        %绘图数据，这个数据只能在初始化的时候写入，一直不变；
        XData;
        YData;
        
        %从用户输入的图直接导出的边对象
        Edges;
    end
    
    methods
        function obj = Rigidity_Tools(nodes,xdata,ydata,edges)
            obj.Nodes = nodes;
            
            obj.XData = xdata;
            obj.YData = ydata;
            
            obj.Edges = edges;
        end
        
        function [Redundantly,NotRedundantlyEdgeTables] = IsRedundantlyRigidGraph(obj,Detail)
            %当某一步不能判断是Redundantly Rigid Graph的时候，就将对应的图对象的边输出到NotRedundantlyEdgeTable
            Redundantly = true;
            
            %获得边数
            EdgesNumber = height(obj.Edges);
            NotRedundantlyEdgeTables = containers.ArrayList(EdgesNumber);
            
            
            if(obj.IsGenericallyRigidGraph(obj.Edges,obj.Nodes,Detail,'position',obj.XData,obj.YData))
            else
                disp('原图不是Generically Rigid Graph');
                Redundantly = false;
                NotRedundantlyEdgeTable.appendElement(obj.Edges);
                return;
            end
            
            %生成待检测边的列表
            EdgesList = obj.RedundantlyEdges(obj.Edges);
     
            %一个一个接受检测
            for i = 1:1:EdgesNumber
                AEdges = EdgesList.removeLast();
                AEdges = AEdges{1};
                if(obj.IsGenericallyRigidGraph(AEdges,obj.Nodes,Detail,'position',obj.XData,obj.YData))
                else
                    disp('发现一个子图不是Generically Rigid Graph。');
                    Redundantly = false;
                    NotRedundantlyEdgeTables.appendElement(AEdges);
                end
            end
        end
    end
    
    methods(Static)    
        function [Rigid] = IsGenericallyRigidGraph(EdgeTable,NodeTable,Detail, varargin)
            %判断一个图是否为Generically Rigid Graph
            Rigid = true;
            
            UserInPut = UserInPut_Group(EdgeTable,NodeTable);
            
            %获取绘图信息
            if(length(varargin)==3)
                if(strcmp(varargin{1},'position'))
                    XDATA = varargin{2};
                    YDATA = varargin{3};
                    UserInPut.Show('position',XDATA,YDATA);
                end
            else
                UserInPut.Show(); 
                XDATA = UserInPut.GraphPlot.XData;
                YDATA = UserInPut.GraphPlot.YData;
            end
            
            %检查是否有绘图位置信息输入
            if(length(varargin)==3)
                if(strcmp(varargin{1},'position'))
                    XDATA = varargin{2};
                    YDATA = varargin{3};
                end
            end
            
            %生成Operation_Group
            Operation = Operation_Group(UserInPut.Graph.Nodes,XDATA,YDATA,UserInPut.Graph.Edges);
            
            if(strcmp(Detail,'detail'))
            %删除用户输入图的显示。
            else
                UserInPut.GraphFigure.delete();
            end
            
            %获得边数
            EdgesNumber = height(UserInPut.Graph.Edges);
            for i = 1:1:EdgesNumber
                Operation.IndependentEdge(1);
                if(strcmp(Detail,'detail'))
                    drawnow();
                end
            end
            
            Operation.StartIdentifyRigidCluster();
            while(Operation.IdentifyARigidCluster() == false)
                if(strcmp(Detail,'detail'))
                    Operation.ShowRigidCluster();
                    drawnow();
                else
                    %如果不用显示详细信息，那么在发现两个以上的Cluster之后立即返回
                    if((max(Operation.Graph.Edges.Cluster)) > 1)
                        Rigid = false;
                        Operation.GraphFigure.delete();
                        return;
                    end
                end
            end
            
            if((max(Operation.Graph.Edges.Cluster)) > 1) 
                Rigid = false;
            elseif(~(strcmp(Detail,'detail')))
                Rigid = true;
                Operation.GraphFigure.delete();
            end
            
        end
        
        function [EdgeTableList] = RedundantlyEdges(EdgeTable)
            %生成用于判断Redundantly Rigidity需要的边列表。
            %这个列表是将原来的边列表每去掉一行以后，得到的一个元素
            
            %得到边个数
            EdgesNumber = height(EdgeTable);
            
            %生成用于存储这些边列表的列表对象。
            EdgeTableList = containers.ArrayList(EdgesNumber);
            
            for i = 1:1:EdgesNumber
                RemoveOneTable = EdgeTable;
                RemoveOneTable(i,:) = [];
                EdgeTableList.appendElement(RemoveOneTable);
            end
        end
        
        function [kConnected,FailedGraph] = kConnectedCheck(EdgeTable,NodeTable,k,XDATA,YDATA,Detail)
            %k连接检查函工具。
            kConnected = true;
            FailedGraph = containers.ArrayList(1);
            %如果在中间出现了检查失败，则将失败时候的图对象放在FailedGraph里面。
            
            %生成待检查的图
            G = graph(EdgeTable,NodeTable);
            
            if(k == 1)
                %检查最基本的1连接的时候，需要特殊处理。
                ConnectComponent = G.conncomp();
                %获得连接件的最大值
                M_ConnectComponent = max(ConnectComponent);
                if(M_ConnectComponent ~= 1)
                        %说明不是连接的图
                        kConnected = false;
                        FailedGraph = containers.ArrayList(1);
                        FailedGraph.appendElement(G);
                        disp('发现了一次检查失败');
                end
                return;
            end
            

            %得到节点个数
            NodesNumber = height(NodeTable);
            
            %计算可能需要的列表个数
            FailedGraphLong = 0;
            for RemoveM = 1:1:(k-1)
                FailedGraphLong = FailedGraphLong + nchoosek(NodesNumber,RemoveM);
            end
            %生成检查失败的节点列表
            FailedGraph = containers.ArrayList(FailedGraphLong);
            
            for RemoveM = 1:1:(k-1)
                %生成移除RemoveM个节点以后的，节点列表组合
                NodeList = combnk(1:NodesNumber,(NodesNumber - RemoveM));
                [m,~] = size(NodeList);
                for Counter = 1:1:m
                    %取得每一个元素，生成子图
                    ASubGraph = G.subgraph(NodeList(Counter,:));
                    if(strcmp(Detail,'VeryDetailed'))
                            figure('Name',num2str(NodeList(Counter,:)),'NumberTitle','on');
                            %获得子图的显示数据
                            X = XDATA(NodeList(Counter,:));
                            Y = YDATA(NodeList(Counter,:));
                            ASubGraph.plot('XData',X,'YData',Y);
                            drawnow;
                    end
                    
                    %获得子图的连接件信息
                    ConnectComponent = ASubGraph.conncomp();
                    %获得连接件的最大值
                    M_ConnectComponent = max(ConnectComponent);
                    if(M_ConnectComponent ~= 1)
                        %说明不是连接的图
                        kConnected = false;
                        FailedGraph.appendElement(ASubGraph);
                        disp('发现了一次检查失败');
                        if(strcmp(Detail,'detail'))
                            figure('Name',num2str(NodeList(Counter,:)),'NumberTitle','on');
                            %获得子图的显示数据
                            X = XDATA(NodeList(Counter,:));
                            Y = YDATA(NodeList(Counter,:));
                            ASubGraph.plot('XData',X,'YData',Y);
                            drawnow;
                        end
                    end
                end
            end
            
        end
    end
end