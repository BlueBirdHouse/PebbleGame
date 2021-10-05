%��������5

%�����ò���������
%��һ��
%T = [1 2 ; 1 3 ; 1 10 ; 2 3 ; 2 4 ;2 9 ; 3 4 ; 3 5 ; 3 8 ; 4 5 ; 4 7 ; 5 6 ; 6 7 ; 6 8 ; 7 8 ; 7 9 ; 8 9 ; 8 10 ; 9 10];

%% �ڶ���(3������)
T1 = [1 3 ; 1 5 ; 3 5 ];
T2 = T1 + 1;
T3 = [1 2 ; 3 4 ; 5 6 ];
T = [T1 ; T2 ; T3];

EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);

%% ������Բ��ԡ�
[Redundantly,NotRedundantlyEdgeTables] = PebbleGame.Rigidity.IsRedundantlyRigidGraph('detail');
disp('������Բ�����ϣ�лл�㣡');

%% 3���Ӳ���
EdgeTable = PebbleGame.UserInPut.Graph.Edges;
NodeTable = PebbleGame.UserInPut.Graph.Nodes;
[kConnected,FailedGraph] = PebbleGame.Rigidity.kConnectedCheck(EdgeTable,NodeTable,3,PebbleGame.Operation.XData,PebbleGame.Operation.YData,'VeryDetailed');
disp('�����Ӳ�����ϣ�лл�㣡');