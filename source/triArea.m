function [a,nv,av] = triArea(points,faces)
% Function to calculate the area of a triangle
% Inputs:
%   p : points of the triangles
%   t : indicies of the points that make up triangles
% Outputs:
%   a: area of the triangles
%   nv: normal vector of the triangele
v1 = points(faces(:,3),:)-points(faces(:,1),:);
v2 = points(faces(:,2),:)-points(faces(:,1),:);
av =  1/2.*(cross(v1,v2));
a = ( av(:,1).^2 + av(:,2).^2 + av(:,3).^2 ) .^ (1/2);
nv = av ./ [a a a];