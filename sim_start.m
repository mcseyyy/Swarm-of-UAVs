function sim_start
%
% simulation example for use of cloud dispersion model
%
% Arthur Richards, Nov 2014
%

% load cloud data
% choose a scenario
% load 'cloud1.mat'
load 'cloud2.mat'

% time and time step
t = 0;
dt = 1;

% open new figure window
figure
hold on % so each plot doesn't wipte the predecessor



uav = UAVsim();
% main simulation loop
for kk=1:1000
    t = t + dt;
    p = cloudsamp(cloud,uav.x,uav.y,t);
    uav.step(dt,p);
    
    %plot stuff
    title(sprintf('t=%.1f secs pos=(%.1f, %.1f)  Concentration=%.2f',t, uav.x,uav.y,p))
    plot(uav.x,uav.y,'o')
    cloudplot(cloud,t)
    pause(0.001)
    
end