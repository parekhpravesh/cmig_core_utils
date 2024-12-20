function M = xtoM(xhat)

%xhat([4:6]) = pi/180*xhat([4:6]);

pitch = eye(4,4);
pitch(2,2) = cos(xhat(4));
pitch(2,3) = -sin(xhat(4));
pitch(3,2) = sin(xhat(4));
pitch(3,3) = cos(xhat(4));

roll = eye(4,4);
roll(1,1) = cos(xhat(5));
roll(1,3) = sin(xhat(5));
roll(3,1) = -sin(xhat(5));
roll(3,3) = cos(xhat(5));

yaw = eye(4,4);
yaw(1,1) = cos(xhat(6));
yaw(1,2) = -sin(xhat(6));
yaw(2,1) = sin(xhat(6));
yaw(2,2) = cos(xhat(6));

trans = eye(4,4);
trans(1,4) = xhat(1);
trans(2,4) = xhat(2);
trans(3,4) = xhat(3);

M = trans*yaw*roll*pitch;

return;

