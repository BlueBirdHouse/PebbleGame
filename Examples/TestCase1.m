%测试用例1，具有三个相互连接的压扁了的"共底正四面体"。
%每一个共底正四面体具有3条非独立的边。
%每一个共底正四面体具有9条独立的边。
%PebbleGame.Operation.IndependentEdge(1);一共要运行12*3次。

T1 = [1 2; 1 4; 1 6; 2 3; 2 4; 2 5; 2 6; 3 4; 3 6; 4 5; 4 6; 5 6];
T2 = [3 7; 3 9; 3 11; 7 8; 7 9; 7 10; 7 11; 8 9; 8 11; 9 10; 9 11; 10 11];
T3 = [5 12; 5 14; 5 16; 12 13; 12 14; 12 15; 12 16; 13 14; 13 16; 14 15; 14 16; 15 16];
T = [T1;T2;T3];
EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);
for i = 1:1:(12*3)
    PebbleGame.Operation.IndependentEdge(1)
    drawnow();
end
PebbleGame.Operation.StartIdentifyRigidCluster();
while(PebbleGame.Operation.IdentifyARigidCluster() == false)
    PebbleGame.Operation.ShowRigidCluster();
    drawnow();
end
disp('执行完毕，谢谢你！');