% Simulation Data
simu.startTime=0;   %[s]
simu.endTime=400;   %[s]
simu.dt = 0.1;      %[s]
simu.simMechanicsFile = 'RM3_2Body_1DOF_1200PTO.slx';
simu.mode='normal';%'normal','accelerator','rapid-accelerator'
simu.explorer='on';

simu.convCalc = 0;
simu.ssReal = 'TD';
simu.hydrocoupling = 1;

% Wave Information
waves.H = 1.0;  %[m]
waves.T = 10;    %[s]
waves.type = 'regular';

% Body Data
body(1) = bodyClass('Float');
body(1).hydroDataType = 'wamit';
body(1).hydroDataLocation = './wamit/buoywamit.out';
body(1).mass = 'wamitDisplacement';
body(1).cg = 'wamit';
body(1).momOfInertia = [20907301 21306090.66 37085481.11];      %[kg-m^2]
body(1).geometry = 'geometry/float.stl';

body(2) = bodyClass('Spar_Plate');
body(2).hydroDataType = 'wamit';
body(2).hydroDataLocation = './wamit/buoywamit.out';
body(2).mass = 'wamitDisplacement';
body(2).cg = 'wamit';
body(2).momOfInertia = [94419614.57 94407091.24 28542224.82];   %[kg-m^2]
body(2).geometry = 'geometry/plate.stl';

% Joint and Constraint Parameters
pto(1) = ptoClass('Joint1');
pto(1).c = 1200000;     %[Ns/m]
constraint(1) = constraintClass('constraint1');


