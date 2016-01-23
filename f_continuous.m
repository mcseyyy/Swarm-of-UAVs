function xdot = f_continuous(x,u)
    xdot = [u(1)*sin(x(3));u(1)*cos(x(3));u(1)*u(2)];
end