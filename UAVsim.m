classdef UAVsim < handle
    
    properties (SetAccess = public, GetAccess = public)
        x; %x coordinate
        y; %y coordinate
        ang; %angle (with regards to Ox)
        ang_thresh;
        dist_thresh;
        speed;
        state=1; %1-SEARCH 2-IN_CLOUD 3-OUT_CLOUD
        d_ang = pi/20;
        p = 0;
        clockwise = -1;
        
    end
    
    properties (Constant)
        SEARCH = 1;
        IN = 2;
        OUT = 3;
    end
    
    methods
        function uav = UAVsim()
            uav.x = 0;
            uav.y = 0;
            uav.ang = -pi/30;
            uav.speed = 20;
            uav.ang_thresh = pi/30;
            uav.dist_thresh = 1000;
            
        end
        
        function change_angle(uav, ang_diff)
            if ang_diff>uav.ang_thresh || ang_diff < -uav.ang_thresh
                return;
            end
            uav.ang = uav.ang + ang_diff;                
        end
        
        function step(uav,dt,p)
            %1-SEARCH;      go in spirals
            %2-SEARCH_LR;
            %3-FOLOW edge (hopefully)
            %4-
            ang_change = 0;
            if (uav.state==1)
                if p>0.3
                    uav.d_ang = pi/20;
                end
                if p<0.41 %still looking for a cloud
                    fprintf('here\n');
                    ang_change = uav.d_ang;
                    uav.d_ang = uav.d_ang*0.99;    
                else %got to a cloud;
                    fprintf('there\n');
                    uav.state = 2; %search_lr
                    uav.d_ang = pi/5;
                    ang_change = pi/5;
                end
            elseif (uav.state == 2)
                if (uav.p>p)
                    uav.clockwise = -1;
                else
                    uav.clockwise = 1;
                end
                uav.state = 3;
            elseif (uav.state == 3)
                if p<0.3
                    uav.state=1;
                    uav.d_ang = pi/20;
                elseif p<uav.p && p>0.3
                    %uav.ang = uav.ang+pi/4*uav.clockwise;
                    ang_change = pi/4*uav.clockwise
                else
                    %uav.ang = uav.ang-pi/4*uav.clockwise;
                    ang_change = -pi/4*uav.clockwise;
                end
            end
             
            ang_change = ang_change/uav.speed;
            x = [uav.x;uav.y; uav.ang];
            u = [uav.speed; ang_change];
            
            k1 = f(x,u);
            k2 = f(x+k1*dt/2,u);
            k3 = f(x+k2*dt/2,u);
            k4 = f(x+k3*dt,u);
            xnew = x+(k1 + 2*k2 + 2*k3 + k4)*dt/6;
            uav.x = xnew(1);
            uav.y = xnew(2);
            uav.ang = xnew(3);
       
            
            
            %uav.x = uav.x + uav.speed * sin(uav.ang) * dt;
            %uav.y = uav.y + uav.speed * cos(uav.ang) * dt;
            uav.p = p;
            fprintf('state=%d speed=%d ang=%f\n',uav.state,uav.speed,uav.ang);
        end
        
        
    end
    
end

