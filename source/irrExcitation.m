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

function bodyTemp = irrExcitation(bodyTemp,waves,simu)
bodyTemp.hydroForce.fExt.re=zeros(waves.numFreq,6);
bodyTemp.hydroForce.fExt.im=zeros(waves.numFreq,6);
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
    for jj = 1:waves.numFreq
        for ii=1:6
            bodyTemp.hydroForce.fExt.re(jj,ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                reshape(bodyTemp.hydro.data.fExt.Re(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w(jj));
            bodyTemp.hydroForce.fExt.im(jj,ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                reshape(bodyTemp.hydro.data.fExt.Im(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w(jj));
            if simu.nonlinFK == 1
                bodyTemp.hydroForce.fExtSC.re(jj,ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                    reshape(bodyTemp.hydro.data.fExtSC.Re(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w(jj));
                bodyTemp.hydroForce.fExtSC.im(jj,ii) = interp2(bodyTemp.hydro.data.waveheading,bodyTemp.hydro.data.period,...
                    reshape(bodyTemp.hydro.data.fExtSC.Im(ii,:,:),length(bodyTemp.hydro.data.period),length(bodyTemp.hydro.data.waveheading)),incidentwave,2*pi/waves.w(jj));
            else
                bodyTemp.hydroForce.fExtSC.re(jj,ii) = 0;
                bodyTemp.hydroForce.fExtSC.im(jj,ii) = 0;
            end
        end
        waves.k(jj,1) = fzero(@(x) (waves.w(jj))^(2)/simu.g - x*tanh(x*waves.waterDepth),waves.w(jj)^2/simu.g);
    end
else
    if bodyTemp.hydro.data.waveheading == 0
        bodyTemp.hydro.data.waveheading = [0,180];
    else
        bodyTemp.hydro.data.waveheading = [0,bodyTemp.hydro.data.waveheading];
    end
    for jj = 1:waves.numFreq
        for ii=1:6
            bodyTemp.hydroForce.fExt.re(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Re(ii,:),waves.w(jj),'spline');
            bodyTemp.hydroForce.fExt.im(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExt.Im(ii,:),waves.w(jj),'spline');
            if simu.nonlinFK == 1
                bodyTemp.hydroForce.fExtSC.re(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExtSC.Re(ii,:),waves.w(jj),'spline');
                bodyTemp.hydroForce.fExtSC.im(jj,ii) = interp1(bodyTemp.hydro.data.frequency,bodyTemp.hydro.data.fExtSC.Im(ii,:),waves.w(jj),'spline');
            else
                bodyTemp.hydroForce.fExtSC.re(jj,ii) = 0;
                bodyTemp.hydroForce.fExtSC.im(jj,ii) = 0;
            end
        end
        waves.k(jj,1) = fzero(@(x) (waves.w(jj))^(2)/simu.g - x*tanh(x*waves.waterDepth),waves.w(jj)^2/simu.g);
    end
    bodyTemp.hydro.data.fExt.Re(:,:,2) = bodyTemp.hydro.data.fExt.Re(:,:,1);
    bodyTemp.hydro.data.fExt.Im(:,:,2) = bodyTemp.hydro.data.fExt.Im(:,:,1);
    bodyTemp.hydro.data.fExtSC.Re(:,:,2) = bodyTemp.hydro.data.fExtSC.Re(:,:,1);
    bodyTemp.hydro.data.fExtSC.Im(:,:,2) = bodyTemp.hydro.data.fExtSC.Im(:,:,1);
end
%%
bodyTemp.hydroForce.ekf=zeros(length(waves.waveAmpTime(:,1)),12);    % Initialize matrix to allow Simulink to run, will be deleted
end