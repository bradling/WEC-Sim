function [a,b,c,d] = impreal(varargin)
varin = nargin;
[nr,nc] = size(varargin{1});
%%
y = varargin{1};
%%
h = hankel(y(2:nc));
%%
[rh,ch] = size(h);
%% Compute the SVD of the Hankel Matrix
[u,svh,v] = svd(h);
svh = diag(svh);
%%
nx = round(varargin{2});
%%
u1 = u(1:rh-1,1:nx);
v1 = v(1:ch-1,1:nx);
u2 = u(1+1:rh,1:nx);
%%
sqs = sqrt(svh(1:nx));
invss = ones(nx,1)./sqs;
%%
ubar = u1'*u2;
a = ubar.*(invss*sqs');
b = (sqs*ones(1,1)).*v1(1:1,:)';
c = u1(1:1,:).*(ones(1,1)*sqs');
d = varargin{1}(1);