%%%%Run this seperatly to obtain the cvs file of RMSE MAPE  MABE and r%%%%
hpara = [20 20;20 25;20 30;20 35; 20 40; 25 25; 30 25; 35 25; 40 25];
excel = [];
for i = 1:length(hpara)
    vec_para = hpara(i,:);
    [RMSE, MAPE, MABE,r] = xxy(vec_para(1),vec_para(2));
    excel = [excel ; [RMSE MAPE MABE r]];
end
excel
csvwrite('excel.csv',excel)