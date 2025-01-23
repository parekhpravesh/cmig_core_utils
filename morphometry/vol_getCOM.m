function lphcom=vol_getCOM(vol, varargin)
%   Calculate center of mass in LPH coordinate
%
%       lphcom=vol_getCOM(vol, [vxlweighted], [vxlth])
%
%  Input:
%       vol: volume structure
%       vxlweighthed: (default=false)
%       vxlth: Voxel Val thresold (defualt=0.)
% output:
%       lphcom: 4X1 vector

vxlweighthed=false;
if nargin >= 2
       vxlweighthed = varargin{1};
end

vxlth = 0;
if nargin >= 3
  vxlth = varargin{2};
end

lphcom=volgetCOMMEX(size(vol.imgs), vol.imgs, vol.Mvxl2lph, vxlweighthed, vxlth);