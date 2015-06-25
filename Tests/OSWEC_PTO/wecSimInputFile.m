% Simulation Data
simu.startTime=0;
simu.endTime=400;
simu.dt = 0.1;
simu.simMechanicsFile = 'wecModel.slx';
simu.mode='normal';%'normal','accelerator','rapid-accelerator'
simu.explorer='on';

% Wave Information
waves.H = 2.5;
waves.T = 8;
waves.type = 'regularCIC';

% Body Data
body(1) = bodyClass('Flap');
body(1).hydroDataType = 'wamit';
body(1).hydroDataLocation = 'wamit/oswec.out';
body(1).mass = 127000;
body(1).cg = 'wamit';
body(1).momOfInertia = [1.85e6 1.85e6 1.85e6];
body(1).geometry = 'geometry/flap.stl';

body(2) = bodyClass('Base');
body(2).hydroDataType = 'wamit';
body(2).hydroDataLocation = 'wamit/oswec.out';
body(2).geometry = 'geometry/base.stl';
body(2).fixed = 1;

% Joint and Constraint Parameters
constraint(1).name='Constraint1';

pto(1)=ptoClass('pto1')
pto.c=120000;
pto.k=0;
pto(1).loc=[0 0 -8.9];
