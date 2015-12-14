function cloudplot(cloud,t)
%
%    cloudplot(cloud,t)
%
%  Contour plot of cloud in current window
%

% store contour handles as persistent to delete them each time
persistent c h

try
    delete(h)
end

% need to permute 
pp = permute(cloud.p,[3 1 2]);

% now interpolate in time which is first dimension
pf = squeeze(interp1(cloud.t,pp,t));

% and draw contours
[c, h] = contour(cloud.x,cloud.y,pf,(0.5:0.5:3));
colorbar('EastOutside')
axis equal
axis([min(cloud.x) max(cloud.x) min(cloud.y) max(cloud.y)])
pause(0.01)