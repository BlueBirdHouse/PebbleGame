classdef Rigidity_Tools < handle        
%Rigidity_Tools ���Թ�����
%������������й�һ��ͼ��Rigidity���Ե���ع��ߺͷ�����

    properties
        %���û������ͼֱ�ӵ����Ľڵ�����
        Nodes;
        
        %��ͼ���ݣ��������ֻ���ڳ�ʼ����ʱ��д�룬һֱ���䣻
        XData;
        YData;
        
        %���û������ͼֱ�ӵ����ı߶���
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
            %��ĳһ�������ж���Redundantly Rigid Graph��ʱ�򣬾ͽ���Ӧ��ͼ����ı������NotRedundantlyEdgeTable
            Redundantly = true;
            
            %��ñ���
            EdgesNumber = height(obj.Edges);
            NotRedundantlyEdgeTables = containers.ArrayList(EdgesNumber);
            
            
            if(obj.IsGenericallyRigidGraph(obj.Edges,obj.Nodes,Detail,'position',obj.XData,obj.YData))
            else
                disp('ԭͼ����Generically Rigid Graph');
                Redundantly = false;
                NotRedundantlyEdgeTable.appendElement(obj.Edges);
                return;
            end
            
            %���ɴ����ߵ��б�
            EdgesList = obj.RedundantlyEdges(obj.Edges);
     
            %һ��һ�����ܼ��
            for i = 1:1:EdgesNumber
                AEdges = EdgesList.removeLast();
                AEdges = AEdges{1};
                if(obj.IsGenericallyRigidGraph(AEdges,obj.Nodes,Detail,'position',obj.XData,obj.YData))
                else
                    disp('����һ����ͼ����Generically Rigid Graph��');
                    Redundantly = false;
                    NotRedundantlyEdgeTables.appendElement(AEdges);
                end
            end
        end
    end
    
    methods(Static)    
        function [Rigid] = IsGenericallyRigidGraph(EdgeTable,NodeTable,Detail, varargin)
            %�ж�һ��ͼ�Ƿ�ΪGenerically Rigid Graph
            Rigid = true;
            
            UserInPut = UserInPut_Group(EdgeTable,NodeTable);
            
            %��ȡ��ͼ��Ϣ
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
            
            %����Ƿ��л�ͼλ����Ϣ����
            if(length(varargin)==3)
                if(strcmp(varargin{1},'position'))
                    XDATA = varargin{2};
                    YDATA = varargin{3};
                end
            end
            
            %����Operation_Group
            Operation = Operation_Group(UserInPut.Graph.Nodes,XDATA,YDATA,UserInPut.Graph.Edges);
            
            if(strcmp(Detail,'detail'))
            %ɾ���û�����ͼ����ʾ��
            else
                UserInPut.GraphFigure.delete();
            end
            
            %��ñ���
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
                    %���������ʾ��ϸ��Ϣ����ô�ڷ����������ϵ�Cluster֮����������
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
            %���������ж�Redundantly Rigidity��Ҫ�ı��б�
            %����б��ǽ�ԭ���ı��б�ÿȥ��һ���Ժ󣬵õ���һ��Ԫ��
            
            %�õ��߸���
            EdgesNumber = height(EdgeTable);
            
            %�������ڴ洢��Щ���б���б����
            EdgeTableList = containers.ArrayList(EdgesNumber);
            
            for i = 1:1:EdgesNumber
                RemoveOneTable = EdgeTable;
                RemoveOneTable(i,:) = [];
                EdgeTableList.appendElement(RemoveOneTable);
            end
        end
        
        function [kConnected,FailedGraph] = kConnectedCheck(EdgeTable,NodeTable,k,XDATA,YDATA,Detail)
            %k���Ӽ�麯���ߡ�
            kConnected = true;
            FailedGraph = containers.ArrayList(1);
            %������м�����˼��ʧ�ܣ���ʧ��ʱ���ͼ�������FailedGraph���档
            
            %���ɴ�����ͼ
            G = graph(EdgeTable,NodeTable);
            
            if(k == 1)
                %����������1���ӵ�ʱ����Ҫ���⴦��
                ConnectComponent = G.conncomp();
                %������Ӽ������ֵ
                M_ConnectComponent = max(ConnectComponent);
                if(M_ConnectComponent ~= 1)
                        %˵���������ӵ�ͼ
                        kConnected = false;
                        FailedGraph = containers.ArrayList(1);
                        FailedGraph.appendElement(G);
                        disp('������һ�μ��ʧ��');
                end
                return;
            end
            

            %�õ��ڵ����
            NodesNumber = height(NodeTable);
            
            %���������Ҫ���б����
            FailedGraphLong = 0;
            for RemoveM = 1:1:(k-1)
                FailedGraphLong = FailedGraphLong + nchoosek(NodesNumber,RemoveM);
            end
            %���ɼ��ʧ�ܵĽڵ��б�
            FailedGraph = containers.ArrayList(FailedGraphLong);
            
            for RemoveM = 1:1:(k-1)
                %�����Ƴ�RemoveM���ڵ��Ժ�ģ��ڵ��б����
                NodeList = combnk(1:NodesNumber,(NodesNumber - RemoveM));
                [m,~] = size(NodeList);
                for Counter = 1:1:m
                    %ȡ��ÿһ��Ԫ�أ�������ͼ
                    ASubGraph = G.subgraph(NodeList(Counter,:));
                    if(strcmp(Detail,'VeryDetailed'))
                            figure('Name',num2str(NodeList(Counter,:)),'NumberTitle','on');
                            %�����ͼ����ʾ����
                            X = XDATA(NodeList(Counter,:));
                            Y = YDATA(NodeList(Counter,:));
                            ASubGraph.plot('XData',X,'YData',Y);
                            drawnow;
                    end
                    
                    %�����ͼ�����Ӽ���Ϣ
                    ConnectComponent = ASubGraph.conncomp();
                    %������Ӽ������ֵ
                    M_ConnectComponent = max(ConnectComponent);
                    if(M_ConnectComponent ~= 1)
                        %˵���������ӵ�ͼ
                        kConnected = false;
                        FailedGraph.appendElement(ASubGraph);
                        disp('������һ�μ��ʧ��');
                        if(strcmp(Detail,'detail'))
                            figure('Name',num2str(NodeList(Counter,:)),'NumberTitle','on');
                            %�����ͼ����ʾ����
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