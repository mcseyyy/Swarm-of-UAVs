function ang_change = uav_fsm(uav,p,dt)
    ang_change = 0;
    uav.curr_x_est = uav.get_x();
    uav.curr_y_est = uav.get_y();
    switch uav.state
        case -1,
            
            if pdist([uav.x_target,uav.curr_x_est; uav.y_target,uav.curr_y_est],'euclidean')<30
                fprintf('Reached Targer\n');
            end            
            uav.ang_est = uav.ang_est+pi/2;
            %uav.ang_est = mod(uav.ang_est+2*pi,2*pi);
            
            target_angle = atan2(uav.x_target - uav.curr_x_est,  uav.y_target - uav.curr_y_est);
            ang_change = -target_angle+uav.ang_est;
            
            fprintf('ang_est=%f  atarget_angle=%f ang_change=%f\n',uav.ang_est/pi*180, target_angle/pi*180, ang_change/pi*180);
            uav.ang_est = uav.ang_est-pi/2;
        case 0,
            if uav.round_no==3
                uav.ang_est = atan2(uav.curr_y_est, uav.curr_x_est)-pi/2;
                fprintf('state 0; ang_est=%f\n\n',uav.ang_est+pi/2);
                uav.state = 2;
            else
                uav.round_no = uav.round_no+1;
            end
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
                ang_change = pi/6;
            elseif p>1.2 && p>uav.p
                ang_change = -pi/10;
            end
    end
    ang_change = ang_threshold(ang_change, uav.speed,dt);
        
        
    %estimate the future location of the UAV
    [est_x,est_y,new_ang] = update_location(uav.curr_x_est, uav.curr_y_est, uav.ang_est, uav.speed, ang_change/uav.speed,dt);
    
    %if the future location is outside the map, 
    uav.ang_est = uav.ang_est+pi/2;
    if est_y <-980
        ang_change = pi-uav.ang_est;
    elseif est_y >980
        ang_change = -uav.ang_est;
    elseif est_x < -980
        ang_change = pi/2 - uav.ang_est;
    elseif est_x > 980
        ang_change = 3*pi/2 - uav.ang_est;
    end
    ang_change = ang_threshold(ang_change, uav.speed,dt);
    fprintf('ang_est=%f\n\n',uav.ang_est/pi*180);
    uav.ang_est = uav.ang_est-pi/2;
    uav.ang_est = mod(uav.ang_est+ang_change+2*pi,2*pi);
    
    uav.prev_x_est = uav.curr_x_est;
    uav.prev_y_est = uav.curr_y_est;
end

function ang_change = ang_threshold(ang_change,speed,dt)
    %make the smallest turn to achieve the required result
    if (ang_change > pi)
        ang_change = ang_change-2*pi;
    elseif (ang_change < -pi)
        ang_change = 2*pi + ang_change;
    end

    %do not turn more than the UAV can
    if ang_change>speed*dt*(pi/20)
        ang_change = speed*(pi/20);
    elseif ang_change < -speed*dt*(pi/20)
        ang_change = -speed*(pi/20);
    end
end
