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
function [waveAmpTime,Sf,frequency] = wavesUserDefined(waves,simu)
% Define Function Inputs
frequency = ones(simu.numFreq,1);                      % [rad/s]  - must set to 1 so Simulink Blocks can initialize properly
Sf = zeros(simu.numFreq,1);                             % [m^2/Hz] - must set to 0 so Simulink Blocks can initialize properly
waves.phaseRand = zeros(simu.numFreq,1).';              % [-]      - must set to 0 so Simulink Blocks can initialize properly
%User Defined Wave Train
data = dlmread(waves.spectrumDataFile);                 % Import wave elevation time series: first column time and second column wave elevation
%timein = data(:,1);                                    
%waveAmpTimein = data(:,2);                             
simu.rampT = simu.dt;                                   % The defined wave elevation is likely to have its own inherent ramp function, therefore we artifically set it to one time step
timeout = [0:simu.dt:max(data(:,1))-min(data(:,1))].';  % Create a fixed time step vector from the min and max values of the input time series
%timeout = [0:simu.dt:max(timein)-min(timein)].';       
waveAmpTimeout = interp1(data(:,1),data(:,2),timeout);  % Interpolate the wave elevation based on the fixed step time series
%waveAmpTimeout = interp1(timein,waveAmpTimein,timeout);
waveAmpTime = [timeout,waveAmpTimeout];                 % Construct the time and signal vector required by the "From Workspace" Simulink Block

