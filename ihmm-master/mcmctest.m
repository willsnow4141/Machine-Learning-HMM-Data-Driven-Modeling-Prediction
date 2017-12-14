%%%%params%%%%
states = 20;
symbols = 25;
test_a_sample = 81;
temper_file = 'temp_LA_SUS.csv';
radia_file = 'radiation.csv';
every_day_analysis =true;
%%%%params%%%%



if every_day_analysis
    fprintf 'DAY ANALYSIS!\n'
else
    fprintf 'HOUR ANALYSIS!\n'
end

    
    
temper_24 = csvread(temper_file,1,1);
radia_96 = csvread(radia_file,1,1);

a = size(temper_24);
days = a(1);

test_raw = temper_24(test_a_sample,:);



% radia_24
radia_24=[];
for i=1:24
    a = radia_96(:,4*i-4+1:4*i);
    radia_24 = [radia_24 mean(a, 2)];
end


if every_day_analysis == true
    radia_24 = mean(radia_24,2);
    temper_24 = mean(temper_24,2);
    test_raw = temper_24(test_a_sample:test_a_sample+9);
end
    
% plot(

% size(radia_24)

max_temper = max(max(temper_24));
min_temper = min(min(temper_24));

max_radia = max(max(radia_24));
min_radia = min(min(radia_24));

temper_region_len = (max_temper - min_temper) / symbols;
radia_region_len = (max_radia - min_radia) / states;

temp = [];
for i = 1:symbols
    temp = [temp min_temper + i * temper_region_len];
end
temper_regions = temp;

temp = [];
for i = 1:states
    temp = [temp min_radia + i * radia_region_len];
end
radia_regions = temp;


temper_vec = reshape(temper_24,1,[]);
radia_vec = reshape(radia_24,1,[]);

temper_int_vec = [];
for i = 1:length(temper_vec)
    for j = 1:symbols
        if temper_vec(i) < temper_regions(j)
            break
        end
    end
    temper_int_vec = [temper_int_vec j];
end

test_int_vec = [];
for i = 1:length(test_raw)
    for j = 1:symbols
        if test_raw(i) < temper_regions(j)
            break
        end
    end
    test_int_vec = [test_int_vec j];
end
% test_int_vec = reshape(test_int_vec,length(test_int_vec)/2,2)


radia_int_vec = [];
for i = 1:length(radia_vec)
    for j = 1:states
        if radia_vec(i) < radia_regions(j)
            break
        end
    end
    radia_int_vec = [radia_int_vec j];
    
end

% length(radia_int_vec)
% length(temper_int_vec)

temper_float_vec = temper_int_vec.*temper_region_len-temper_region_len/2+min_temper;
radia_float_vec = radia_int_vec.*radia_region_len-radia_region_len/2+min_radia;

fprintf('Temperature range: %f °C - %f °C. \n',min_temper, max_temper);
fprintf('Radiation range: %f W/m2 - %f W/m2. \n ',min_radia, max_radia);

index = 1:length(temper_float_vec);

figure(1)
plot(index,temper_float_vec)
title('温度变化曲线')
if every_day_analysis
    xlabel('Day index')
else
    xlabel('Hour index')
end
ylabel('Temperature (°C)')

figure(2)
plot(index,radia_float_vec)
title('辐射强度变化曲线')
if every_day_analysis
    xlabel('Day index')
else
    xlabel('Hour index')
end
ylabel('Radiation (W/m2)')

fprintf('按任意键继续...\n')
pause;

fprintf('参数估计中...\n')


%%###########
num_init_symbol=25;

hypers.alpha0_a = 4;
hypers.alpha0_b = 2;
hypers.gamma_a = 3;
hypers.gamma_b = 6;
hypers.H = ones(1,num_init_symbol) * 0.3;
tic

[S ,stats] = iHmmSampleGibbs(temper_int_vec, hypers, 300, 1, 1, ceil(rand(1,T) * 20));
toc

[tr_mat, emit_mat] = hmmestimate(temper_int_vec, S{1}.S);
%#############
%返回的隐状态序列
S{1}.S
fprintf('隐状态转移矩阵:')
tr_mat
fprintf('观测值转移矩阵:')
emit_mat


% Plot some stats
figure(1)
subplot(3,2,1)
plot(stats.K)
title('K')
subplot(3,2,2)
plot(stats.jll)
title('Joint Log Likelihood')
subplot(3,2,3)
plot(stats.alpha0)
title('alpha0')
subplot(3,2,4)
plot(stats.gamma)
title('gamma')
subplot(3,2,5)
imagesc(SampleTransitionMatrix(S{1}.S, zeros(1,S{1}.K))); colormap('Gray');
title('Transition Matrix')
subplot(3,2,6)
imagesc(SampleEmissionMatrix(S{1}.S, Y, S{1}.K, hypers.H)); colormap('Gray');
title('Emission Matrix')



    
    
    
    
    
    
    
    
    
    
    
    
    
    



