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


    
    uav = UAVsim(0,0,0,0,0); %x,y,ang,t,id
    

    % main simulation loop
    for kk=1:3600
        t = t + dt;
        uav.step(dt,t,cloud);

        %plot the UAVs and the cloud
        cla
        title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav.get_real_x,uav.get_real_y,uav.p))
        %plot(uav.get_real_x(),uav.get_real_y(),'o')
        plot_circle(uav.get_real_x(),uav.get_real_y(),30);
        plot (uav.x_target,uav.y_target,'o');
        cloudplot(cloud,t)
    end
end


function plot_circle(x,y,r)
    ang = 0:0.01:2*pi;
    xp = r*cos(ang);
    yp = r*sin(ang);
    plot(x+xp,y+yp);
end