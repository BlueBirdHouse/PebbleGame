%��������4��������Բ���������

T = [1 4 ; 1 3 ; 1 2 ; 2 3 ; 3 4; 2 5 ; 2 6; 5 6 ; 4 6];
EdgeTable = table(T,'VariableNames',{'EndNodes'});
PebbleGame = PebbleGamePlayStage(EdgeTable);
[Redundantly,NotRedundantlyEdgeTables] = PebbleGame.Rigidity.IsRedundantlyRigidGraph('detail');
disp('ִ����ϣ�лл�㣡');