function draw_spiral( a,b )
    
    figure;
    title(sprintf('%d*pi + %d',a,b));
    t=linspace(0,a*pi,b);
    x=t.*cos(t);
    y=t.*sin(t);
    plot(x,y);
end

