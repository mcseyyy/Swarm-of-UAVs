function ang_change = uav_fsm(uav,p,dt,messages)
    ang_change = 0;
    uav.curr_x_est = uav.get_x();
    uav.curr_y_est = uav.get_y();
    switch uav.state
        case -1,
             if pdist([uav.x_target,uav.y_target; uav.curr_x_est ,uav.curr_y_est],'euclidean')<100
                uav.state = uav.return_state;
             end
             
             target_ang = atan2(uav.x_target - uav.curr_x_est,  uav.y_target - uav.curr_y_est);
             ang_change = target_ang-uav.ang_est;
        case 0,
            
            if uav.round_no==3
                uav.ang_est = atan2(uav.curr_x_est, uav.curr_y_est);
                uav.state = 2;
            else
                uav.round_no = uav.round_no+1;
            end
        case 1,
            for i=1:size(messages,1)
                if messages(i,3)>0.4
                    uav.state = -1;
                    uav.x_target = messages(i,1);
                    uav.y_target = messages(i,2);
                    uav.return_state = 3;
                    break;
                end
            end
            
                    
            if uav.state ==-1
                target_ang = atan2(uav.x_target - uav.curr_x_est,  uav.y_target - uav.curr_y_est);
                ang_change = target_ang-uav.ang_est;
            elseif (abs(uav.curr_x_est)>900 || abs(uav.curr_y_est) > 900)
                %if a boundary is reachedbefore finding the cloud,
                %go back to (0,0) and start searching again
                uav.state = -1;
                uav.return_state = 1;
                uav.spiral_change = pi/20;
                uav.x_target = 0;
                uav.y_target = 0;
            elseif p<0.4 %still looking for a cloud
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
            uav.speed = 10;
            if p<0.4
                uav.state = 1;
            elseif p<uav.p && p>0.9
                ang_change = pi/3;
                uav.state = 4;
            end
        case 4,
            num_uavs = size(messages,1);
            uav.speed = 15;
            if (p>0.8)
                uav.hull_x = [uav.hull_x,uav.curr_x_est];
                uav.hull_y = [uav.hull_y,uav.curr_y_est];
                if size(uav.hull_x)>50
                    hull_indexes = convhull(uav.hull_x, uav.hull_y);
                    uav.hull_x = uav.hull_x(hull_indexes);
                    uav.hull_y = uav.hull_y(hull_indexes);
                end
            end
            size(uav.hull_x)
            if size(uav.hull_x,2)>20
                x_c = mean(uav.hull_x);
                y_c = mean(uav.hull_y);
                ang_c = zeros(num_uavs);
                %calculate the angle between the center of the cloud and
                %all the UAVs; angles should be between [0,2pi] and not
                %between [-pi,pi]
                
                for i=1:num_uavs
                    ang_c(messages(i,4)) = atan2(messages(i,1)-x_c, messages(i,2)-y_c);
                end
                fprintf('TAA DAA\n');
                own_ang = ang_c(uav.id);
                ang_c = sort(ang_c);
                idx = find(ang_c==own_ang);
                
                if (idx==1) prev_ang_diff = mod(own_ang-ang_c(num_uavs)+2*pi,2*pi);
                else prev_ang_diff = mod(own_ang-ang_c(idx-1)+2*pi,2*pi);
                end
                
                if (idx==num_uavs) next_ang_diff= mod(ang_c(1)-own_ang+2*pi,2*pi);
                else next_ang_diff = mod(ang_c(idx+1)-own_ang+2*pi,2*pi);
                end
                
                if prev_ang_diff<next_ang_diff
                    uav.speed = 20;
                elseif prev_ang_diff > next_ang_diff
                    uav.speed = 10;
                end 
            end
                
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
    bound = 950;
    if est_y <- bound
        ang_change = 3*pi/2+pi/20-uav.ang_est;
    elseif est_y > bound
        ang_change = pi/2+pi/20-uav.ang_est;
    elseif est_x < -bound
        ang_change = pi/20-uav.ang_est;
    elseif est_x > bound
        ang_change = pi+pi/20 - uav.ang_est;
    end
    ang_change = ang_threshold(ang_change, uav.speed,dt);
    
    
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
