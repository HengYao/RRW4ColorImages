function [Pnm] = PHFM_De(plate,rho,theta,Maxorder)
[N, M] = size(plate);
Pnm = zeros(Maxorder+1, Maxorder*2+1);
for order = 0:Maxorder
    for repetition = -Maxorder:Maxorder
        if order + abs(repetition) <= Maxorder
            if order == 0
                T = 1/sqrt(2);
            elseif mod(order, 2) == 1
                T = sin(rho.^2 * pi * (order+1));
            else
                T = cos(rho.^2 * pi * order);
            end
            H = T .* exp(-1j * repetition * theta);
            Product = double(plate) .* H;
            Pnm(order+1,repetition+Maxorder+1) = sum(Product(:)) * (8/(pi*N^2));
        end
    end
end
end


    


