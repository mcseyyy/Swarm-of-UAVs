classdef UAVsim < handle
    properties (SetAccess = public, GetAccess = public)
        ang_thresh;
        dist_thresh;
        speed=20;
        state=1; %1-SEARCH 2-IN_CLOUD 3-OUT_CLOUD
        p=0;
        curr_x_est;
        curr_y_est;
        prev_x_est;
        prev_y_est;
        ang_est=-1;
        t_start;
        spiral_change = pi/15; %the total change in angle per timestep
        ang_estimate = 0;
    end
    properties (GetAccess = private)
        x=0;
        y=0;
        ang=0;
    end
    
    methods (Static)
        function offset = get_offset()
            offset = randn*3;
            if offset>3
                offset  = 3;
            elseif offset<-3
                offset = -3;
            end
        end
    end
    
    methods
        function uav = UAVsim(x,y,t)
            if (nargin>2)
                uav.x = x;
                uav.y = y;
                uav.t_start = t;                    
            end            
        end
        
        function x = get_x(uav)
            x = uav.x + uav.get_offset();
        end
        function y = get_y(uav)
            y = uav.y + uav.get_offset();
        end
        
        function x = get_real_x(uav) %for plotting
            x=uav.x;
        end
        function y = get_real_y(uav) %gor plotting
            y=uav.y;
        end
        
        
    
        function step(uav,dt,t,cloud)
            p = cloudsamp(cloud,uav.x,uav.y,t);
            ang_change = uav_fsm(uav,p); 
            
            ang_change = ang_change/uav.speed;
            
            x = [uav.x;uav.y; uav.ang];
            u = [uav.speed; ang_change];
            
            k1 = f_continuous(x,u);
            k2 = f_continuous(x+k1*dt/2,u);
            k3 = f_continuous(x+k2*dt/2,u);
            k4 = f_continuous(x+k3*dt,u);
            xnew = x +(k1 + 2*k2 + 2*k3 + k4)*dt/6;
            uav.x = xnew(1);
            uav.y = xnew(2);
            uav.ang = xnew(3);
            uav.p = p;
        end
    end
    
end

