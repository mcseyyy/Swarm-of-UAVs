classdef UAVsim < handle
    properties (SetAccess = public, GetAccess = public)
        id;
        p=0;
        curr_x_est;
        curr_y_est;
        prev_x_est;
        prev_y_est;
        state=0; % 0-Estimate_Angle 1-SEARCH 2-IN_CLOUD 3-OUT_CLOUD
        
        hull_x = [];
        hull_y = [];
        return_state;
        
        speed=20;
        
        
        
        ang_est=0;
        
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
        % error generator for UAV's GPS
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
        %constructor
        function uav = UAVsim(x,y,ang,id)
            if (nargin>2)
                uav.x = x;
                uav.y = y;
                uav.ang = ang;
                uav.id = id;
            end            
        end
        
        %functions for GPS data
        function x = get_x(uav)
            x = uav.x + uav.get_offset();
        end
        function y = get_y(uav)
            y = uav.y + uav.get_offset();
        end
        
        %this gets the real (x,y) coordinates for plotting
        function x = get_real_x(uav) %for plotting
            x=uav.x;
        end
        function y = get_real_y(uav) %gor plotting
            y=uav.y;
        end
    
        % This function calls the FSM and controls the dynamics of the UAV
        % It returns the message from the UAV
        function [x,y,p,id,new_uav] = step(uav,dt,t,cloud,messages)
            uav.t_alive = uav.t_alive+dt;
            p = cloudsamp(cloud,uav.x,uav.y,t);
            
            [total_ang_change, new_uav]= uav_fsm(uav,p,dt,messages); 
            
            ang_speed = total_ang_change/uav.speed;
            [uav.x,uav.y,uav.ang] = update_location(uav.x, uav.y, uav.ang, uav.speed, ang_speed,dt);
            uav.ang = mod(uav.ang+2*pi,2*pi);
            uav.p = p;
            x = uav.curr_x_est;
            y = uav.curr_y_est;
            id = uav.id;
            if uav.t_alive < 5
                %if the uav has been recently launched, do not send any
                %messages; the way I am handling messages requires all UAVs
                %to send a message so I filled it with garbage;
                x = 9999;
                y = 9999;
                p = 0;
            end
            
        end
    end
    
end

