% Simulation Data
simu.startTime=0;
simu.endTime=400;
simu.dt = 0.1;
simu.simMechanicsFile = 'RM3_2Body_3DOF_0PTO.slx';
simu.mode='normal';%'normal','accelerator','rapid-accelerator'
simu.explorer='on';
simu.hydroDataWamit=1;

% Wave Information
waves.H = 2.5;
waves.T = 8;
waves.type = 'regular';

% Body Data
body(1) = bodyClass('Float');
body(1).hydroDataType = 'wamit';
body(1).hydroDataLocation = './wamit/buoywamit.out';
body(1).mass = 'wamitDisplacement';
body(1).cg = 'wamit';
body(1).momOfInertia = [20907301 21306090.66 37085481.11];
body(1).geometry = 'geometry/float.stl';

body(2) = bodyClass('Spar_Plate');
body(2).hydroDataType = 'wamit';
body(2).hydroDataLocation = './wamit/platewamit.out';
body(2).mass = 'wamitDisplacement';
body(2).cg = 'wamit';
body(2).momOfInertia = [94419614.57 94407091.24 28542224.82];
body(2).geometry = 'geometry/plate.stl';

% Joint and Constraint Parameters
pto(1) = ptoClass('pto1');
constraint(1) = constraintClass('constraint1');

