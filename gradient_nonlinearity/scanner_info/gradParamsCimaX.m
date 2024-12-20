function CimaXParams = gradParamsCimaX

% Spherical harmonic parameters for the Cima.X gradients

CimaXParams.R0 = 0.275;

% Allocate memory
CimaXParams.Alpha_x = zeros(30,30);
CimaXParams.Alpha_y = zeros(30,30);
CimaXParams.Alpha_z = zeros(30,30);
CimaXParams.Beta_x = zeros(30,30);
CimaXParams.Beta_y = zeros(30,30);
CimaXParams.Beta_z = zeros(30,30);

% X gradient
CimaXParams.Alpha_x(1+  3, 1 +1) = -0.07025648;
CimaXParams.Alpha_x(1+  3, 3 +1) =  0.01140823;
CimaXParams.Alpha_x(1+  5, 1 +1) = -0.14812807;
CimaXParams.Alpha_x(1+  5, 3 +1) = -0.05632462;
CimaXParams.Alpha_x(1+  5, 5 +1) = -0.00306187;
CimaXParams.Alpha_x(1+  7, 1 +1) =  0.04935786;
CimaXParams.Alpha_x(1+  7, 3 +1) =  0.01281179;
CimaXParams.Alpha_x(1+  7, 5 +1) =  0.00103534;
CimaXParams.Alpha_x(1+  7, 7 +1) =  0.00066301;
CimaXParams.Alpha_x(1+  9, 1 +1) = -0.00442005;
CimaXParams.Alpha_x(1+  9, 3 +1) =  0.01258057;
CimaXParams.Alpha_x(1+  9, 5 +1) = -0.00015061;
CimaXParams.Alpha_x(1+  9, 7 +1) = -0.00432969;
CimaXParams.Alpha_x(1+  9, 9 +1) = -0.00312940;
CimaXParams.Alpha_x(1+ 11, 1 +1) = -0.00232449;
CimaXParams.Alpha_x(1+ 11, 3 +1) = -0.01566540;
CimaXParams.Alpha_x(1+ 11, 5 +1) = -0.00224059;
CimaXParams.Alpha_x(1+ 11, 7 +1) =  0.00462652;
CimaXParams.Alpha_x(1+ 11, 9 +1) =  0.00183288;
CimaXParams.Alpha_x(1+ 11,11 +1) = -0.00017843;
CimaXParams.Alpha_x(1+ 13, 1 +1) =  0.00223425;
CimaXParams.Alpha_x(1+ 13, 3 +1) =  0.01074993;
CimaXParams.Alpha_x(1+ 13, 5 +1) =  0.00172102;
CimaXParams.Alpha_x(1+ 13, 7 +1) = -0.00238613;
CimaXParams.Alpha_x(1+ 13, 9 +1) = -0.00121901;
CimaXParams.Alpha_x(1+ 15, 1 +1) = -0.00121930;
CimaXParams.Alpha_x(1+ 15, 3 +1) = -0.00474720;
CimaXParams.Alpha_x(1+ 15, 5 +1) = -0.00031703;
CimaXParams.Alpha_x(1+ 15, 7 +1) =  0.00082350;
CimaXParams.Alpha_x(1+ 15, 9 +1) =  0.00049012;
CimaXParams.Alpha_x(1+ 15,11 +1) =  0.00049694;
CimaXParams.Alpha_x(1+ 15,13 +1) =  0.00028456;
CimaXParams.Alpha_x(1+ 15,15 +1) =  0.00047656;

% Y gradient
CimaXParams.Beta_y(1+  3, 1 +1) = -0.06262697;
CimaXParams.Beta_y(1+  3, 3 +1) = -0.00477239;
CimaXParams.Beta_y(1+  5, 1 +1) = -0.12744499;
CimaXParams.Beta_y(1+  5, 3 +1) =  0.04128885;
CimaXParams.Beta_y(1+  5, 5 +1) = -0.00825132;
CimaXParams.Beta_y(1+  7, 1 +1) =  0.03131393;
CimaXParams.Beta_y(1+  7, 3 +1) = -0.00731067;
CimaXParams.Beta_y(1+  7, 5 +1) =  0.00561453;
CimaXParams.Beta_y(1+  7, 7 +1) =  0.00026171;
CimaXParams.Beta_y(1+  9, 1 +1) =  0.00483218;
CimaXParams.Beta_y(1+  9, 3 +1) = -0.00793049;
CimaXParams.Beta_y(1+  9, 5 +1) = -0.00383150;
CimaXParams.Beta_y(1+  9, 7 +1) = -0.00189384;
CimaXParams.Beta_y(1+  9, 9 +1) =  0.00060760;
CimaXParams.Beta_y(1+ 11, 1 +1) = -0.00666523;
CimaXParams.Beta_y(1+ 11, 3 +1) =  0.00826605;
CimaXParams.Beta_y(1+ 11, 5 +1) =  0.00135991;
CimaXParams.Beta_y(1+ 11, 7 +1) = -0.00042176;
CimaXParams.Beta_y(1+ 11, 9 +1) = -0.00047048;
CimaXParams.Beta_y(1+ 11,11 +1) =  0.00013401;
CimaXParams.Beta_y(1+ 13, 1 +1) =  0.00426110;
CimaXParams.Beta_y(1+ 13, 3 +1) = -0.00494870;
CimaXParams.Beta_y(1+ 13, 5 +1) = -0.00083609;
CimaXParams.Beta_y(1+ 13, 7 +1) =  0.00071655;
CimaXParams.Beta_y(1+ 13, 9 +1) = -0.00017266;
CimaXParams.Beta_y(1+ 13,13 +1) = -0.00016587;
CimaXParams.Beta_y(1+ 15, 1 +1) = -0.00196383;
CimaXParams.Beta_y(1+ 15, 3 +1) =  0.00196264;
CimaXParams.Beta_y(1+ 15, 5 +1) =  0.00066180;
CimaXParams.Beta_y(1+ 15, 7 +1) = -0.00053231;
CimaXParams.Beta_y(1+ 15, 9 +1) =  0.00017042;
CimaXParams.Beta_y(1+ 15,13 +1) =  0.00025860;
CimaXParams.Beta_y(1+ 15,15 +1) = -0.00022697;

% Z gradient
CimaXParams.Alpha_z(1+  3, 0 +1) = -0.07580385;
CimaXParams.Alpha_z(1+  5, 0 +1) = -0.20127557;
CimaXParams.Alpha_z(1+  7, 0 +1) =  0.11012998;
CimaXParams.Alpha_z(1+  9, 0 +1) = -0.01643211;
CimaXParams.Alpha_z(1+ 11, 0 +1) = -0.01013336;
CimaXParams.Alpha_z(1+ 13, 0 +1) =  0.00830568;
CimaXParams.Alpha_z(1+ 15, 0 +1) = -0.00285834;
