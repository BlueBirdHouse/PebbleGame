%��������1�����������໥���ӵ�ѹ���˵�"������������"��
%ÿһ�����������������3���Ƕ����ıߡ�
%ÿһ�����������������9�������ıߡ�
%PebbleGame.Operation.IndependentEdge(1);һ��Ҫ����12*3�Ρ�

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
disp('ִ����ϣ�лл�㣡');