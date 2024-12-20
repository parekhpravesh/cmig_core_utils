function [val inbound]=vol_getvxlsval(lphpos, vol, varargin)
% Obatin Voxel valuse based on LPH coordinate
%       
%   [val inbound]=vol_getvxlsval(lphpos, vo1, [Mreg], [method],[padding])
%
% Input:
%   lphpos: N X 4 matrix LPH coordinate position in homogenoeus coordinates
%   vol:    Input Volume
%   Mlph:   Reslice matrix (LPH based)
%   method: 0: :NEAREST LINEAR 1:(default) 2:cubic 
%           3: Key's spline 4: Cubic spline. 5: Hamming_Sinc
%   padding : half width of number of points used in the interpolation,
%                  only for 4 and 5. For example, 3 means it would use
%                  6*6*6 points for interpolation.
%
% Outpur:
%   val: N X 1 vector voxel vals 
%   inbound: N X1 vector for inbound or not



Mreg=eye(4,4);
if nargin >= 3
       Mreg = varargin{1};
end
Mlph2vxl=inv(vol.Mvxl2lph)*Mreg;

interpm = 1;
if nargin >= 4
  interpm = varargin{2};
end

padding=3;
if nargin >= 5
  padding = varargin{3};
end

if (interpm==0) % Nearest Neighbor padding=0
    padding=0;
elseif (interpm==1) % Lineae  padding=1
    padding=1;
elseif (interpm==2) % cubic and key's padding =2
    padding=2;
elseif (interpm==3)
    padding=2;
end

[val inbound]=volgetvxlsvalMEX(lphpos, size(vol.imgs), vol.imgs, Mlph2vxl,  interpm, padding);
