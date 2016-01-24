function sim_start
%
% simulation example for use of cloud dispersion model
%
% Arthur Richards, Nov 2014
%

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



uav = UAVsim(0,0,0);

% main simulation loop
for kk=1:3600
    t = t + dt;
    
    
    
    
    uav.step(dt,t,cloud);
    
    
    
    %plot stuff
    cla
    title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav.get_real_x,uav.get_real_y,uav.p))
    plot(uav.get_real_x(),uav.get_real_y(),'o')
    cloudplot(cloud,t)
    
    
end