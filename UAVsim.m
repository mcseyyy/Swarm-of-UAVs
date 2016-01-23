classdef UAVsim < handle
    properties (SetAccess = public, GetAccess = public)
        ang_thresh;
        dist_thresh;
        speed=20;
        state=1; %1-SEARCH 2-IN_CLOUD 3-OUT_CLOUD
        clockwise = 1;
        p=0;
        t_start;
        x_start;
        y_start;
        x=0;
        y=0;
        ang = 0;
        spiral_change = pi/15; %the total change in angle per timestep
    end
    
    properties (Constant)
        SEARCH = 1;
        IN = 2;
        OUT = 3;
    end
    
    methods
        function uav = UAVsim(x_start,y_start,t_start)
            if (nargin==2)
                uav.x_start = x_start;
                uav.x = x_start;
                uav.y_start = y_start;
                uav.y = y_start;
                uav.t_start = t_start;
                
            else
                uav.x = 0;
                uav.y = 0;
                uav.t_start = 0;
                
            end
            
        end
        
        function x = get.x(uav)
            x = uav.x + uav.get_offset();
        end
        
        function y = get.y(uav)
            y = uav.y + uav.get_offset();
        end
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
        
        function step(uav,dt,t,cloud)
            %1-SEARCH;      go in spirals
            %2-SEARCH_LR;
            %3-FOLOW edge (hopefully)
            %4-
            p = cloudsamp(cloud,uav.x,uav.y,t);
            ang_change = 0;
            left_right = 0;
            
            switch uav.state
                case 1,
                    if p<0.4 %still looking for a cloud
                        ang_change = uav.spiral_change;
                        uav.spiral_change = uav.spiral_change*0.99;
                    else %got to a cloud;
                        uav.state = 2;
                        uav.speed = 10;
                        uav.spiral_change = pi/20;
                    end
                case 2,
                    if p<0.4
                        uav.state = 1;
                        uav.speed = 20;
                    elseif p>uav.p && p>1
                        uav.state = 3;
                    end
                case 3,
                    if p<0.4
                        uav.state = 1;
                    elseif p<uav.p && p>0.9
                        ang_change = pi/3;
                        uav.state = 4;
                    end
                case 4,
                    if p<0.9 && p<uav.p
                        ang_change = pi/10;
                    elseif p>1.1 && p>uav.p
                        ang_change = -pi/10;
                    end
                       
            end 
            
            ang_change = ang_change/uav.speed;
            
            x = [uav.x;uav.y; uav.ang];
            u = [uav.speed; ang_change];
            
            k1 = f_continuous(x,u);
            k2 = f_continuous(x+k1*dt/2,u);
            k3 = f_continuous(x+k2*dt/2,u);
            k4 = f_continuous(x+k3*dt,u);
            xnew = x+(k1 + 2*k2 + 2*k3 + k4)*dt/6;
            uav.x = xnew(1);
            uav.y = xnew(2);
            uav.ang = xnew(3);
       

            uav.p = p;
            fprintf('state=%d speed=%d ang=%f clockwise=%d\n',uav.state,uav.speed,uav.ang, uav.clockwise);
        end
    end
    
end

