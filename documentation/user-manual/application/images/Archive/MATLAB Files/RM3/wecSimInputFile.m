% Simulation Data
simu.startTime=0;                           % Simulation Start Time [s]
simu.endTime=400;                           % Simulation End Time [s]
simu.dt = 0.1;                              % Simulation Delta_Time [s]
simu.simMechanicsFile = ...                 % Specify Simulink Model File     
    'RM3_2Body_1DOF_1200PTO.slx';   
simu.mode='normal';                         % Specify Simulation Mode 
                                                % (normal/accelerator
                                                % /rapid-accelerator)
simu.explorer='on';                         % Turn SimMechanics Explorer 
                                                % (on/off)

% Wave Information
waves.H = 2.5;                              % Wave Height [m]
waves.T = 8;                                % Wave Period [s]
waves.type = 'regular';                     % Specify Type of Waves 

% Body Data
body(1) = bodyClass('Float');               % Initialize bodyClass for Float
body(1).hydroDataType = 'wamit';            % Specify BEM solver
body(1).hydroDataLocation = ...             % Location of WAMIT *.out file
    './wamit/buoywamit.out';
body(1).mass = 'wamitDisplacement';         % Mass from WAMIT [kg]
body(1).cg = 'wamit';                       % Cg from WAMIT [m]
body(1).momOfInertia = ...                  % Moment of Inertia [kg-m^2]
    [20907301 21306090.66 37085481.11];      
body(1).geometry = 'geometry/float.stl';    % Geometry File

body(2) = bodyClass('Spar_Plate');          % Initialize bodyClass for 
                                                % Spar/Plate
body(2).hydroDataType = 'wamit';            % Specify BEM solver
body(2).hydroDataLocation = ...             % Location of WAMIT *.out file
    './wamit/buoywamit.out'; 
body(2).mass = 'wamitDisplacement';         % Mass from WAMIT [kg]
body(2).cg = 'wamit';                       % Cg from WAMIT [m]
body(2).momOfInertia = ...
    [94419614.57 94407091.24 28542224.82];  % Moment of Inertia [kg-m^2]
body(2).geometry = 'geometry/plate.stl';    % Geometry File

% PTO and Constraint Parameters
constraint(1) = ...                         % Initialize Constraint Class 
    constraintClass('Constraint1');             % for Constraint1

pto(1) = ptoClass('PTO1');                  % Initialize ptoClass for PTO1
pto(1).k=0;                                 % PTO Stiffness Coeff [N/m]
pto(1).c=1200000;                           % PTO Damping Coeff [Ns/m]