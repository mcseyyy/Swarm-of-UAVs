function ang_change = uav_fsm(uav,p,dt)
    ang_change = 0;
    uav.curr_x_est = uav.get_x();
    uav.curr_y_est = uav.get_y();
    switch uav.state
        case 1,
            if p<0.4 %still looking for a cloud
                ang_change = uav.spiral_change;
                uav.spiral_change = uav.spiral_change*0.99;
            else %got to a cloud;
                uav.state = 2;
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
            if p<0.95 && p<uav.p
                ang_change = pi/10;
            elseif p>1.2 && p>uav.p
                ang_change = -pi/10;
            end
    end
    if ang_change == 0
        uav.ang_est = atan2(uav.curr_y_est - uav.prev_y_est, uav.curr_x_est-uav.prev_x_est);
    else
        % check if the movement would make the uav to get outside the map;
        % if this is the case, turn to the right as much as possible;
        
        %also, update the angle estimate
        [est_x,est_y,new_ang_est] = update_location(uav.curr_x_est, uav.curr_y_est, uav.ang_est, uav.speed, ang_change/uav.speed,dt);
        
        
        
    end;
    
    
    uav.prev_x_est = uav.curr_x_est;
    uav.prev_y_est = uav.curr_y_est;
end

