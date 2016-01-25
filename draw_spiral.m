function draw_spiral( a,b )
    n=10;
    for i=1:n
        fprintf('%d\n',i);
        n=n-1;
    end
    
    figure;
    title(sprintf('%d*pi + %d',a,b));
    t=linspace(0,a*pi,b);
    x=t.*cos(t);
    y=t.*sin(t);
    plot(x,y);
end

