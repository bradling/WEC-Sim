%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2014 the National Renewable Energy Laboratory and Sandia Corporation
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [waveAmpTime,waveAmp,w] = wavesReg(waves, simu)

maxRampIT=round(simu.rampT/simu.dt);
w=2*pi/waves.T;
waveAmp=waves.H/2;

%%  Calulate wave history
waveAmpTime=zeros(simu.maxIt+1,2);
% No wave ramping defined
if simu.rampT==0
   for i=1:simu.maxIt+1
       t = (i-1)*simu.dt;
       waveAmpTime(i,2) = waveAmp*cos(w*t);
       waveAmpTime(i,1) = t;
   end
% If wave ramping defined
else
   for i=1:maxRampIT
       t = (i-1)*simu.dt;
       waveAmpTime(i,2) = waveAmp*cos(w*t)*(1+cos(pi+pi*(i-1)/maxRampIT))/2;
       waveAmpTime(i,1) = t;
   end
   for i=maxRampIT+1:simu.maxIt+1;
       t = (i-1)*simu.dt;
       waveAmpTime(i,2) = waveAmp*cos(w*t);
       waveAmpTime(i,1) = t;
   end       
end
