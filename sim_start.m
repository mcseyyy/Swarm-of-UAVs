function sim_start
    % load cloud data
    % choose a scenario
    % load 'cloud1.mat'
    close all;
    load 'cloud1.mat'

    % time and time step
    t = 0;
    dt = 1;

    % open new figure window
    figure
    hold on % so each plot doesn't wipte the predecessor

    id_count = 1;
    num_uavs = 1;
    uav(num_uavs,1) = UAVsim; %x,y,ang,t,id
    ang_dist = 2*pi/num_uavs;
    for i=1:num_uavs
        ang = ang_dist/2+ang_dist*(i-1);
        ang = normrnd(ang,ang_dist/2);
        uav(i) = UAVsim(0,0,ang,0,i);
    end;
        
    
    
    old_msg = zeros(num_uavs,5);
    spawn_new_uav = false;
    % main simulation loop
    for kk=1:3600
        new_msg = zeros(num_uavs,5);
        
        t = t + dt;
        i=1;
        spawn_new_uav = false;
        fprintf('num_uavs %d\n',num_uavs);
        while i<=num_uavs
            
            [x,y,p,id,new_uav] = uav(floor(i)).step(dt,t,cloud,old_msg);
            new_msg(i,1:5) = [x,y,p,id,new_uav];
            if (new_uav)
                spawn_new_uav = true;
            end
            if uav(i).state == 5 
                %if uav returned to the base, remove it
                
                if i<num_uavs && i>1
                    uav = [uav(1:i-1);uav(i+1:end)];
                elseif i<1
                    uav = uav(2:end);
                else
                    uav = uav(1:end-1);
                end
                    
                i=i-1;
                num_uavs = num_uavs-1;
            end
            i=i+1;
        end
        
        
        %plot the UAVs and the cloud
        if num_uavs<1
            return;
        end
        cla
        title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav(1).get_real_x,uav(1).get_real_y,uav(1).p))
        %plot(uav.get_real_x(),uav.get_real_y(),'o')
        for i=1:num_uavs
            if (uav(i).speed == 10)
                plot(uav(i).get_real_x(),uav(i).get_real_y(),'x')
            elseif (uav(i).speed ==20)
                plot(uav(i).get_real_x(),uav(i).get_real_y(),'+')
            else
                plot(uav(i).get_real_x(),uav(i).get_real_y(),'o')
            %plot_circle(uav(i).get_real_x(),uav(i).get_real_y(),30);
            end
        end
        cloudplot(cloud,t);
        old_msg = new_msg;
        if spawn_new_uav
            
            num_uavs = num_uavs+1;
            id_count = id_count+1;
            ang = rand;
            uav = [uav;UAVsim(0,0,ang,0,id_count)];
        end
    end
end


function plot_circle(x,y,r)
    ang = 0:0.01:2*pi;
    xp = r*cos(ang);
    yp = r*sin(ang);
    plot(x+xp,y+yp);
end