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

function bodyTemp = regExcitation(bodyTemp,waves,simu)
bodyTemp.hydroForce.fExt.re=zeros(1,6);
bodyTemp.hydroForce.fExt.im=zeros(1,6);
%%
if length(bodyTemp.hydro.data.waveheading) > 1
    %%
    gamma = atan2((bodyTemp.initAngularDispAxis(2)*bodyTemp.initAngularDispAxis(1)*(1-cos(bodyTemp.initAngularDispAngle)) + bodyTemp.initAngularDispAxis(3)*sin(bodyTemp.initAngularDispAngle))/cos(bodyTemp.initAngularDispAngle),...
        (cos(bodyTemp.initAngularDispAngle) + bodyTemp.initAngularDispAxis(1)^(2)*(1-cos(bodyTemp.initAngularDispAngle)))/cos(bodyTemp.initAngularDispAngle));
    if gamma > waves.heading
        incidentwave = 360 - (gamma/pi*180 - waves.heading);
    else
        incidentwave = waves.heading-gamma/pi*180;
    end
    %%
    for ii=1:6
        bodyTemp.hydroForce.fExt.re(ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
            reshape(bodyTemp.hydro.data.fExt.Re(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w);
        bodyTemp.hydroForce.fExt.im(ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
            reshape(bodyTemp.hydro.data.fExt.Im(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w);
        if simu.nonlinFK == 1
            bodyTemp.hydroForce.fExtSC.re(ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                reshape(bodyTemp.hydro.data.fExtSC.Re(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w);
            bodyTemp.hydroForce.fExtSC.im(ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                reshape(bodyTemp.hydro.data.fExtSC.Im(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w);
        else
            bodyTemp.hydroForce.fExtSC.re(ii) = 0;
            bodyTemp.hydroForce.fExtSC.im(ii) = 0;
        end
    end
    waves.k = fzero(@(x) (waves.w)^(2)/simu.g - x*tanh(x*waves.waterDepth),waves.w^2/simu.g);
else
    if bodyTemp.hydro.data.waveheading == 0
        bodyTemp.hydro.data.waveheading = [0,180];
    else
        bodyTemp.hydro.data.waveheading = [0,bodyTemp.hydro.data.waveheading];
    end
    for ii =1:6
        bodyTemp.hydroForce.fExt.re(ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Re(ii,:),waves.w,'spline');
        bodyTemp.hydroForce.fExt.im(ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Im(ii,:),waves.w,'spline');
        if simu.nonlinFK == 1
            bodyTemp.hydroForce.fExtSC.re(ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExtSC.Re(ii,:),waves.w,'spline');
            bodyTemp.hydroForce.fExtSC.im(ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExtSC.Im(ii,:),waves.w,'spline');
        else
            bodyTemp.hydroForce.fExtSC.re(ii) = 0;
            bodyTemp.hydroForce.fExtSC.im(ii) = 0;
        end
    end
    bodyTemp.hydro.data.fExt.Re(:,:,2) = bodyTemp.hydro.data.fExt.Re(:,:,1);
    bodyTemp.hydro.data.fExt.Im(:,:,2) = bodyTemp.hydro.data.fExt.Im(:,:,1);
    bodyTemp.hydro.data.fExtSC.Re(:,:,2) = bodyTemp.hydro.data.fExtSC.Re(:,:,1);
    bodyTemp.hydro.data.fExtSC.Im(:,:,2) = bodyTemp.hydro.data.fExtSC.Im(:,:,1);
    waves.k = fzero(@(x) (waves.w)^(2)/simu.g - x*tanh(x*waves.waterDepth),waves.w^2/simu.g);
end
bodyTemp.hydroForce.ekf=zeros(length(waves.waveAmpTime(:,1)),12);    % Initialize matrix
end
