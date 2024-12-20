function [vol, M] = load_dicom_fl2(flist,dcminfo)
% [vol, M, dcmvolinfo] = load_dicom_fl(flist)
%
% Loads a volume from the dicom files in flist.
%
% The volume dimensions are arranged such that the
% readout dimension is first, followed by the phase-encode,
% followed by the slices (this is not implemented yet)
%
% M is the 4x4 vox2ras transform such that
% vol(i1,i2,i3), xyz1 = M*[i1 i2 i3 1] where the
% indicies are 0-based. 
%
% dcmvolinfo is a structure that contains some usefull
% parameters (eg, TR, TE, flip angle, etc).
%
% Does not handle multiple frames correctly yet.
%
% $Id: load_dicom_fl.m,v 1.3 2002/12/21 00:58:33 greve Exp $

vol=[];
M=[];

dcmvolinfo = [];

if(nargin ~= 2)
  fprintf('[vol, M] = load_dicom_fl2(flist,dcminfo)\n');
  return;
end

nfiles = size(flist,1);

tic

if 0
fprintf('Loading info\n');
for n = 1:nfiles
  fname = deblank(flist(n,:));
%  fprintf('n = %d, %s   %g\n',n,fname,toc);
  tmpinfo = dicominfo(fname);
  tmpinfo = fix_impax_dcm_tags(tmpinfo);
  if(isempty(tmpinfo)) 
    fprintf('ERROR: reading %s\n',fname);
    return;
  end
  if(n > 1)
    % Check that the nth series number agrees with the first
    if(tmpinfo.SeriesNumber ~= dcminfo0(1).SeriesNumber)
      fprintf('ERROR: series number inconsistency (%s)\n',fname);
      return;
    end
  end
  tmpinfo.fname = fname;
  dcminfo0(n) = tmpinfo;
end

% Sort by slice location %
dcminfo = sort_by_sliceloc(dcminfo0);

end

% Slice direction cosine %
sdc = dcminfo(nfiles).ImagePositionPatient-dcminfo(1).ImagePositionPatient;
sdc = sdc /sqrt(sum(sdc.^2));

% Distance between slices %
%dslice = sqrt(sum(dcminfo(2).ImagePositionPatient-dcminfo(1).ImagePositionPatient).^2);
dslice = norm(dcminfo(2).ImagePositionPatient-dcminfo(1).ImagePositionPatient); % fixed AMD
% needs more fixing for dual-flip 3dflash (AAS)

% Matrix of direction cosines %
Mdc = zeros(3,3);
Mdc(:,1) = dcminfo(1).ImageOrientationPatient(1:3);
Mdc(:,2) = dcminfo(1).ImageOrientationPatient(4:6);
Mdc(:,3) = sdc;

% Voxel resolution %
delta = [dcminfo(1).PixelSpacing; dslice];
D = diag(delta);

% XYZ of first voxel in first slice %
P0 = dcminfo(1).ImagePositionPatient;

% Change Siemens to be RAS %
Manufacturer = dcminfo(1).Manufacturer;
if(strcmpi(Manufacturer,'Siemens'))
  % Lines below are for 
  % correcting for if P0 is at corner of 
  % the first voxel instead of at the center
  % Pcrs0 = [-0.5 -0.5 0]'; %'
  % P0 = P0 - Mdc*D*Pcrs0;

  % Change to RAS
  Mdc(1,:) = -Mdc(1,:); 
  Mdc(2,:) = -Mdc(2,:); 
  P0(1)    = -P0(1);
  P0(2)    = -P0(2);
end

% Compute vox2ras transform %
M = [Mdc*D P0; 0 0 0 1];

if(strcmpi(Manufacturer,'Siemens'))
  % Lines below are for 
  % correcting for if P0 is at corner of 
  % the first voxel instead of at the center
  M = M*[[eye(3) [0.5 0.5 0]']; 0 0 0 1]; % Correct for pixel-edge vs. center in-plane
else % GE or Philips? -> Reverse A/P & R/L
  M = diag([-1 -1 1 1])*M;
end

% Pre-allocate vol. Note: column and row designations do
% not really mean anything. The "column" is the fastest
% dimension. The "row" is the next fastest, etc.
ndim1 = dcminfo(1).Columns;
ndim2 = dcminfo(1).Rows;
ndim3 = nfiles;
vol = zeros(ndim1,ndim2,ndim3);

fprintf('Loading data\n');
for n = 1:nfiles
%  fprintf('n = %d, %g\n',n,toc);
  fname = deblank(flist(n,:));

  dcminfo4scaling = dicominfo(fname);
  if isfield(dcminfo4scaling, 'RescaleSlope') && isfield(dcminfo4scaling, 'RescaleIntercept')
    rescale_slope = dcminfo4scaling.RescaleSlope;
    rescale_intercept = dcminfo4scaling.RescaleIntercept;
    x = dicomread(fname);
    x = rescale_slope.*double(x) + rescale_intercept;
  else
    x = dicomread(fname);
  end

  if(isempty(x))
    fprintf('ERROR: could not load pixel data from %s\n',fname);
    return;
  end
  % Note: dicomread will transposed the image. This is supposed
  % to help. Anyway, to make the vox2ras transform agree with
  % the volume, the image is transposed back.
  vol(:,:,n) = x'; %'
end

% Reorder dimensions so that ReadOut dim is first %
if(0 & ~strcmpi(dcminfo(1).PhaseEncodingDirection,'ROW'))
  % This does not work
  fprintf('INFO: permuting vol so that ReadOut is first dim\n');
  vol = permute(vol,[2 1 3]);
  Mtmp = M;
  M(:,1) = Mtmp(:,2);
  M(:,2) = Mtmp(:,1);
end

M = c2matlab(M); % convert VOX2RAS matrix from zero-based to one-based voxelindexing 

%keyboard

return;

%----------------------------------------------------------%
function dcminfo2 = sort_by_sliceloc(dcminfo)
  nslices = length(dcminfo);
  sliceloc = zeros(nslices,1);
  for n = 1:nslices
    sliceloc(n) = dcminfo(n).SliceLocation;
  end

  [tmp ind] = sort(sliceloc);
  dcminfo2 = dcminfo(ind);
return;

%----------------------------------------------------------%

