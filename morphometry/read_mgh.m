function vol = read_mgh(fn)
% Read in "mgh" format files (i.e. dump of Fischl MRI struct)
%
% E.g.: vol = read_mgh('vol1.mgh');

% (gnchen)

[mghhr, img]=mghread(fn);

%Columns
vol.dimc=mghhr.width;
%Rows
vol.dimr=mghhr.height;
%depth
vol.dimd=mghhr.depth;

%Voxel size in Row direction
vol.vx=mghhr.xsize;

%Voxel size in Column direction
vol.vy=mghhr.ysize;

%Voxel size in Slice direction
vol.vz=mghhr.zsize;

vol.slicegap=0;

Mvxl2lph=eye(4,4);

% Row direction vector
Mvxl2lph(:,2)=vol.vx*[-mghhr.x_r;-mghhr.x_a;mghhr.x_s;0];
vol.DirRow=[-mghhr.x_r;-mghhr.x_a;mghhr.x_s];
%Column Direction vector
Mvxl2lph(:,1)=vol.vy*[-mghhr.y_r;-mghhr.y_a;mghhr.y_s;0];
vol.DirCol=[-mghhr.y_r;-mghhr.y_a;mghhr.y_s];
%Slice direction vector
Mvxl2lph(:,3)=(vol.vz+vol.slicegap)*[-mghhr.z_r;-mghhr.z_a;mghhr.z_s;0];
vol.DirDep=[-mghhr.z_r;-mghhr.z_a;mghhr.z_s;];

%lphcent
vol.lphcent=[-mghhr.c_r;-mghhr.c_a;mghhr.c_s];

%For matlab Index sake: start from 1
T=Mvxl2lph*[-(vol.dimr+1)/2; -(vol.dimc+1)/2; -(vol.dimd+1)/2;1];
Mvxl2lph(:,4)=T+[vol.lphcent;0];
vol.Mvxl2lph=Mvxl2lph;
vol.imgs=img;


%Determin Sagittal/Coronol/Axial dir
%Slice Direction
adir=abs(vol.DirDep);
maxa=max(adir);
ind=find(adir==maxa);
if (ind==1)
    vol.SagDir=3;
 %   vol.lphcent(1)=pos(1)+vol.DirDep(ind)*vol.vz*(vol.dimd-1)/2;
elseif (ind==2)
    vol.CorDir=3;
  %  vol.lphcent(2)=pos(2)+vol.DirDep(ind)*vol.vz*(vol.dimd-1)/2;
else
    vol.AxlDir=3;
   % vol.lphcent(3)=pos(3)+vol.DirDep(ind)*vol.vz*(vol.dimd-1)/2;
end

%Becaureful about inplane half pixel shift
adir=abs(vol.DirRow);
maxa=max(adir);
ind=find(adir==maxa);
if (ind==1)
    vol.SagDir=2;
    %vol.lphcent(1)=pos(1)+vol.DirRow(ind)*vol.vx*(vol.dimc)/2;
elseif (ind==2)
    vol.CorDir=2;
    %vol.lphcent(2)=pos(2)+vol.DirRow(ind)*vol.vx*(vol.dimc)/2;
else
    vol.AxlDir=2;
    %vol.lphcent(3)=pos(3)+vol.DirRow(ind)*vol.vx*(vol.dimc)/2;
end

adir=abs(vol.DirCol);
maxa=max(adir);
ind=find(adir==maxa);
if (ind==1)
    vol.SagDir=1;
    %vol.lphcent(1)=pos(1)+vol.DirCol(ind)*vol.vy*(vol.dimr)/2;
elseif (ind==2)
    vol.CorDir=1;
    %vol.lphcent(2)=pos(2)+vol.DirCol(ind)*vol.vy*(vol.dimr)/2;
else
    vol.AxlDir=1;
    %vol.lphcent(3)=pos(3)+vol.DirCol(ind)*vol.vy*(vol.dimr)/2;
end

%=======
if ~isempty(strfind(fn, 'seg'))
  load tkmcolors
  vol.cmap = tkmcolors;
end

vol.maxI = mghhr.maxI;
vol.minI = mghhr.minI;

  
