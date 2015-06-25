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
function bodyTemp = ekfExcitation(bodyTemp,waves,simu)
WFQSt=min(bodyTemp.hydro.data.frequency);
WFQEd=max(bodyTemp.hydro.data.frequency);
df  = (WFQEd-WFQSt)/(simu.numFreq-1);
w = [WFQSt:df:WFQEd]; % Interpolate frequencies with a constant step
%% Calculate the initial incident wave heading based on wave heading and yaw of the rigid body
if length(bodyTemp.hydro.data.waveheading) > 1
    gamma = atan2((bodyTemp.initAngularDispAxis(2)*bodyTemp.initAngularDispAxis(1)*(1-cos(bodyTemp.initAngularDispAngle)) + bodyTemp.initAngularDispAxis(3)*sin(bodyTemp.initAngularDispAngle))/cos(bodyTemp.initAngularDispAngle),...
        (cos(bodyTemp.initAngularDispAngle) + bodyTemp.initAngularDispAxis(1)^(2)*(1-cos(bodyTemp.initAngularDispAngle)))/cos(bodyTemp.initAngularDispAngle));
    if gamma > waves.heading
        incidentwave = 360 - (gamma/pi*180 - waves.heading);
    else
        incidentwave = waves.heading-gamma/pi*180;
    end
    %%
    for ii=1:6 % Interpolate the frequency wave exciting force coefficients
        for jj = 1:length(w)
            bodyTemp.hydroForce.fExt.re(jj,ii) = ...
                interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,reshape(bodyTemp.hydro.data.fExt.Re(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),...
                incidentwave,2*pi/w(jj));
            bodyTemp.hydroForce.fExt.im(jj,ii) = ...
                interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,reshape(bodyTemp.hydro.data.fExt.Im(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),...
                incidentwave,2*pi/w(jj));
            waves.k(jj,1) = fzero(@(x) (w(jj))^(2)/simu.g - x*tanh(x*waves.waterDepth),w(jj)^2/simu.g);
        end
                bodyTemp.hydroForce.fExtSC.re(jj,ii) = 0;
                bodyTemp.hydroForce.fExtSC.im(jj,ii) = 0;
    end
else % Make modifications if number of headings from BEM solver is 1
    if bodyTemp.hydro.data.waveheading == 0
        bodyTemp.hydro.data.waveheading = [0,180];
    else
        bodyTemp.hydro.data.waveheading = [0,bodyTemp.hydro.data.waveheading];
    end
    for ii=1:6 % Interpolate the frequency wave exciting force coefficients
        for jj = 1:length(w)
            bodyTemp.hydroForce.fExt.re(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Re(ii,:),w(jj),'linear');
            bodyTemp.hydroForce.fExt.im(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Im(ii,:),w(jj),'linear');
            waves.k(jj,1) = fzero(@(x) (w(jj))^(2)/simu.g - x*tanh(x*waves.waterDepth),w(jj)^2/simu.g);% Calculate wave number
        end
            bodyTemp.hydroForce.fExtSC.re(jj,ii) = 0;
            bodyTemp.hydroForce.fExtSC.im(jj,ii) = 0;
    end
    bodyTemp.hydro.data.fExt.Re(ii,:,2) = bodyTemp.hydro.data.fExt.Re(ii,:,1);% Duplicating is required to satisfy the 2D interpolation blocks used in irregular and regular wave
    bodyTemp.hydro.data.fExt.Im(ii,:,2) = bodyTemp.hydro.data.fExt.Im(ii,:,1);% trials with multiple headings from WAMIT
    bodyTemp.hydro.data.fExt.Re(:,:,2) = bodyTemp.hydro.data.fExt.Re(:,:,1);
    bodyTemp.hydro.data.fExt.Im(:,:,2) = bodyTemp.hydro.data.fExt.Im(:,:,1);
    bodyTemp.hydro.data.fExtSC.Re(:,:,2) = bodyTemp.hydro.data.fExtSC.Re(:,:,1);
    bodyTemp.hydro.data.fExtSC.Im(:,:,2) = bodyTemp.hydro.data.fExtSC.Im(:,:,1);
end
%%
bodyTemp.hydroForce.ekf=zeros(length(waves.waveAmpTime(:,1)),12);    % Initialize matrix
ts = -max(waves.waveAmpTime(:,1))/2:simu.dt:max(waves.waveAmpTime(:,1))/2; % Construct symmetric time series about t = 0 that is the same size as waves.waveAmpTime(:,1)
for kt=1:length(ts) %Construct the excitation kernel function for each mode of motion
    for ii=1:6
        if abs(ts(kt)) < simu.CITime
            bodyTemp.hydroForce.ekf(kt,ii) = 1./pi*trapz(w,bodyTemp.hydroForce.fExt.re(:,ii).*cos(w(:)*ts(kt)) - bodyTemp.hydroForce.fExt.im(:,ii).*sin(w(:)*ts(kt)));
        else
            bodyTemp.hydroForce.ekf(kt,ii) = 0;
        end
    end;
end
%% Convolve the excitation force kernel with the imported wave elevation time series
for jj = 1:6
    bodyTemp.hydroForce.ekf(:,6+jj) = conv(waves.waveAmpTime(:,2),bodyTemp.hydroForce.ekf(:,jj),'same')*simu.dt;
end