%测试用例5

%论文用测试用例。
%第一版
%T = [1 2 ; 1 3 ; 1 10 ; 2 3 ; 2 4 ;2 9 ; 3 4 ; 3 5 ; 3 8 ; 4 5 ; 4 7 ; 5 6 ; 6 7 ; 6 8 ; 7 8 ; 7 9 ; 8 9 ; 8 10 ; 9 10];

%% 第二版(3个测量)
T1 = [1 3 ; 1 5 ; 3 5 ];
T2 = T1 + 1;
T3 = [1 2 ; 3 4 ; 5 6 ];
T = [T1 ; T2 ; T3];

EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);

%% 冗余刚性测试。
[Redundantly,NotRedundantlyEdgeTables] = PebbleGame.Rigidity.IsRedundantlyRigidGraph('detail');
disp('冗余刚性测试完毕，谢谢你！');

%% 3连接测试
EdgeTable = PebbleGame.UserInPut.Graph.Edges;
NodeTable = PebbleGame.UserInPut.Graph.Nodes;
[kConnected,FailedGraph] = PebbleGame.Rigidity.kConnectedCheck(EdgeTable,NodeTable,3,PebbleGame.Operation.XData,PebbleGame.Operation.YData,'VeryDetailed');
disp('三连接测试完毕，谢谢你！');