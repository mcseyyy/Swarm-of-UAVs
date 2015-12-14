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
            %2-IN_CLOUD;    keep going straight until you get too close to
            %               the middle
            %4-OUT_CLOUD;   spin in circles until you get back in
            if (uav.state==1 && p<0.4)
                uav.ang = uav.ang + uav.d_ang;
                uav.d_ang = uav.d_ang*0.99;    
            elseif (uav.state == 1 && p>=0.4) %got to a cloud;
                uav.state = 2;
            elseif (uav.state == 2 && p>0.8)  %too close to center
                uav.d_ang = -pi/3;
                uav.state = 1;
            elseif (uav.state == 2 && p<0.4)  %too far from center
                uav.state=1;
                uav.d_ang = -pi/3;
            end
            if uav.ang>2*pi
                uav.ang = uav.ang-2*pi;
            end
            uav.x = uav.x + uav.speed * sin(uav.ang) * dt;
            uav.y = uav.y + uav.speed * cos(uav.ang) * dt;
            fprintf('state=%d speed=%d ang=%f\n',uav.state,uav.speed,uav.ang);
        end
    end
    
end

