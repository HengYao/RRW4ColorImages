function [Pnm_wr1, Pnm_wr2, Pnm_wr3, watermark_ex] = CoreExtract_3Channel( ...
    Pnm_1,Pnm_2,Pnm_3,Maxorder,Messlength,num_n,QS,dq)

% Pnm_ex=Pnm;
Pnm_wr1 = Pnm_1; P00_1 = Pnm_1(1,Maxorder+1);
Pnm_wr2 = Pnm_2; P00_2 = Pnm_2(1,Maxorder+1);
Pnm_wr3 = Pnm_3; P00_3 = Pnm_3(1,Maxorder+1);

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
    x(1,i) = (abs(flat_Pnm(3,i))/P00_1)*num_n;
    x(2,i) = (abs(flat_Pnm(4,i))/P00_2)*num_n;
    x(3,i) = (abs(flat_Pnm(5,i))/P00_3)*num_n;
end

% 容器准备
watermark_ex = zeros(1,Messlength);

% Q(xTu,delta)
for i = 1:Messlength
    xTu = x(:,i)' * u(:,i);
    Q_0 = round((xTu+d_0)/QS)*QS-d_0;
    Q_1 = round((xTu+d_1)/QS)*QS-d_1;
    if abs(Q_0-xTu)<=abs(Q_1-xTu)
        watermark_ex(i)=0;
    else
        watermark_ex(i)=1;
    end
    x_q = dq(i) * u(:,i);
    xr(:,i) = x(:,i) - x_q;
end

% 嵌入后的幅度恢复成矩
flat_Pnm_wr = flat_Pnm;
for i = 1:Messlength
    flat_Pnm_wr(3,i) = (xr(1,i)*P00_1/num_n)/abs(flat_Pnm(3,i))*flat_Pnm(3,i);
    flat_Pnm_wr(4,i) = (xr(2,i)*P00_2/num_n)/abs(flat_Pnm(4,i))*flat_Pnm(4,i);
    flat_Pnm_wr(5,i) = (xr(3,i)*P00_3/num_n)/abs(flat_Pnm(5,i))*flat_Pnm(5,i);
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
            if all(flat_Pnm_wr(1:2,count) == [order;repetition])&&(count<=Messlength)
                Pnm_wr1(order+1,repetition+Maxorder+1) = flat_Pnm_wr(3,count);
                Pnm_wr2(order+1,repetition+Maxorder+1) = flat_Pnm_wr(4,count);
                Pnm_wr3(order+1,repetition+Maxorder+1) = flat_Pnm_wr(5,count);
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
        Pnm_wr1(order+1,Maxorder+1-repetition) = conj(Pnm_wr1(order+1,Maxorder+1+repetition));
        Pnm_wr2(order+1,Maxorder+1-repetition) = conj(Pnm_wr2(order+1,Maxorder+1+repetition));
        Pnm_wr3(order+1,Maxorder+1-repetition) = conj(Pnm_wr3(order+1,Maxorder+1+repetition));
    end
end

end % Function End