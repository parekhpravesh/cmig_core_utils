function voluw = vol_unwarp_grad(vol, gradient_type, jacobian, varargin)
% Correct for image distortions due to gradient nonlinearity. 
%
% voluw = vol_unwarp_grad(vol, gradient_type, jacobian, [d], [unwarpflag], [interpm], [padding], [bclamp])
%
% Inputs:
%
%   gradient_type: 0:  Siemens Sonata
%                  1:  Siemens Allegra
%                  2:  GE BRM
%                  3:  GE CRM
%                  4:  Siemens Avanto
%                  5:  Siemens AXXess/Espree
%                  6:  Siemens Quantum/Symphony
%                  7:  GE Twin Speed Whole Body
%                  8:  GE Twin Speed Zoom
%                  9:  GE MR450 or MR750
%                  10: GE MR750W
%                  11: Siemens Skyra
%                  12: Siemens Connectome Skyra
%                  13: Siemens Prisma
%                  14: GE Signa Premier
%                  15: GE Signa UHP
%                  16: Siemens Verio/Biograph
%                  17: Siemens Vida
%                  18: Siemens Cima.X
%
%   jacobian:      0: don't use jacobian 
%                  1: apply jacobian 
%
%   d:             distance for estimate jacobian
%
%   unwarpflag:    0: unwarp 3D (default)
%                  1: unwarp through plan only
%                  2: unwarp inplane only
%
%   interpm :     0: Nearest Neighbor 1:Linear  2:cubic (default)
%                 3: Key's spline 4: Cubic spline. 5: Hamming_Sinc
%
%   padding :     half width of number of points used in the interpolation,
%                 only for Cubic spline and Hamming_Sinc. 
%                 For example, 3 means it would use
%                 6*6*6 points for interpolation.
%   bclamp : set negative value to zero default = true


voluw = vol;

d=1.;
if nargin >= 4
    d=varargin{1};
end

unwarpflag=0;
if nargin >= 5
    unwarpflag=varargin{2};
end

interpm = 2;
if nargin >= 6
  interpm = varargin{3};
end


padding=3;
if nargin >= 7
  padding = varargin{4};
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

bclamp=true;
if nargin >= 8
  bclamp = varargin{5};
end

[dlfn,dpfn,dhfn,voluw.GRAD_UNWARP] = mmil_grad_files(gradient_type);

dLvol = read_mgh(dlfn);
dPvol = read_mgh(dpfn);
dHvol = read_mgh(dhfn);

Mlph2vol = inv(vol.Mvxl2lph);
Mlph2vol_g = inv(dLvol.Mvxl2lph);

voluw.imgs = volunwarpgradMEX(size(vol.imgs), vol.imgs, vol.Mvxl2lph, Mlph2vol,...
			      size(dLvol.imgs), dLvol.imgs, dPvol.imgs, dHvol.imgs,...
                  Mlph2vol_g, jacobian, unwarpflag, vol.DirRow, ...
                  vol.DirCol, vol.DirDep, interpm, padding, d);

if (bclamp)
    ind=find(voluw.imgs<0);
    voluw.imgs(ind)=0;
end

[voluw.maxI voluw.minI]=maxmin(voluw.imgs);
