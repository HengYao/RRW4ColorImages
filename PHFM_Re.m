function [fxy] = PHFM_Re(Pnm,plate,rho,theta,Maxorder)
[N, M] = size(plate);
fxy = zeros(N, M);
for order = 0:Maxorder
    for repetition = -Maxorder:1:Maxorder
        if order + abs(repetition) <= Maxorder
            if order == 0
                T = 1/sqrt(2);
            elseif mod(order, 2) == 1
                T = sin(rho.^2 * pi * (order+1));
            else
                T = cos(rho.^2 * pi * order);
            end
            H = T .* exp(1j * repetition * theta);
            Product = Pnm(order+1,repetition+Maxorder+1) .* H;
            fxy = fxy + Product;
        end
    end
end  
end