function [Pnm_e1,Pnm_e2,Pnm_e3,watermark,dq] = CoreEmbed_3Channel( ...
    Pnm_1,Pnm_2,Pnm_3,Maxorder,Messlength,num_n,QS)

% num_s不需要了
Pnm_e1 = Pnm_1; P00_1 = Pnm_1(1,Maxorder+1);
Pnm_e2 = Pnm_2; P00_2 = Pnm_2(1,Maxorder+1);
Pnm_e3 = Pnm_3; P00_3 = Pnm_3(1,Maxorder+1);

% seed = randi([1,10000]);
seed = 12;
rng(seed);
watermark=randi([0,1],1,Messlength);

% 抖动量预定义
d_0 = 0;
d_1 = d_0 + QS/2;

% 筛选备选嵌入矩并展平
count = 0;
for order = 0:Maxorder
    for repetition = 0:Maxorder
        if order + repetition == 0
            continue
        end
        if order + repetition <= Maxorder
            count = count + 1;
            flat_Pnm(:,count) = [order;repetition;
                Pnm_1(order+1,repetition+Maxorder+1);
                Pnm_2(order+1,repetition+Maxorder+1);
                Pnm_3(order+1,repetition+Maxorder+1)];
        end
    end
end

% 投影向量
for i = 1:Messlength
    proj_tem = abs(flat_Pnm(3:5,i));
    u(:,i) = proj_tem/norm(proj_tem);
end

% 矩幅度及标准化
for i = 1:Messlength
    %这个地方还有点疑点，三个通道上的需要做三次分别的标准化还是统一的标准化
    %目前能想到，假如做随机的话，肯定是各自的标准化更合适一些？（感觉）
    x(1,i) = (abs(flat_Pnm(3,i))/P00_1)*num_n;
    x(2,i) = (abs(flat_Pnm(4,i))/P00_2)*num_n;
    x(3,i) = (abs(flat_Pnm(5,i))/P00_3)*num_n;
end
% x = (abs(flat_Pnm(3:5,i))./P00)*num_n;

% Q(xTu,delta)
% x和u都是列向量了不用转了
for i = 1:Messlength
    xTu = x(:,i)' * u(:,i);
    if uint8(watermark(i)) == 1
        Dlt = d_1;
    elseif uint8(watermark(i)) == 0
        Dlt = d_0;
    else
        disp("only binary sequence permitted")
    end
    Q = round((xTu+Dlt)/QS)*QS-Dlt;
    dq(1,i) =  Q-xTu;%这里不是整数公式还得改改
    y(:,i) = x(:,i)+(Q-xTu)*u(:,i);
end

% 嵌入后的幅度恢复成矩
flat_Pnm_e = flat_Pnm;
for i = 1:Messlength
    flat_Pnm_e(3,i) = (y(1,i)*P00_1/num_n)/abs(flat_Pnm(3,i))*flat_Pnm(3,i);
    flat_Pnm_e(4,i) = (y(2,i)*P00_2/num_n)/abs(flat_Pnm(4,i))*flat_Pnm(4,i);
    flat_Pnm_e(5,i) = (y(3,i)*P00_3/num_n)/abs(flat_Pnm(5,i))*flat_Pnm(5,i);
end

% 嵌入后的展平矩再恢复成矩阵的结构
count = 0;
flag_break = 0;
for order = 0:Maxorder
    for repetition = 0:Maxorder
        if order + repetition == 0
            continue
        end
        if order + repetition <= Maxorder
            count = count + 1;
            if all(flat_Pnm_e(1:2,count) == [order;repetition])&&(count<=Messlength)
                Pnm_e1(order+1,repetition+Maxorder+1) = flat_Pnm_e(3,count);
                Pnm_e2(order+1,repetition+Maxorder+1) = flat_Pnm_e(4,count);
                Pnm_e3(order+1,repetition+Maxorder+1) = flat_Pnm_e(5,count);
            end
            if count > Messlength
                flag_break = 1;
            end
        end
        if flag_break == 1
            break
        end
    end
    if flag_break == 1
        break
    end
end

for order = 0:Maxorder
    for repetition = 1:Maxorder
        Pnm_e1(order+1,Maxorder+1-repetition) = conj(Pnm_e1(order+1,Maxorder+1+repetition));
        Pnm_e2(order+1,Maxorder+1-repetition) = conj(Pnm_e2(order+1,Maxorder+1+repetition));
        Pnm_e3(order+1,Maxorder+1-repetition) = conj(Pnm_e3(order+1,Maxorder+1+repetition));
    end
end
end % Function End