function [xx,yy,ang] = update_location(uav_x, uav_y, uav_ang, uav_speed, ang_change,dt)
    x = [uav_x;uav_y; uav_ang];
    u = [uav_speed; ang_change];
            
    k1 = f_continuous(x,u);
    k2 = f_continuous(x+k1*dt/2,u);
    k3 = f_continuous(x+k2*dt/2,u);
    k4 = f_continuous(x+k3*dt,u);
    xnew = x +(k1 + 2*k2 + 2*k3 + k4)*dt/6;
    xx = xnew(1);
    yy = xnew(2);
    ang = xnew(3);
end 
function xdot = f_continuous(x,u)
    xdot = [u(1)*sin(x(3));u(1)*cos(x(3));u(1)*u(2)];
end