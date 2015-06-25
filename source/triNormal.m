function nv = triNormal(points,faces)
% function to calculate the normal vector of a triangle
% Inputs:
%    points: triangle verticies
%    faces: connectivity
% Outputs:
%    nV = normal vector;
v1 = points(faces(:,1),:)-points(faces(:,2),:);
v2 = points(faces(:,1),:)-points(faces(:,3),:);
nv = (cross(v1,v2));
nv = nv/norm(nv);
