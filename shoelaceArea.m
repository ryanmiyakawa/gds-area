function area = shoelaceArea(coords)

% Duplicate first coordinate
coords = [coords; coords(1,:)];


area = 0;
for k = 1:size(coords,1) - 1
    xn = coords(k,1);
    yn = coords(k,2);
    
    xnp1 = coords(k+1,1);
    ynp1 = coords(k+1,2);
    
    area = area + 1/2*(xn*ynp1 - yn*xnp1);
    
end

area = abs(area);



