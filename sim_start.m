function sim_start
    % load cloud data
    % choose a scenario
    % load 'cloud1.mat'
    close all;
    load 'cloud1.mat'

    % time and time step
    t = 0;
    dt = 1;
    last_launch = 1; %time when the last UAV was launched

    % open new figure window
    figure
    hold on % so each plot doesn't wipte the predecessor
    
    %create initial UAVs
    id_count = 1; %id for the next spawned UAV
    num_uavs = 1; %number of active UAVs
    uav(num_uavs,1) = UAVsim; 
    ang = rand*2*pi;
    uav(1) = UAVsim(0,0,ang,1);%x,y,ang,id
    
    
    old_msg = zeros(num_uavs,5); %keeps the messages that have to be processed for next iterration
    spawn_new_uav = false; %if this becomes true, launch a new uav
    
    for kk=1:3600
        new_msg = zeros(num_uavs,5); %create an empty matrix for the new messages
        t = t + dt;
        
        spawn_new_uav = false;
        i=1;
        while i<=num_uavs
            [x,y,p,id,new_uav] = uav(floor(i)).step(dt,t,cloud,old_msg);
            new_msg(i,1:5) = [x,y,p,id,new_uav]; %get the message from the current UAV
            if (new_uav)
                spawn_new_uav = true;
            end
            if uav(i).state == 5
                %if UAV ran out of battery
                uav(i)=[];%remove the current UAV
                i=i-1;
                num_uavs = num_uavs-1;
            end
            i=i+1;
        end
        if num_uavs<1
            %sanity check
            return;
        end
        
        %plot the UAVs and the cloud
        cla
        title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav(1).get_real_x,uav(1).get_real_y,uav(1).p))
        
        for i=1:num_uavs
            text(uav(i).get_real_x()-14, uav(i).get_real_y()-5,sprintf('%d',uav(i).id));
            if uav(i).t_alive>10
                %I assumed that during take off, the UAV does not need to
                %do collision avoidance (until it reaches the required
                %height) so I do not plot a circle around it for the first
                %10 seconds.
                % this is useful in the case the cloud spreads over the
                % base (0,0);
                plot_circle(uav(i).get_real_x(),uav(i).get_real_y(),25);
            end
        end
        cloudplot(cloud,t);
        old_msg = new_msg;
        if spawn_new_uav && (kk-last_launch>25)
            last_launch = kk+1;
            num_uavs = num_uavs+1;
            id_count = id_count+1;
            ang = rand*2*pi;
            uav = [uav;UAVsim(0,0,ang,id_count)];
        end
    end
end


function plot_circle(x,y,r)
    %plots a circle at (x,y) corrdinates with radius r;
    %quality of the plotted circle is not very good but it is decent enough;
    ang = 0:0.5:2*pi;
    xp = r*cos(ang);
    yp = r*sin(ang);
    plot(x+xp,y+yp);
end