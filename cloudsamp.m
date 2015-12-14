function p=cloudsamp(cloud,x,y,t)
%
%  p=cloudsamp(cloud,x,y,t)
%
% simulate concentration sample from pollutant cloud
%
% "cloud" should have elements p,x,y,t from dispersal simulation
% Sample relates to time t at position x,y
%

% simple interpolation in 3D
p = interp3(cloud.x,cloud.y,cloud.t,cloud.p,...
            x,y,t);
        
% warning if time too late
if t>max(cloud.t),
    warning('cloudsamp: time out of range.  Extrapolations could be weird.')
end