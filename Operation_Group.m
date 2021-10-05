classdef Operation_Group < handle
    %UserInPut 用于完成泡泡覆盖的工作，即判断边的独立性。
    
    properties
        Graph = digraph(); %不是handle。相当于作者的pebble index。
        GraphPlot; %是handle，显示内容的句柄。
        GraphFigure; %是handle,绘图窗口的句柄。
        
        %绘图数据，这个数据只能在初始化的时候写入，一直不变；
        XData;
        YData;
        
        %用户需要增加上去的边
        EdgeReadyForAdd; %还没有被增加到图上的边。
        EdgeUnableAdd; %不能被增加到图上的边。重复边：redundant bound。
        WorkingEdge; %当前正在尝试增加的边，初始化为0.是二元数组，不是一个表！
        
        %拉曼图的节点。当不能找到第四个泡泡的时候，搜索的路径经过的那些节点。
        %由于边是逐渐增加上去的，所以这个列表内的很多项都需要合并.
        %handle类
        LamanNodesList; 
        
        %用来保存LamanEdges的列表。
        %这个列表后期经过合并，最后得到LamanSubgraphs各图包含的边。
        %根据LamanNodesList中包含的内容，在用到的时候初始化。
        %handle类
        LamanEdgesList;
        
        %用于在存储边的时候作为模板。其结构与EdgeReadyForAdd一样，但是一个空表。
        EdgeTempletTable; 
        
        %创建handle着色类。其中含有RigidCluster的编号，对应边的颜色。
        %在StartIdentifyRigidCluster()中首次初始化。
        RigidClusterEdgeColor;
        
        %改变边的方向导致了原有边上信息丢失。在特殊应用中，需要保持这些信息。
        %打开这些开关，就会保持删除边和增加边两次操作的附加信息。
        UnCoverCoverInfoBridge = false;
        UnCoverCoverInfo;
    end
    
    methods
        function obj = Operation_Group(names,xdata,ydata,edgereadyforadd)
            %n是节点个数，用于生成一个只有节点但是没边的有向图
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
            
            obj.GraphFigure = figure('Name','操作图，没操作完毕以前不要关闭！','NumberTitle','on');
            
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
            % 检查输入的ID是否在ID的范围内.
            assert(all(imag(NodeID) == 0) && all(mod(NodeID,1) == 0), ...
                   'simiam:NotRealInteger', ...
                   'NodeID must be a real integer.')
            assert(NodeID > 0 && NodeID < Inf, ...
                   'simiam:OutOfBounds', ...
                   'NodeID must be greater than zero and less than infinity.');
            A = obj.Graph.adjacency;
            [n,~] = size(A);
            if(NodeID > n)
                error('NodeID数超过节点个数');
            end
        end
        
        function EdgeNodeMatch(obj,NodeID,Edge)
            %检查nodeIDs是否是VertexA或VertexB其中之一。如果不是，出错退出。
             VertexA = Edge(1,1);
             VertexB = Edge(1,2);
             if (NodeID ~= VertexA) && (NodeID ~= VertexB)
                 error('边和节点号不对应！');
             end
        end
        
        function [isCovered] = EdgeisCovered(obj,Edge)
            %检查Graph的边[ VertexA, VertexB]是否已经被覆盖了。注意边的顺序。
            VertexA = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.Graph.findedge(VertexA, VertexB) == 0)
                isCovered = false;
            else
                isCovered = true;
            end
        end
        
        function [FreePebbleNumber] = ReadFreePebbleNumber (obj,NodeID)
            % 表查询，给出NodeID节点上的FreePebble个数。
            FreePebbleNumber = obj.Graph.Nodes.FreePebble(NodeID);
        end
        
        function WriteFreePebbleNumber_(obj,NodeID, FreePebbleNumber)
            if(FreePebbleNumber > 2)
                error('写入了多余两个泡泡数值');
            end
            obj.Graph.Nodes.FreePebble(NodeID) = FreePebbleNumber;
        end
        
        function [PinNumber] = ReadPin(obj,NodeID)
            % 表查询，给出NodeID节点上的Pin个数。
            PinNumber = obj.Graph.Nodes.Pin(NodeID);
        end
        
        function WritePin_(obj,NodeID, PinNumber)
            % 表写入，改写NodeID节点上的Pin个数为Pin Number。
            obj.Graph.Nodes.Pin(NodeID) = PinNumber;
        end
        
        function PinPebble(obj,NodeID, NumbertoPin)
            % 暂时钉住NumbertoPin个泡泡不让它们移动.
            obj.IDIntheRange(NodeID);
            if(obj.ReadFreePebbleNumber(NodeID) < NumbertoPin)
                error('操作不能完成，没有那么多FreePebble可Pin');
            end
            Temp = obj.ReadFreePebbleNumber(NodeID) - NumbertoPin;
            obj.WriteFreePebbleNumber_(NodeID,Temp);
            Temp = obj.ReadPin(NodeID) + NumbertoPin;
            obj.WritePin_(NodeID,Temp);
            
        end
        
        function UnPinPebble(obj,NodeID, NumbertoUnPin)
            %将NumbertoUnPin个泡泡转换为FreePebble。
            obj.IDIntheRange(NodeID);
            if(obj.ReadPin(NodeID)<NumbertoUnPin)
                error('没有那么多Pin泡泡可以变为FreePebble');
            end
            Temp = NumbertoUnPin + obj.ReadFreePebbleNumber(NodeID);
            if(Temp > 2)
                error('操作不能完成，会导致当前结点FreePebble太多');
            end
            obj.WriteFreePebbleNumber_(NodeID,Temp);
            Temp = obj.ReadPin(NodeID) - NumbertoUnPin;
            obj.WritePin_(NodeID,Temp);
        end
        
        function AutoUnPinAPebble(obj)
            %全图操作。如果有泡泡空位的话，自动从Pin的泡泡里面UnPin一个出来。
            if(obj.HowManyPin() <= 0)
                error('全图没有任何被Pin住的泡泡。');
            end
            [n,~] = size(obj.Graph.adjacency);
            for i = 1:1:n
                try
                    obj.UnPinPebble(i,1);
                catch
                end
            end
            if(obj.HowManyPin > 0)
                disp('仍然有被Pin住的泡泡。');
            end
        end
        
        function [TotalFreePebbleNumber] = HowManyFreePebble(obj)
            %计算当前全图共有多少个FreePebble。
            TotalFreePebbleNumber = sum(obj.Graph.Nodes.FreePebble,1);
        end
        
        function [TotalPinNumber] = HowManyPin(obj)
            %计算当前全图共有多少个Pin。
            TotalPinNumber = sum(obj.Graph.Nodes.Pin,1);
        end
        
        function CovertheEdge_(obj,Edge)
            %利用DonateVertex上的FreePebble覆盖[ VertexA, VertexB]。
            %DonateVertex一定是[ VertexA, VertexB]相邻的。
            DonateVertex = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.EdgeisCovered(Edge) == true)
                error('这条边已经被覆盖了。');
            end
            if(obj.ReadFreePebbleNumber(DonateVertex) <= 0)
                error('DonateVertex上没有FreePebble可供覆盖。');
            end
            obj.Graph = obj.Graph.addedge(DonateVertex,VertexB,1);
            
            %检查通信桥是否打开，如果打开，增加保留的信息。
            if(obj.UnCoverCoverInfoBridge == true)
                SavedEndNodes = obj.UnCoverCoverInfo.Edges.EndNodes(1,:);
                SavedEndNodesA = str2num(SavedEndNodes{1,1});
                SavedEndNodesB = str2num(SavedEndNodes{1,2});
                if (VertexB == SavedEndNodesA) && (DonateVertex == SavedEndNodesB)
                    edgeID = obj.Graph.findedge(DonateVertex, VertexB);
                    obj.Graph.Edges.Color(edgeID,:) = obj.UnCoverCoverInfo.Edges.Color(1,:);
                    obj.Graph.Edges.Cluster(edgeID) = obj.UnCoverCoverInfo.Edges.Cluster(1);
                else
                    error('UnCoverCoverInfoBridge已经打开，但是增加边的时候，额外信息不符');
                end
            end
            
            Temp = obj.ReadFreePebbleNumber(DonateVertex) - 1;
            obj.WriteFreePebbleNumber_(DonateVertex,Temp);
            obj.Show();
        end
        
        function UnCovertheEdge_(obj,Edge)
            %解除对边的覆盖，并将泡泡归还给VertexA。
            VertexA = Edge(1,1);
            VertexB = Edge(1,2);
            if(obj.EdgeisCovered(Edge) == false)
                error('这条边没有被覆盖。');
            end
            if(obj.ReadFreePebbleNumber(VertexA) >= 2)
                error('Source节点上的FreePebble太多。');
            end
            
            %检查通信桥是否打开，如果打开，保留即将移除边的信息。
            if(obj.UnCoverCoverInfoBridge == true)
                obj.UnCoverCoverInfo = obj.Graph.subgraph([VertexA VertexB]);
            end
            
            obj.Graph = obj.Graph.rmedge(VertexA, VertexB);
            Temp = obj.ReadFreePebbleNumber(VertexA) + 1;
            obj.WriteFreePebbleNumber_(VertexA,Temp);
            obj.Show();
        end
        
        function TryToAddaEdge(obj,EdgeReadyForAddNumber, WHERE)
        %开始尝试将某一条边增加到Graph上面去。
            if(strcmp(WHERE,'database') ~= true)
                error('数据源选择错误。');
            end
            if(obj.WorkingEdge ~= 0)
                error('上一次操作没有完成。如果这条边不能够被覆盖，建议执行承认失败功能。');
            end
            obj.WorkingEdge = obj.EdgeReadyForAdd.EndNodes(EdgeReadyForAddNumber,:);
            obj.EdgeReadyForAdd(EdgeReadyForAddNumber,:) = [];
            obj.Show();
            obj.GraphPlot.highlight(obj.WorkingEdge,'NodeColor','y', 'EdgeColor','y','LineWidth',1.5);
        end
        
        function CoverWorkingEdge(obj)
            %利用WorkingEdge相关联的两个节点中的任何一个上面的FreePebble来覆盖WorkingEdge。
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
            error('WorkingEdge相关联的节点上没有FreePebble。尝试为其寻找FreePebble');
        end
        
        function UnabletoCoverWorkingEdge(obj)
            %如果实在不能够找到FreePebble来覆盖WorkingEdge，那么使用这个函数放弃。
            if(obj.WorkingEdge == 0)
                error('WorkingEdge是空的。');
            end
            obj.EdgeUnableAdd{end+1,:} = obj.WorkingEdge;
            obj.WorkingEdge = 0;
            obj.Show();
        end
        
        function [PathtoFreePebble, BreadthFirstSearch] = FindAPebble(obj,nodeID)
            %从nodeID开始，沿着donate的方向，发现一个FreePebble
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
            %按照PathtoFreePebble指示的方向，从路径尾节点上开始交换覆盖，
            %从而使得头部得到一个FreePebble。
            if(PathtoFreePebble == 0)
                error('无效的路径');
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
            %检测EdgeReadyForAdd中由EdgeReadyForAddNumber指定的边是否是独立边。
            obj.TryToAddaEdge(EdgeReadyForAddNumber,'database');
            WorkingNodeA = obj.WorkingEdge(1,1);
            WorkingNodeB = obj.WorkingEdge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            
            CollectedFreePebbleNumber = 0;
            
            %针对WorkingNodeA收集第一个泡泡。
            %注意，即便WorkingNodeA本身就有FreePebble也是没有关系的。
            try %首先尝试在WorkingNodeA上收集第一个FreePebble。除非找不到FreePebble才会出错。
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['需要详细研究。为什么在节点',num2str(WorkingNodeA),'上一个自由泡泡也收集不到！'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Independent = -1;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeA,1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            
            %针对WorkingNodeB收集第一个泡泡。
            %注意，即便WorkingNodeB本身就有FreePebble也是没有关系的。
            try %首先尝试在WorkingNodeB上收集第一个FreePebble。除非找不到FreePebble才会出错。
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['需要详细研究。为什么在节点',num2str(WorkingNodeB),'上一个自由泡泡也收集不到！'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Independent = -2;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeB,1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            
            %下面就可能出现找不到FreePebble的情况了。
            BreadthFirstSearch_A = 0;
            BreadthFirstSearch_B = 0;
            
            %在WorkingNodeA上收集第三个FreePebble。
            FailedA = false;
            try
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %发现在WorkingNodeA上面不能发现第三个泡泡。
                %保存宽度优先算法的结果以便生成Laman Subgraphs.
                BreadthFirstSearch_A = BreadthFirstSearch;
                FailedA = true;
            end
            if(FailedA == false)
                %说明找到了FreePebble。
                obj.PinPebble(WorkingNodeA,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            end
            
            %在WorkingNodeB上收集第四个FreePebble。
            FailedB = false;
            try
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %发现在WorkingNodeB上面不能发现第三个泡泡。
                %保存宽度优先算法的结果以便生成Laman Subgraphs.
                BreadthFirstSearch_B = BreadthFirstSearch;
                FailedB = true;
            end
            if(FailedB == false)
                %说明找到了FreePebble。
                obj.PinPebble(WorkingNodeB,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber + 1;
            end
            
            if(CollectedFreePebbleNumber < 3)
                error('同时找不到第三个和第四个泡泡，需要自己研究。');
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
                error('找到了5个甚至以上的FreePebble，这是不可能的。');
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
            % 启动RigidCluster识别工作，主要为识别做数值准备。
            % 初始化RigidCluster标识和颜色类。
            % 为Graph. Edges表增加Cluster列。
            % 为Graph. Edges表增加Color列。
            % 为Graph. Nodes表增加Visited列。
            obj.RigidClusterEdgeColor = color.ContrastColor();
            n = height(obj.Graph.Edges);
            obj.Graph.Edges.Cluster = ones(n,1)*(-1);
            obj.Graph.Edges.Color = zeros(n,3);
            
            n = height(obj.Graph.Nodes);
            obj.Graph.Nodes.Visited = zeros(n,1);
            
            %打开通信桥
            obj.UnCoverCoverInfoBridge = true;
        end
        
        function [ClusterNumber] = ReadCluster(obj,Edge)
            % 表读取，读取边的RigidCluster归属信息。
            % Edge一定是数值性的横向数组
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
            if(edgeID == 0)
                error('没有这么一条边。');
            end
            ClusterNumber = obj.Graph.Edges.Cluster(edgeID);
        end
        
        function [ClusterNumber] = ReadColour(obj,Edge)
            % 表读取，读取边的RigidCluster相关联的颜色信息。
            % Edge一定是数值性的横向数组
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
            if(edgeID == 0)
                error('没有这么一条边。');
            end
            ClusterNumber = obj.Graph.Edges.Color(edgeID,:);
        end
        
        function [] = WriteAllCluster_(obj,NodeIDs, ClusterNumber)
            %将NodeIDs中所包含的所有边的Cluster均设定为ClusterNumber。
            %用于处理同时需要设定很多值的情况。
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
            %将NodeIDs中所包含的所有边的Graph.Edges.Color()均设定为ColourInformation。。
            %用于处理同时需要设定很多值的情况。
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
            % 返回NodeID的所有邻居。包括前向邻居和后向邻居。
            % 注意这个是有向图，需要找到preIDs = predecessors(G, NodeID)，sucIDs = successors(G, NodeID)。
            %然后合并在一起。
            P = obj.Graph.predecessors(NodeID);
            S = obj.Graph.successors(NodeID);
            Neighbours = [P ; S];
        end
        
        function [] = WriteAllVisited_(obj,NodeIDs, Logical)
            %遍历NodeIDs中的所有节点，将每一个节点的Visited均设定为Logical。
            %用于处理同时需要设定很多值的情况。
            [m,n] = size(NodeIDs);
            n = max(m,n);
            for i = 1:1:n
                obj.Graph.Nodes.Visited(NodeIDs(i)) = Logical;
            end
        end
        
        function [Logical] = IsVisited(obj,NodeID)
            %返回节点NodeID的Visited状态。
            Logical = obj.Graph.Nodes.Visited(NodeID);
        end
        
        function [Explore, NodeIDs] = ExploreARigidClusterNode(obj,Edge, ExploreNode)
            % 判断ExploreNode相对于edge的性质，暂时不管边的事情。
            % Explore=true，发现了Rigid节点，则NodeIDs里面包含这些节点,也包含ExploreNode。。
            % Explore=false，发现了floppy节点，则NodeIDs里面包含这些节点,也包含ExploreNode。。
            
            %edge是已经被标记过属于现存的某一个RigidCluster的边。
            
            %提取edge的两个点WorkingNodeA，WorkingNodeB。
            WorkingNodeA = Edge(1,1);
            WorkingNodeB = Edge(1,2);
            
            %输入有效性检查
            obj.IDIntheRange(WorkingNodeA);
            obj.IDIntheRange(WorkingNodeB);
            obj.IDIntheRange(ExploreNode);
            if(obj.EdgeisCovered([WorkingNodeA WorkingNodeB]) == false)
                error('输入的edge在图上并不存在。');
            end
            
            %记录这个过程一共收集到了多少个FreePebble。
            CollectedFreePebbleNumber = 0;
            
            %开始第一和第二泡泡收集过程
            %针对WorkingNodeA收集第一个泡泡。
            %注意，即便WorkingNodeA本身就有FreePebble也是没有关系的。
            %首先尝试在WorkingNodeA上收集第一个FreePebble。
            %除非找不到FreePebble才会出错。
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['需要详细研究。为什么在节点',num2str(WorkingNodeA),'上一个自由泡泡也收集不到！'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Explore = -1;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeA, 1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            
            %针对WorkingNodeB收集第一个泡泡。
            %注意，即便ExploreNode本身就有FreePebble也是没有关系的。
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME
                msg = ['需要详细研究。为什么在节点',num2str(WorkingNodeB),'上一个自由泡泡也收集不到！'];
                causeException = MException('MATLAB:myCode:IndependentEdge',msg);
                ME = addCause(ME,causeException);
                Explore = -2;
                rethrow(ME);
            end
            obj.PinPebble(WorkingNodeB, 1);
            CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;

            %下面就可能出现找不到FreePebble的情况了。
            
            %在WorkingNodeA上第二次收集FreePebble。
            FailedA = false; %在WorkingNodeA上第二次收集到泡泡是否失败的标志。
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeA);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %发现在WorkingNodeA上面不能发现泡泡。
                FailedA = true;
            end
            if(FailedA==false)
                %如果是，说明找到了FreePebble。
                obj.PinPebble(WorkingNodeA,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            end

            %在WorkingNodeB上第二次收集FreePebble。
            FailedB = false; %在WorkingNodeB上第二次收集到泡泡是否失败的标志。
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(WorkingNodeB);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %发现在WorkingNodeA上面不能发现泡泡。
                FailedB = true;
            end
            if(FailedB==false)
                %如果是，说明找到了FreePebble。
                obj.PinPebble(WorkingNodeB,1);
                CollectedFreePebbleNumber = CollectedFreePebbleNumber+1;
            end
            
            if(CollectedFreePebbleNumber ~= 3)
                error(strcat('收集到了 ',num2str(CollectedFreePebbleNumber),' 个泡泡，真是奇怪。'));
                Explore = -3;
                return;
            end
            
            %下面开始在ExploreNode上找第四个FreePebble
            FailedExploreNode = false;
            try 
                [PathtoFreePebble, BreadthFirstSearch] = obj.FindAPebble(ExploreNode);
                obj.RearrangePebble(PathtoFreePebble);
            catch ME %发现在WorkingNodeA上面不能发现泡泡。
                FailedExploreNode = true;
            end
            
            %下面开始判断并输出结果
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
            
            %释放Pin住的泡泡
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
            %识别出一个RigidCluster。
            %这个函数运行的前提是认为前面一个标记的RigidCluster完全探索完毕了。
            %如果发现所有的边均被标记了，就会返回true，否则返回false.
            
            %得到节点个数。
            n = height(obj.Graph.Nodes);
            %生成待分析节点列表。
            ToVisitNodes = containers.ZipNumList(n);
            %标记所有的节点均为没有访问过。
            obj.WriteAllVisited_([1:1:n],false);

            %设定输出默认值。
            IdentifyFinished = false;
            
            %得到边数。
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
            
            %提取与WorkingEdge相关联的WorkingNodeA和WorkingNodeB。
            [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(WorkingEdgesID);
            obj.RigidClusterEdgeColor.Flash();
            %为这条边标记RigidCluster数据
            obj.WriteAllCluster_([WorkingNodeA ; WorkingNodeB],obj.RigidClusterEdgeColor.Counter);
            obj.WriteAllColour_([WorkingNodeA ; WorkingNodeB],obj.RigidClusterEdgeColor.ColorRGB);
            obj.WriteAllVisited_([WorkingNodeA ; WorkingNodeB],true);
            
            %提取WorkingNodeA邻居
            NeighboursWorkingNodeA = obj.AllNeighbour(WorkingNodeA);
            [m,n] = size(NeighboursWorkingNodeA);
            n = max(m,n);
            for i = 1:1:n
                Printer = NeighboursWorkingNodeA(i);
                if(obj.IsVisited(Printer) == false)
                    ToVisitNodes.appendElement(Printer);
                end
            end
            
            %提取WorkingNodeB邻居
            NeighboursWorkingNodeB = obj.AllNeighbour(WorkingNodeB);
            [m,n] = size(NeighboursWorkingNodeB);
            n = max(m,n);
            for i = 1:1:n
                Printer = NeighboursWorkingNodeB(i);
                if(obj.IsVisited(Printer) == false)
                    ToVisitNodes.appendElement(Printer);
                end
            end
            
            %精简化ToVisitNodes
            ToVisitNodes.ZipList();
            
            if(ToVisitNodes.Count == 0)
                IdentifyFinished = true;
                return;
            end
            
            %下面开始做一个超级迭代
            while(ToVisitNodes.Count ~= 0)
                %首先弹出来一个
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
                                %这里增加了一次列表压缩，应为出现了一次超出列表容限的情况。
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
            %得到边数。
            e = height(obj.Graph.Edges);
            for i = 1:1:e
                Color = obj.Graph.Edges.Color(i,:);
                %edgeID = obj.Graph.findedge(WorkingNodeA, WorkingNodeB);
                [WorkingNodeA, WorkingNodeB] = obj.Graph.findedge(i);
                obj.GraphPlot.highlight(WorkingNodeA,WorkingNodeB,'EdgeColor',Color);
            end
        end
        
        function Show(obj)
            %生成新的生成新的GraphPlot对象。
            figure(obj.GraphFigure);
            obj.GraphPlot = obj.Graph.plot('XData',obj.XData,'YData',obj.YData,'EdgeColor','k');
            %遍历每一个节点
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
                    error(strcat('出现了拥有过多泡泡的节点:',num2str(i)));
                end
                if(obj.ReadFreePebbleNumber(i) < 0)
                    error(strcat('部分节点出现了负值泡泡:',num2str(i)));
                end
            end
        end
    end
    
end

