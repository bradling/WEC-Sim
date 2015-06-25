function c = triCenter(points,faces)
%Function to caculate the center coordinate of a triangle
% Inputs:
%     verts: list of 3D points
%     faces: indicies that define the triangles
% Outputs:
%     cents: centers of the triangles
c(:,1) = mean(points(faces(:,1),1)+points(faces(:,2),1)+points(faces(:,3),1));
c(:,2) = mean(points(faces(:,1),2)+points(faces(:,2),2)+points(faces(:,3),2));
c(:,3) = mean(points(faces(:,1),3)+points(faces(:,2),3)+points(faces(:,3),3));
