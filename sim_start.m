function sim_start
    % load cloud data
    % choose a scenario
    % load 'cloud1.mat'
    close all;
    load 'cloud2.mat'

    % time and time step
    t = 0;
    dt = 1;

    % open new figure window
    figure
    hold on % so each plot doesn't wipte the predecessor


    num_uavs = 4;
    uav(num_uavs,1) = UAVsim; %x,y,ang,t,id
    ang_dist = 2*pi/num_uavs;
    for i=1:num_uavs
        ang = ang_dist/2+ang_dist*(i-1);
        ang = normrnd(ang,ang_dist/2);
        uav(i) = UAVsim(0,0,ang,0,i);
    end;
        
    
    new_msg = zeros(num_uavs,3);
    old_msg = zeros(num_uavs,3);
    % main simulation loop
    for kk=1:3600
        t = t + dt;
        for i=1:num_uavs
            [x,y,p] = uav(i).step(dt,t,cloud,old_msg);
            new_msg(i,1:3) = [x,y,p];
            fprintf('--%d %d\n',uav(i).id,uav(i).state);
        end
        fprintf('============\n');

        %plot the UAVs and the cloud
        cla
        title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav.get_real_x,uav.get_real_y,uav.p))
        %plot(uav.get_real_x(),uav.get_real_y(),'o')
        for i=1:num_uavs
            plot_circle(uav(i).get_real_x(),uav(i).get_real_y(),30);
        end
        cloudplot(cloud,t);
        old_msg = new_msg;
        new_msg = [];
    end
end


function plot_circle(x,y,r)
    ang = 0:0.01:2*pi;
    xp = r*cos(ang);
    yp = r*sin(ang);
    plot(x+xp,y+yp);
end