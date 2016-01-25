classdef UAVsim < handle
    properties (SetAccess = public, GetAccess = public)
        %ang_thresh;
        %dist_thresh;
        hull_x = [];
        hull_y = [];
        return_state;
        id;
        speed=20;
        state=0; % 0-Estimate_Angle 1-SEARCH 2-IN_CLOUD 3-OUT_CLOUD
        p=0;
        curr_x_est;
        curr_y_est;
        prev_x_est;
        prev_y_est;
        ang_est=0;
        t_start;
        t_alive = 0;
        round_no = 0;
        spiral_change = pi/15; %the total change in angle per timestep
        x_target;
        y_target;
        %ang_estimate = 0;
        
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
        function uav = UAVsim(x,y,ang,t,id)
            if (nargin>2)
                uav.x = x;
                uav.y = y;
                uav.ang = ang;
                uav.t_start = t;     
                uav.id = id;
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
    
        function [x,y,p,id,new_uav] = step(uav,dt,t,cloud,messages)
            
            uav.t_alive = uav.t_alive+dt;
            p = cloudsamp(cloud,uav.x,uav.y,t);
            
            [total_ang_change, new_uav]= uav_fsm(uav,p,dt,messages); 
            
            turn_speed = total_ang_change/uav.speed;
            [uav.x,uav.y,uav.ang] = update_location(uav.x, uav.y, uav.ang, uav.speed, turn_speed,dt);
            uav.ang = mod(uav.ang+2*pi,2*pi);
            uav.p = p;
            x = uav.curr_x_est;
            y = uav.curr_y_est;
            id = uav.id;
            
            fprintf('id=%d state=%d return_state=%d\n',uav.id, uav.state, uav.return_state);
        end
    end
    
end

