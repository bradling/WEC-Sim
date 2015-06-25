function [] = PlotStateSpaceEstimation(Inputmatfile,bind)
%Inputmatfile must be a string input
%bind is the body number
load(Inputmatfile)
%%
if simu.hydrocoupling == 1
    kk = simu.numWecBodies;
else
    kk = 1;
end
%% Added Mass
close all
for pp = bind
    qq = 1;
    for oo = 1:kk

        for ii = 3
            for jj = 3+(6*(oo-1)):6:6*oo
                figure()
                plot(body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fAddedMass(ii,jj,:),1,length(body(pp).hydro.data.period))/1000,...
                    body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fAddedMassest(ii,jj,:),1,length(body(pp).hydro.data.period))/1000,'+')
                    %body(pp).hydro.data.frequency,body(pp).hydro.data.fAddedMassInf(ii,jj,:)*ones(size(body(pp).hydro.data.frequency))/1000,'--')
                grid on;
                if kk == 1
                    ylabel(['Added Mass, \mu_{',num2str(ii+(6*(pp-1))),num2str(jj+(6*(pp-1))),'}, [t]'])
                else
                    ylabel(['Added Mass, \mu_{',num2str(ii+(6*(pp-1))),num2str(jj),'}, [t]'])
                end
                xlabel('Angular Frequency [rad/s]');xlim([0 7])
                if ii == 6 && jj == 6*oo
                    legend('\mu (\sigma)',['\mu_{est} (\sigma) ',simu.ssReal],'\mu (\infty)')
                end
                qq = qq+1;
            end
        end
%         [ax4,h3]=suplabel(body(pp).name  ,'t');
%         %[ax2,h2]=suplabel('Added Mass','y');
%         set(h3,'FontSize',20);%set(h2,'FontSize',20);
    end
end
%% Wave Damping
for pp = bind
    qq = 1;
    for oo = 1:kk

        for ii = 3
            for jj = 3+(6*(oo-1)):6:6*oo
                figure()
                plot(body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fDamping(ii,jj,:),1,length(body(pp).hydro.data.period))/1000,...
                    body(pp).hydro.data.frequency,reshape(body(pp).hydro.data.fDampingest(ii,jj,:),1,length(body(pp).hydro.data.period))/1000,'+')
                grid on;
                if kk == 1
                    ylabel(['Wave Damping, \lambda_{',num2str(ii+(6*(pp-1))),num2str(jj+(6*(pp-1))),'}, [kN/(m/s)]'])
                else
                    ylabel(['Wave Damping, \lambda_{',num2str(ii+(6*(pp-1))),num2str(jj),'}, [kN/(m/s)]'])
                end
                xlabel('Angular Frequency [rad/s]');xlim([0 7])
                if ii == 6 && jj == 6*oo
                    legend('\lambda (\sigma)',['\lambda_{est} (\sigma) ',simu.ssReal])
                end
                qq = qq+1;
            end
        end
%         [ax4,h3]=suplabel(body(pp).name  ,'t');
%         %[ax2,h2]=suplabel('Added Mass','y');
%         set(h3,'FontSize',20);%set(h2,'FontSize',20);
    end
end