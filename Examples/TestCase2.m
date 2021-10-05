%²âÊÔÓÃÀı2£¬ÍŞÍŞĞÎ×´µÄ²âÊÔÓÃÀı¡£

T1 = [1 2; 1 6; 1 7 ; 2 6 ; 2 7 ; 3 6 ; 4 6 ; 5 6 ; 6 7];
T = [T1];
EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);
for i = 1:1:(9)
    PebbleGame.Operation.IndependentEdge(1)
    drawnow();
end
PebbleGame.Operation.StartIdentifyRigidCluster();
PebbleGame.Operation.StartIdentifyRigidCluster();
while(PebbleGame.Operation.IdentifyARigidCluster() == false)
    PebbleGame.Operation.ShowRigidCluster();
    drawnow();
end
disp('Ö´ĞĞÍê±Ï£¬Ğ»Ğ»Äã£¡');