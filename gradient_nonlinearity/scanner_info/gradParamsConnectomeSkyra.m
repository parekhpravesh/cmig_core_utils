function gradParamsConnectomeSkyra = gradParamsConnectomeSkyra

% Spherical harmonic parameters for the Connectome Skyra gradients

gradParamsConnectomeSkyra.R0 = 0.20;

% Allocate memory
gradParamsConnectomeSkyra.Alpha_x = zeros(30,30);
gradParamsConnectomeSkyra.Alpha_y = zeros(30,30);
gradParamsConnectomeSkyra.Alpha_z = zeros(30,30);
gradParamsConnectomeSkyra.Beta_x = zeros(30,30);
gradParamsConnectomeSkyra.Beta_y = zeros(30,30);
gradParamsConnectomeSkyra.Beta_z = zeros(30,30);

% X gradient
gradParamsConnectomeSkyra.Alpha_x(1+ 3, 1 +1) = -0.10260;
gradParamsConnectomeSkyra.Alpha_x(1+ 3, 3 +1) = -0.01515;
gradParamsConnectomeSkyra.Alpha_x(1+ 5, 1 +1) = -0.03340;
gradParamsConnectomeSkyra.Alpha_x(1+ 5, 3 +1) = -0.00424;
gradParamsConnectomeSkyra.Alpha_x(1+ 5, 5 +1) = -0.00329;
gradParamsConnectomeSkyra.Alpha_x(1+ 7, 1 +1) =  0.01022;
gradParamsConnectomeSkyra.Alpha_x(1+ 7, 3 +1) =  0.00572;
gradParamsConnectomeSkyra.Alpha_x(1+ 9, 1 +1) = -0.00164;
gradParamsConnectomeSkyra.Alpha_x(1+ 9, 3 +1) = -0.00190;

% Y gradient
gradParamsConnectomeSkyra.Beta_y(1+ 3, 1 +1) = -0.10098;
gradParamsConnectomeSkyra.Beta_y(1+ 3, 3 +1) =  0.00277;
gradParamsConnectomeSkyra.Beta_y(1+ 5, 1 +1) = -0.03317;
gradParamsConnectomeSkyra.Beta_y(1+ 5, 3 +1) =  0.00424;
gradParamsConnectomeSkyra.Beta_y(1+ 5, 5 +1) =  0.00095;
gradParamsConnectomeSkyra.Beta_y(1+ 7, 1 +1) =  0.01091;
gradParamsConnectomeSkyra.Beta_y(1+ 7, 3 +1) = -0.00416;
gradParamsConnectomeSkyra.Beta_y(1+ 9, 1 +1) = -0.00191;
gradParamsConnectomeSkyra.Beta_y(1+ 9, 3 +1) =  0.00130;

% Z gradient
gradParamsConnectomeSkyra.Alpha_z(1+ 3, 0 +1) = -0.10420;
gradParamsConnectomeSkyra.Alpha_z(1+ 5, 0 +1) = -0.04230;
gradParamsConnectomeSkyra.Alpha_z(1+ 7, 0 +1) =  0.02120;
gradParamsConnectomeSkyra.Alpha_z(1+ 9, 0 +1) = -0.00610;
