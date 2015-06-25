function [fexcite]  = nonLinearFroudeKrylov(x,faces,points,cg,k,h,heading)
% Function to calculate buoyancy force and moment on a triangulated surface
% NOTE: This function assumes that the STL file is imported with its CG at 0,0,0

% Compute new tri coords after cog rotation and translation
points = offsetXYZ(points,cg);% offset so the geom can be rotated about the cog, which needs to be moved to 0,0,0

% Calculate new tri centers for hydrostatic pressure calc
[center,pointstemp] = triCenter(points,faces);

% Calculate tri area vectors, area, and normal vectors
[av] = triArea(pointstemp,faces);

% Calculate lever arm from COG
cogVect = [center(center(:,3)<0,1)-(x(1)+cg(1)),...
    center(center(:,3)<0,2)-(x(2)+cg(2)),...
    center(center(:,3)<0,3)-(x(3)+cg(3))];

% Calculate the hydrodynamic forces
[fexcite]=fHydrodynamic(center(center(:,3)<0,:),cogVect,av(center(:,3)<0,:),k,h,heading);
end

function verts = offsetXYZ(verts,x)
% Function to move the position vertices
verts(:,1) = verts(:,1) + x(1);
verts(:,2) = verts(:,2) + x(2);
verts(:,3) = verts(:,3) + x(3);
end

function [c,pointstemp] = triCenter(points,faces)
%Function to caculate the center coordinate of a triangle
% Inputs:
%     points: list of 3D points
%     faces: indicies that define the triangles
% Outputs:
%     c: centers of the triangles
c = zeros(length(faces),3);
pointstemp = points;
for ii = 1:length(faces)
    signmat = [sign(points(faces(ii,1),3)),sign(points(faces(ii,2),3)),sign(points(faces(ii,3),3))];
    if sum(signmat) ~= -3 && sum(signmat) ~= 3
        %%
        if sum(signmat) == -1 && sum(signmat==0) == 0
            indpos = find(signmat==1,1);
            indneg = find(signmat==-1,2);
            pointstemp1x = (points(faces(ii,indpos(1,1)),1)-points(faces(ii,indneg(1,1)),1))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),1);
            pointstemp1y = (points(faces(ii,indpos(1,1)),2)-points(faces(ii,indneg(1,1)),2))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),2);
            pointstemp2x = (points(faces(ii,indpos(1,1)),1)-points(faces(ii,indneg(1,2)),1))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,2)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),1);
            pointstemp2y = (points(faces(ii,indpos(1,1)),2)-points(faces(ii,indneg(1,2)),2))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,2)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),2);
            pointstemp(faces(ii,indpos(1,1)),1) = (pointstemp1x + pointstemp2x)/2;
            pointstemp(faces(ii,indpos(1,1)),2) = (pointstemp1y + pointstemp2y)/2;
            pointstemp(faces(ii,indpos(1,1)),3) = 0;
        elseif sum(signmat) == 1 && sum(signmat==0) == 0
            indpos = find(signmat==1,2);
            indneg = find(signmat==-1,1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pointstemp(faces(ii,indpos(1,1)),1) = (points(faces(ii,indpos(1,1)),1)-points(faces(ii,indneg(1,1)),1))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),1);
            pointstemp(faces(ii,indpos(1,1)),2) = (points(faces(ii,indpos(1,1)),2)-points(faces(ii,indneg(1,1)),2))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),2);
            pointstemp(faces(ii,indpos(1,1)),3) = 0;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pointstemp(faces(ii,indpos(1,2)),1) = (points(faces(ii,indpos(1,2)),1)-points(faces(ii,indneg(1,1)),1))/(points(faces(ii,indpos(1,2)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,2)),3))...
                +points(faces(ii,indpos(1,2)),1);
            pointstemp(faces(ii,indpos(1,2)),2) = (points(faces(ii,indpos(1,2)),2)-points(faces(ii,indneg(1,1)),2))/(points(faces(ii,indpos(1,2)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,2)),3))...
                +points(faces(ii,indpos(1,2)),2);
            pointstemp(faces(ii,indpos(1,2)),3) = 0;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif sum(signmat) == 0 && sum(signmat==0) == 1
            indpos = find(signmat==1,1);
            indneg = find(signmat==-1,1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pointstemp(faces(ii,indpos(1,1)),1) = (points(faces(ii,indpos(1,1)),1)-points(faces(ii,indneg(1,1)),1))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),1);
            pointstemp(faces(ii,indpos(1,1)),2) = (points(faces(ii,indpos(1,1)),2)-points(faces(ii,indneg(1,1)),2))/(points(faces(ii,indpos(1,1)),3)-points(faces(ii,indneg(1,1)),3))*(-points(faces(ii,indpos(1,1)),3))...
                +points(faces(ii,indpos(1,1)),2);
            pointstemp(faces(ii,indpos(1,1)),3) = 0;
        else
            %No action place holder
        end
    end
end
c(:,1) = (pointstemp(faces(:,1),1)+pointstemp(faces(:,2),1)+pointstemp(faces(:,3),1))/3;
c(:,2) = (pointstemp(faces(:,1),2)+pointstemp(faces(:,2),2)+pointstemp(faces(:,3),2))/3;
c(:,3) = (pointstemp(faces(:,1),3)+pointstemp(faces(:,2),3)+pointstemp(faces(:,3),3))/3;
end

function [av] = triArea(points,faces)
% Function to calculate the area of a triangle
% Inputs:
%   p : points of the triangles
%   t : indicies of the points that make up triangles
% Outputs:
%   a: area of the triangles
%   nv: normal vector of the triangele
v1 = points(faces(:,2),:)-points(faces(:,1),:);
v2 = points(faces(:,3),:)-points(faces(:,1),:);
av =  1/2.*(cross(v1,v2));
end

function [fexcite] = fHydrodynamic(center,cogVect,av,k,h,heading)
% Function to calculate the force and moment about the cog due to
% hydrostatic pressure
fexcite = zeros(6,1);

% Calculate the hydrodynamic pressure at each triangle center
if isinf(cosh(k*h))
    pressureVectexcite = [exp(k*(center(:,3))).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi))),...
        exp(k*(center(:,3))).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi))),...
        exp(k*(center(:,3))).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi)))];
else
    pressureVectexcite = [cosh(k*(center(:,3)+h))./cosh(k*h).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi))),...
        cosh(k*(center(:,3)+h))./cosh(k*h).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi))),...
        cosh(k*(center(:,3)+h))./cosh(k*h).*exp(-1i*k*(center(:,1)*cos(heading/180*pi) + center(:,2)*sin(heading/180*pi)))];
end

% Compute force about cog
fexcite(1:3) = sum(pressureVectexcite.*-av);

% Compute moment about cog
fexcite(4:6) =  sum(cross(cogVect,pressureVectexcite.*-av));
end