classdef Operation_Group < handle
    %UserInPut ����������ݸ��ǵĹ��������жϱߵĶ����ԡ�
    
    properties
        Graph = digraph(); %����handle���൱�����ߵ�pebble index��
        GraphPlot; %��handle����ʾ���ݵľ����
        GraphFigure; %��handle,��ͼ���ڵľ����
        
        %��ͼ���ݣ��������ֻ���ڳ�ʼ����ʱ��д�룬һֱ���䣻
        XData;
        YData;
        
        %�û���Ҫ������ȥ�ı�
        EdgeReadyForAdd; %��û�б����ӵ�ͼ�ϵıߡ�
        EdgeUnableAdd; %���ܱ����ӵ�ͼ�ϵıߡ��ظ��ߣ�redundant bound��
        WorkingEdge; %��ǰ���ڳ������ӵıߣ���ʼ��Ϊ0.�Ƕ�Ԫ���飬����һ����
        
        %����ͼ�Ľڵ㡣�������ҵ����ĸ����ݵ�ʱ��������·����������Щ�ڵ㡣
        %���ڱ�����������ȥ�ģ���������б��ڵĺܶ����Ҫ�ϲ�.
        %handle��
        LamanNodesList; 
        
        %��������LamanEdges���б�
        %����б���ھ����ϲ������õ�LamanSubgraphs��ͼ�����ıߡ�
        %����LamanNodesList�а��������ݣ����õ���ʱ���ʼ����
        %handle��
        LamanEdgesList;
        
        %�����ڴ洢�ߵ�ʱ����Ϊģ�塣��ṹ��EdgeReadyForAddһ��������һ���ձ�
        EdgeTempletTable; 
        
        %����handle��ɫ�ࡣ���к���RigidCluster�ı�ţ���Ӧ�ߵ���ɫ��
        %��StartIdentifyRigidCluster()���״γ�ʼ����
        RigidClusterEdgeColor;
        
        %�ı�ߵķ�������ԭ�б�����Ϣ��ʧ��������Ӧ���У���Ҫ������Щ��Ϣ��
        %����Щ���أ��ͻᱣ��ɾ���ߺ����ӱ����β����ĸ�����Ϣ��
        UnCoverCoverInfoBridge = false;
        UnCoverCoverInfo;
    end
    
    methods
        function obj = Operation_Group(names,xdata,ydata,edgereadyforadd)
            %n�ǽڵ��������������һ��ֻ�нڵ㵫��û�ߵ�����ͼ
            [n,~]= size(names);
            A = eye(n);
            obj.Graph = digraph(A,names,'OmitSelfLoops');
            
            obj.XData = xdata;
            obj.YData = ydata;
            
            obj.EdgeReadyForAdd = edgereadyforadd;
            
            
            obj.EdgeTempletTable = obj.EdgeReadyForAdd;
            obj.EdgeTempletTable(:,:) = [];
            
            obj.EdgeUnableAdd = obj.EdgeTempletTable;
            
            obj.WorkingEdge = 0;
            
            k = (n+1)*n/2;
            obj.LamanNodesList = containers.ArrayList(k);
            
            obj.GraphFigure = figure('Name','����ͼ��û���������ǰ��Ҫ�رգ�','NumberTitle','on');
            
            Name = {'1'};
            for i = 2:1:n
                Name = {Name{1,:} num2str(i)};
            end
            Name = Name';
            FreePebble = ones(n,1)*2;
            Pin = zeros(n,1);
            
            obj.Graph.Nodes.Name = Name;
            obj.Graph.Nodes.FreePebble = FreePebble;
            obj.Graph.Nodes.Pin = Pin;
            
            obj.UnCoverCoverInfoBridge = false;
            
            obj.Show();
        end
        
        function IDIntheRange(obj,NodeID)
            % ��������ID�Ƿ���ID�ķ�Χ��.
            assert(all(imag(NodeID) == 0) && all(mod(NodeID,1) == 0), ...
                   'simiam:NotRealInteger', ...
                   'NodeID must be a real integer.')
            assert(NodeID > 0 && NodeID < Inf, ...
                   'simiam:OutOfBounds', ...
                   'NodeID must be greater than zero and less than infinity.');
            A = obj.Graph.adjacency;
            [n,~] = size(A);
            if(NodeID > n)
                error('NodeID�������ڵ����');
            end
        end
        
        function EdgeNodeMatch(obj,NodeID,Edge)
            %���nodeIDs�Ƿ���VertexA��VertexB����֮һ��������ǣ������˳���
             VertexA = Edge(1,1);
             VertexB = Edge(1,2);
             if (NodeID ~= VertexA) && (NodeID ~= VertexB)
                 error('�ߺͽڵ�Ų���Ӧ��');
             end
        end
        
        function [isCovered] = EdgeisCovered(obj,Edge)
            %���Graph�ı�[ VertexA, VertexB]�Ƿ��Ѿ��������ˡ�ע��ߵ�˳��
            VertexA = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.Graph.findedge(VertexA, VertexB) == 0)
                isCovered = false;
            else
                isCovered = true;
            end
        end
        
        function [FreePebbleNumber] = ReadFreePebbleNumber (obj,NodeID)
            % ���ѯ������NodeID�ڵ��ϵ�FreePebble������
            FreePebbleNumber = obj.Graph.Nodes.FreePebble(NodeID);
        end
        
        function WriteFreePebbleNumber_(obj,NodeID, FreePebbleNumber)
            if(FreePebbleNumber > 2)
                error('д���˶�������������ֵ');
            end
            obj.Graph.Nodes.FreePebble(NodeID) = FreePebbleNumber;
        end
        
        function [PinNumber] = ReadPin(obj,NodeID)
            % ���ѯ������NodeID�ڵ��ϵ�Pin������
            PinNumber = obj.Graph.Nodes.Pin(NodeID);
        end
        
        function WritePin_(obj,NodeID, PinNumber)
            % ��д�룬��дNodeID�ڵ��ϵ�Pin����ΪPin Number��
            obj.Graph.Nodes.Pin(NodeID) = PinNumber;
        end
        
        function PinPebble(obj,NodeID, NumbertoPin)
            % ��ʱ��סNumbertoPin�����ݲ��������ƶ�.
            obj.IDIntheRange(NodeID);
            if(obj.ReadFreePebbleNumber(NodeID) < NumbertoPin)
                error('����������ɣ�û����ô��FreePebble��Pin');
            end
            Temp = obj.ReadFreePebbleNumber(NodeID) - NumbertoPin;
            obj.WriteFreePebbleNumber_(NodeID,Temp);
            Temp = obj.ReadPin(NodeID) + NumbertoPin;
            obj.WritePin_(NodeID,Temp);
            
        end
        
        function UnPinPebble(obj,NodeID, NumbertoUnPin)
            %��NumbertoUnPin������ת��ΪFreePebble��
            obj.IDIntheRange(NodeID);
            if(obj.ReadPin(NodeID)<NumbertoUnPin)
                error('û����ô��Pin���ݿ��Ա�ΪFreePebble');
            end
            Temp = NumbertoUnPin + obj.ReadFreePebbleNumber(NodeID);
            if(Temp > 2)
                error('����������ɣ��ᵼ�µ�ǰ���FreePebble̫��');
            end
            obj.WriteFreePebbleNumber_(NodeID,Temp);
            Temp = obj.ReadPin(NodeID) - NumbertoUnPin;
            obj.WritePin_(NodeID,Temp);
        end
        
        function AutoUnPinAPebble(obj)
            %ȫͼ��������������ݿ�λ�Ļ����Զ���Pin����������UnPinһ��������
            if(obj.HowManyPin() <= 0)
                error('ȫͼû���κα�Pinס�����ݡ�');
            end
            [n,~] = size(obj.Graph.adjacency);
            for i = 1:1:n
                try
                    obj.UnPinPebble(i,1);
                catch
                end
            end
            if(obj.HowManyPin > 0)
                disp('��Ȼ�б�Pinס�����ݡ�');
            end
        end
        
        function [TotalFreePebbleNumber] = HowManyFreePebble(obj)
            %���㵱ǰȫͼ���ж��ٸ�FreePebble��
            TotalFreePebbleNumber = sum(obj.Graph.Nodes.FreePebble,1);
        end
        
        function [TotalPinNumber] = HowManyPin(obj)
            %���㵱ǰȫͼ���ж��ٸ�Pin��
            TotalPinNumber = sum(obj.Graph.Nodes.Pin,1);
        end
        
        function CovertheEdge_(obj,Edge)
            %����DonateVertex�ϵ�FreePebble����[ VertexA, VertexB]��
            %DonateVertexһ����[ VertexA, VertexB]���ڵġ�
            DonateVertex = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.EdgeisCovered(Edge) == true)
                error('�������Ѿ��������ˡ�');
            end
            if(obj.ReadFreePebbleNumber(DonateVertex) <= 0)
                error('DonateVertex��û��FreePebble�ɹ����ǡ�');
            end
            obj.Graph = obj.Graph.addedge(DonateVertex,VertexB,1);
            
            %���ͨ�����Ƿ�򿪣�����򿪣����ӱ�������Ϣ��
            if(obj.UnCoverCoverInfoBridge == true)
                SavedEndNodes = obj.UnCoverCoverInfo.Edges.EndNodes(1,:);
                SavedEndNodesA = str2num(SavedEndNodes{1,1});
                SavedEndNodesB = str2num(SavedEndNodes{1,2});
                if (VertexB == SavedEndNodesA) && (DonateVertex == SavedEndNodesB)
                    edgeID = obj.Graph.findedge(DonateVertex, VertexB);
                    obj.Graph.Edges.Color(edgeID,:) = obj.UnCoverCoverInfo.Edges.Color(1,:);
                    obj.Graph.Edges.Cluster(edgeID) = obj.UnCoverCoverInfo.Edges.Cluster(1);
                else
                    error('UnCoverCoverInfoBridge�Ѿ��򿪣��������ӱߵ�ʱ�򣬶�����Ϣ����');
                end
            end
            
            Temp = obj.ReadFreePebbleNumber(DonateVertex) - 1;
            obj.WriteFreePebbleNumber_(DonateVertex,Temp);
            obj.Show();
        end
        
        function UnCovertheEdge_(obj,Edge)
            %����Աߵĸ��ǣ��������ݹ黹��VertexA��
            VertexA = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.EdgeisCovered(Edge) == false)
                error('������û�б����ǡ�');
            end
            if(obj.ReadFreePebbleNumber(VertexA) >= 2)
                error('Source�ڵ��ϵ�FreePebble̫�ࡣ');
            end
            
            %���ͨ�����Ƿ�򿪣�����򿪣����������Ƴ��ߵ���Ϣ��
            if(obj.UnCoverCoverInfoBridge == true)
                obj.UnCoverCoverInfo = obj.Graph.subgraph([VertexA VertexB]);
            end
            
            obj.Graph = obj.Graph.rmedge(VertexA, VertexB);
            Temp = obj.ReadFreePebbleNumber(VertexA) + 1;
            obj.WriteFreePebbleNumber_(VertexA,Temp);
            obj.Show();
        end
        
        function TryToAddaEdge(obj,EdgeReadyForAddNumber, WHERE)
        %��ʼ���Խ�ĳһ�������ӵ�Graph����ȥ��
            if(strcmp(WHERE,'database') ~= true)
                error('����Դѡ�����');
            end
            if(obj.WorkingEdge ~= 0)
                error('��һ�β���û����ɡ���������߲��ܹ������ǣ�����ִ�г���ʧ�ܹ��ܡ�');
            end
            obj.WorkingEdge = obj.EdgeReadyForAdd.EndNodes(EdgeReadyForAddNumber,:);
            obj.EdgeReadyForAdd(EdgeReadyForAddNumber,:) = [];
            obj.Show();
            obj.GraphPlot.highlight(obj.WorkingEdge,'NodeColor','y', 'EdgeColor','y','LineWidth',1.5);
        end
        
        function CoverWorkingEdge(obj)
            %����WorkingEdge������������ڵ��е��κ�һ�������FreePebble������WorkingEdge��
            WorkingNodeA = obj.WorkingEdge(1,1);
            WorkingNodeB = obj.WorkingEdge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            if(obj.ReadFreePebbleNumber(WorkingNodeA) > 0)
                obj.CovertheEdge_([WorkingNodeA WorkingNodeB]);
                WorkingNodeA = 0;
                WorkingNodeB = 0;
                obj.WorkingEdge = 0;
                obj.Show();
                return;
            end
            if(obj.ReadFreePebbleNumber(WorkingNodeB) > 0)
                obj.CovertheEdge_([WorkingNodeB WorkingNodeA]);
                WorkingNodeA = 0;
                WorkingNodeB = 0;
                obj.WorkingEdge = 0;
                obj.Show();
                return;
            end
            error('WorkingEdge������Ľڵ���û��FreePebble������Ϊ��Ѱ��FreePebble');
        end
        
        function UnabletoCoverWorkingEdge(obj)
            %���ʵ�ڲ��ܹ��ҵ�FreePebble������WorkingEdge����ôʹ���������������
            if(obj.WorkingEdge == 0)
                error('WorkingEdge�ǿյġ�');
            end
            obj.EdgeUnableAdd{end+1,:} = obj.WorkingEdge;
            obj.WorkingEdge = 0;
            obj.Show();
        end
        
        function [PathtoFreePebble, BreadthFirstSearch] = FindAPebble(obj,nodeID)
            %��nodeID��ʼ������donate�ķ��򣬷���һ��FreePebble
            obj.IDIntheRange(nodeID);
            Search = obj.Graph.bfsearch(nodeID);
            BreadthFirstSearch = Search;
            obj.GraphPlot.highlight(Search, 'NodeColor','y', 'EdgeColor','y','LineWidth',1.5);
            PathtoFreePebble = 0;
            [n,~] = size(Search);
            for i = 1:1:n
                FirstFreePebbleNode = Search(i,1);
                if(obj.ReadFreePebbleNumber(FirstFreePebbleNode) > 0)
                    obj.Show();
                    PathtoFreePebble = obj.Graph.shortestpath(nodeID,FirstFreePebbleNode);
                    obj.GraphPlot.highlight(PathtoFreePebble, 'NodeColor','y', 'EdgeColor','y','LineWidth',1.5);
                    break;
                end
            end
        end
        
        function RearrangePebble(obj,PathtoFreePebble)
            %����PathtoFreePebbleָʾ�ķ��򣬴�·��β�ڵ��Ͽ�ʼ�������ǣ�
            %�Ӷ�ʹ��ͷ���õ�һ��FreePebble��
            if(PathtoFreePebble == 0)
                error('��Ч��·��');
            end
            
            [a,b] = size(PathtoFreePebble);
            a = max(a,b);
            if(a == 1)
                obj.Show();
                return;
            end
            
            for i = a:-1:2
                Head = PathtoFreePebble(i);
                Tail = PathtoFreePebble(i-1);
                obj.UnCovertheEdge_([Tail Head]);
                obj.CovertheEdge_([Head Tail]);
                obj.Show();
            end
        end
        
        function [Independent] = IndependentEdge(obj,EdgeReadyForAddNumber)
            %���EdgeReadyForAdd����EdgeReadyForAddNumberָ���ı��Ƿ��Ƕ����ߡ�
            obj.TryToAddaEdge(EdgeReadyForAddNumber,'database');
            WorkingNodeA = obj.WorkingEdge(1,1);
            WorkingNodeB = obj.WorkingEdge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            
            CollectedFreePebbleNumber = 0;
            
            %���WorkingNodeA�ռ���һ�����ݡ�
            %ע�⣬����WorkingNodeA�������FreePebbleҲ��û�й�ϵ�ġ�
            try %���ȳ�����WorkingNodeA���ռ���һ��FreePebble�������Ҳ���FreePebble�Ż����
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['��Ҫ��ϸ�о���Ϊʲô�ڽڵ�',num2str(WorkingNodeA),'��һ����������Ҳ�ռ�������'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Independent = -1;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeA,1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            
            %���WorkingNodeB�ռ���һ�����ݡ�
            %ע�⣬����WorkingNodeB�������FreePebbleҲ��û�й�ϵ�ġ�
            try %���ȳ�����WorkingNodeB���ռ���һ��FreePebble�������Ҳ���FreePebble�Ż����
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['��Ҫ��ϸ�о���Ϊʲô�ڽڵ�',num2str(WorkingNodeB),'��һ����������Ҳ�ռ�������'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Independent = -2;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeB,1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            
            %����Ϳ��ܳ����Ҳ���FreePebble������ˡ�
            BreadthFirstSearch_A = 0;
            BreadthFirstSearch_B = 0;
            
            %��WorkingNodeA���ռ�������FreePebble��
            FailedA = false;
            try
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %������WorkingNodeA���治�ܷ��ֵ��������ݡ�
                %�����������㷨�Ľ���Ա�����Laman Subgraphs.
                BreadthFirstSearch_A = BreadthFirstSearch;
                FailedA = true;
            end
            if(FailedA == false)
                %˵���ҵ���FreePebble��
                obj.PinPebble(WorkingNodeA,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            end
            
            %��WorkingNodeB���ռ����ĸ�FreePebble��
            FailedB = false;
            try
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %������WorkingNodeB���治�ܷ��ֵ��������ݡ�
                %�����������㷨�Ľ���Ա�����Laman Subgraphs.
                BreadthFirstSearch_B = BreadthFirstSearch;
                FailedB = true;
            end
            if(FailedB == false)
                %˵���ҵ���FreePebble��
                obj.PinPebble(WorkingNodeB,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            end
            
            if(CollectedFreePebbleNumber < 3)
                error('ͬʱ�Ҳ����������͵��ĸ����ݣ���Ҫ�Լ��о���');
            end
            
            if(CollectedFreePebbleNumber == 4)
                obj.UnPinPebble(WorkingNodeA,1);
                obj.CoverWorkingEdge();
                obj.UnPinPebble(WorkingNodeA,1);
                obj.UnPinPebble(WorkingNodeB,2);
                Independent = true;
                obj.Show();
                return;
            end
            
            if(CollectedFreePebbleNumber ~= 3)
                error('�ҵ���5���������ϵ�FreePebble�����ǲ����ܵġ�');
            end
            
            if(FailedB == true)
                obj.UnabletoCoverWorkingEdge();
                obj.UnPinPebble(WorkingNodeA,2);
                obj.UnPinPebble(WorkingNodeB,1);
                obj.LamanNodesList.appendElement(BreadthFirstSearch_B);
                Independent = false;
                obj.Show();
                return;
            end
            
            if(FailedA == true)
                obj.UnabletoCoverWorkingEdge();
                obj.UnPinPebble(WorkingNodeA,1);
                obj.UnPinPebble(WorkingNodeB,2);
                obj.LamanNodesList.appendElement(BreadthFirstSearch_A);
                Independent = false;
                obj.Show();
                return;
            end
        end
        
        function StartIdentifyRigidCluster(obj)
            % ����RigidClusterʶ��������ҪΪʶ������ֵ׼����
            % ��ʼ��RigidCluster��ʶ����ɫ�ࡣ
            % ΪGraph. Edges������Cluster�С�
            % ΪGraph. Edges������Color�С�
            % ΪGraph. Nodes������Visited�С�
            obj.RigidClusterEdgeColor = color.ContrastColor();
            n = height(obj.Graph.Edges);
            obj.Graph.Edges.Cluster = ones(n,1)*(-1);
            obj.Graph.Edges.Color = zeros(n,3);
            
            n = height(obj.Graph.Nodes);
            obj.Graph.Nodes.Visited = zeros(n,1);
            
            %��ͨ����
            obj.UnCoverCoverInfoBridge = true;
        end
        
        function [ClusterNumber] = ReadCluster(obj,Edge)
            % ���ȡ����ȡ�ߵ�RigidCluster������Ϣ��
            % Edgeһ������ֵ�Եĺ�������
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
            if(edgeID == 0)
                error('û����ôһ���ߡ�');
            end
            ClusterNumber = obj.Graph.Edges.Cluster(edgeID);
        end
        
        function [ClusterNumber] = ReadColour(obj,Edge)
            % ���ȡ����ȡ�ߵ�RigidCluster���������ɫ��Ϣ��
            % Edgeһ������ֵ�Եĺ�������
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
            if(edgeID == 0)
                error('û����ôһ���ߡ�');
            end
            ClusterNumber = obj.Graph.Edges.Color(edgeID,:);
        end
        
        function [] = WriteAllCluster_(obj,NodeIDs, ClusterNumber)
            %��NodeIDs�������������бߵ�Cluster���趨ΪClusterNumber��
            %���ڴ���ͬʱ��Ҫ�趨�ܶ�ֵ�������
            n = height(obj.Graph.Edges);
            for i = 1:1:n
                AEdge = obj.Graph.Edges.EndNodes(i,:);
                WorkingNodeA = AEdge(1,1);
                WorkingNodeB = AEdge(1,2);
                edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
                [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(edgeID);
                if isequal(intersect(NodeIDs, WorkingNodeA),WorkingNodeA) && isequal(intersect(NodeIDs, WorkingNodeB),WorkingNodeB)
                    obj.Graph.Edges.Cluster(edgeID) = ClusterNumber;
                end
            end
        end
        
        function [] = WriteAllColour_(obj,NodeIDs, ColourInformation)
            %��NodeIDs�������������бߵ�Graph.Edges.Color()���趨ΪColourInformation����
            %���ڴ���ͬʱ��Ҫ�趨�ܶ�ֵ�������
            n = height(obj.Graph.Edges);
            for i = 1:1:n
                AEdge = obj.Graph.Edges.EndNodes(i,:);
                WorkingNodeA = AEdge(1,1);
                WorkingNodeB = AEdge(1,2);
                edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
                [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(edgeID);
                if isequal(intersect(NodeIDs, WorkingNodeA),WorkingNodeA) && isequal(intersect(NodeIDs, WorkingNodeB),WorkingNodeB)
                    obj.Graph.Edges.Color(edgeID,:) = ColourInformation;
                end
            end
        end
        
        function [Neighbours] = AllNeighbour(obj,NodeID)
            % ����NodeID�������ھӡ�����ǰ���ھӺͺ����ھӡ�
            % ע�����������ͼ����Ҫ�ҵ�preIDs = predecessors(G, NodeID)��sucIDs = successors(G, NodeID)��
            %Ȼ��ϲ���һ��
            P = obj.Graph.predecessors(NodeID);
            S = obj.Graph.successors(NodeID);
            Neighbours = [P ; S];
        end
        
        function [] = WriteAllVisited_(obj,NodeIDs, Logical)
            %����NodeIDs�е����нڵ㣬��ÿһ���ڵ��Visited���趨ΪLogical��
            %���ڴ���ͬʱ��Ҫ�趨�ܶ�ֵ�������
            [m,n] = size(NodeIDs);
            n = max(m,n);
            for i = 1:1:n
                obj.Graph.Nodes.Visited(NodeIDs(i)) = Logical;
            end
        end
        
        function [Logical] = IsVisited(obj,NodeID)
            %���ؽڵ�NodeID��Visited״̬��
            Logical = obj.Graph.Nodes.Visited(NodeID);
        end
        
        function [Explore, NodeIDs] = ExploreARigidClusterNode(obj,Edge, ExploreNode)
            % �ж�ExploreNode�����edge�����ʣ���ʱ���ܱߵ����顣
            % Explore=true��������Rigid�ڵ㣬��NodeIDs���������Щ�ڵ�,Ҳ����ExploreNode����
            % Explore=false��������floppy�ڵ㣬��NodeIDs���������Щ�ڵ�,Ҳ����ExploreNode����
            
            %edge���Ѿ�����ǹ������ִ��ĳһ��RigidCluster�ıߡ�
            
            %��ȡedge��������WorkingNodeA��WorkingNodeB��
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            
            %������Ч�Լ��
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            obj.IDIntheRange(ExploreNode);
            if(obj.EdgeisCovered([WorkingNodeA WorkingNodeB]) == false)
                error('�����edge��ͼ�ϲ������ڡ�');
            end
            
            %��¼�������һ���ռ����˶��ٸ�FreePebble��
            CollectedFreePebbleNumber = 0;
            
            %��ʼ��һ�͵ڶ������ռ�����
            %���WorkingNodeA�ռ���һ�����ݡ�
            %ע�⣬����WorkingNodeA�������FreePebbleҲ��û�й�ϵ�ġ�
            %���ȳ�����WorkingNodeA���ռ���һ��FreePebble��
            %�����Ҳ���FreePebble�Ż����
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['��Ҫ��ϸ�о���Ϊʲô�ڽڵ�',num2str(WorkingNodeA),'��һ����������Ҳ�ռ�������'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Explore = -1;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeA, 1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            
            %���WorkingNodeB�ռ���һ�����ݡ�
            %ע�⣬����ExploreNode�������FreePebbleҲ��û�й�ϵ�ġ�
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['��Ҫ��ϸ�о���Ϊʲô�ڽڵ�',num2str(WorkingNodeB),'��һ����������Ҳ�ռ�������'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Explore = -2;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeB, 1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;

            %����Ϳ��ܳ����Ҳ���FreePebble������ˡ�
            
            %��WorkingNodeA�ϵڶ����ռ�FreePebble��
            FailedA = false; %��WorkingNodeA�ϵڶ����ռ��������Ƿ�ʧ�ܵı�־��
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %������WorkingNodeA���治�ܷ������ݡ�
                FailedA = true;
            end
            if(FailedA==false)
                %����ǣ�˵���ҵ���FreePebble��
                obj.PinPebble(WorkingNodeA,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            end

            %��WorkingNodeB�ϵڶ����ռ�FreePebble��
            FailedB = false; %��WorkingNodeB�ϵڶ����ռ��������Ƿ�ʧ�ܵı�־��
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %������WorkingNodeA���治�ܷ������ݡ�
                FailedB = true;
            end
            if(FailedB==false)
                %����ǣ�˵���ҵ���FreePebble��
                obj.PinPebble(WorkingNodeB,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            end
            
            if(CollectedFreePebbleNumber ~= 3)
                error(strcat('�ռ����� ',num2str(CollectedFreePebbleNumber),' �����ݣ�������֡�'));
                Explore = -3;
                return;
            end
            
            %���濪ʼ��ExploreNode���ҵ��ĸ�FreePebble
            FailedExploreNode = false;
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(ExploreNode);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %������WorkingNodeA���治�ܷ������ݡ�
                FailedExploreNode = true;
            end
            
            %���濪ʼ�жϲ�������
            if(FailedExploreNode == true)
                Explore = true;
                NodeIDs = BreadthFirstSearch;
                obj.WriteAllVisited_(NodeIDs,true(1,1));
                obj.WriteAllVisited_(ExploreNode,true(1,1));
            end
            
            if(FailedExploreNode == false)
                Explore = false;
                NodeIDs = PathtoFreePebble;
                obj.WriteAllVisited_(NodeIDs,2);
                obj.WriteAllVisited_(ExploreNode,2);
            end
            
            %�ͷ�Pinס������
            if(FailedA == true)
                obj.UnPinPebble(WorkingNodeA,1);
                obj.UnPinPebble(WorkingNodeB,2);
            end
            
            if(FailedB == true)
                obj.UnPinPebble(WorkingNodeA,2);
                obj.UnPinPebble(WorkingNodeB,1);
            end
            
            obj.Show();
        end
        
        function [IdentifyFinished] = IdentifyARigidCluster(obj)
            %ʶ���һ��RigidCluster��
            %����������е�ǰ������Ϊǰ��һ����ǵ�RigidCluster��ȫ̽������ˡ�
            %����������еı߾�������ˣ��ͻ᷵��true�����򷵻�false.
            
            %�õ��ڵ������
            n = height(obj.Graph.Nodes);
            %���ɴ������ڵ��б�
            ToVisitNodes = containers.ZipNumList(n);
            %������еĽڵ��Ϊû�з��ʹ���
            obj.WriteAllVisited_([1:1:n],false);

            %�趨���Ĭ��ֵ��
            IdentifyFinished = false;
            
            %�õ�������
            e = height(obj.Graph.Edges);
            for i = 1:1:e
                if(obj.Graph.Edges.Cluster(i) == -1)
                    WorkingEdgesID = i;
                    IdentifyFinished = false;
                    break;
                else
                    IdentifyFinished = true;
                end
            end
            
            if(IdentifyFinished == true)
                return;
            end
            
            %��ȡ��WorkingEdge�������WorkingNodeA��WorkingNodeB��
            [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(WorkingEdgesID);
            obj.RigidClusterEdgeColor.Flash();
            %Ϊ�����߱��RigidCluster����
            obj.WriteAllCluster_([WorkingNodeA ; WorkingNodeB],obj.RigidClusterEdgeColor.Counter);
            obj.WriteAllColour_([WorkingNodeA ; WorkingNodeB],obj.RigidClusterEdgeColor.ColorRGB);
            obj.WriteAllVisited_([WorkingNodeA ; WorkingNodeB],true);
            
            %��ȡWorkingNodeA�ھ�
            NeighboursWorkingNodeA = obj.AllNeighbour(WorkingNodeA);
            [m,n] = size(NeighboursWorkingNodeA);
            n = max(m,n);
            for i = 1:1:n
                Printer = NeighboursWorkingNodeA(i);
                if(obj.IsVisited(Printer) == false)
                    ToVisitNodes.appendElement(Printer);
                end
            end
            
            %��ȡWorkingNodeB�ھ�
            NeighboursWorkingNodeB = obj.AllNeighbour(WorkingNodeB);
            [m,n] = size(NeighboursWorkingNodeB);
            n = max(m,n);
            for i = 1:1:n
                Printer = NeighboursWorkingNodeB(i);
                if(obj.IsVisited(Printer) == false)
                    ToVisitNodes.appendElement(Printer);
                end
            end
            
            %����ToVisitNodes
            ToVisitNodes.ZipList();
            
            if(ToVisitNodes.Count == 0)
                IdentifyFinished = true;
                return;
            end
            
            %���濪ʼ��һ����������
            while(ToVisitNodes.Count ~= 0)
                %���ȵ�����һ��
                ExploreNode = ToVisitNodes.removeLast();
                ExploreNode = ExploreNode{1};
                try
                    [Explore, NodeIDs] = obj.ExploreARigidClusterNode([WorkingNodeA WorkingNodeB], ExploreNode);
                catch
                    [Explore, NodeIDs] = obj.ExploreARigidClusterNode([WorkingNodeB WorkingNodeA], ExploreNode);
                end
                if(Explore == true)
                    [m,n] = size(NodeIDs);
                    n = max(m,n);
                    for i = 1:1:n
                        Printer = NodeIDs(i);
                        NeighboursPrinter = obj.AllNeighbour(Printer);
                        [p,q] = size(NeighboursPrinter);
                        q = max(p,q);
                        for j = 1:1:q
                            ANeighboursPrinter = NeighboursPrinter(j);
                            if(obj.IsVisited(ANeighboursPrinter) == false)
                                ToVisitNodes.appendElement(ANeighboursPrinter);
                                %����������һ���б�ѹ����ӦΪ������һ�γ����б����޵������
                                ToVisitNodes.ZipList();
                            end
                        end
                    end
                end
                ToVisitNodes.ZipList();
            end
            
            n = height(obj.Graph.Nodes);
            RigidNodes = [];
            for i = 1:1:n
                if(obj.IsVisited(i) == true)
                    RigidNodes = [RigidNodes ; i];
                end
            end
            obj.WriteAllCluster_(RigidNodes,obj.RigidClusterEdgeColor.Counter);
            obj.WriteAllColour_(RigidNodes,obj.RigidClusterEdgeColor.ColorRGB);
            
            obj.Show();
        end
        
        function ShowRigidCluster(obj)
            obj.Show();
            %�õ�������
            e = height(obj.Graph.Edges);
            for i = 1:1:e
                Color = obj.Graph.Edges.Color(i,:);
                %edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
                [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(i);
                obj.GraphPlot.highlight(WorkingNodeA,WorkingNodeB,'EdgeColor',Color);
            end
        end
        
        function Show(obj)
            %�����µ������µ�GraphPlot����
            figure(obj.GraphFigure);
            obj.GraphPlot = obj.Graph.plot('XData',obj.XData,'YData',obj.YData,'EdgeColor','k');
            %����ÿһ���ڵ�
            [n,~] = size(obj.Graph.adjacency);
            for i = 1:1:n
                if(obj.ReadFreePebbleNumber(i) == 2)
                    obj.GraphPlot.highlight(i, 'NodeColor','b');
                end
                if(obj.ReadFreePebbleNumber(i) == 1)
                    obj.GraphPlot.highlight(i, 'NodeColor','g');
                end
                if(obj.ReadFreePebbleNumber(i) == 0)
                    obj.GraphPlot.highlight(i, 'NodeColor','k');
                end
                if(obj.ReadFreePebbleNumber(i) > 2)
                    error(strcat('������ӵ�й������ݵĽڵ�:',num2str(i)));
                end
                if(obj.ReadFreePebbleNumber(i) < 0)
                    error(strcat('���ֽڵ�����˸�ֵ����:',num2str(i)));
                end
            end
        end
    end
    
end

