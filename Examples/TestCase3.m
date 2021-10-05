%测试用例2，手链形状的测试用例。

T1 = [1 2; 1 10; 2 3; 2 4; 2 10; 3 4; 4 5; 4 6; 5 6; 6 7; 6 8; 7 8 ; 8 9 ; 8 10; 9 10];
T = [T1];
EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);
for i = 1:1:(15)
    PebbleGame.Operation.IndependentEdge(1)
    drawnow();
end
PebbleGame.Operation.StartIdentifyRigidCluster();
while(PebbleGame.Operation.IdentifyARigidCluster() == false)
    PebbleGame.Operation.ShowRigidCluster();
    drawnow();
end
disp('执行完毕，谢谢你！');