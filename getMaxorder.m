function [Maxorder,capacity] = getMaxorder(Messlength)
Maxorder = 1;
capacity = -1; % exclude00
while(Messlength > capacity)
    capacity = 0;
    for i = 0:Maxorder
        for j = 0:Maxorder
            if i + j <= Maxorder
                capacity = capacity + 1;
            end
        end
    end
    Maxorder = Maxorder + 1;
end
end



