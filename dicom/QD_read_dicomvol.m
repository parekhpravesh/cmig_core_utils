function [vol, M] = QD_read_dicomvol(fnames, rescale_flag, sortflag);
%
warnstatussave = warning;
warning('off');

if ~exist('rescale_flag', 'var')
   rescale_flag = 1;
end

if ~exist('sortflag','var') || isempty(sortflag)
  sortflag = true;
end 

% Remove CT scout images
ct_flag = 0;
modality = getfield(dicominfo(fnames{1}),'Modality');
if ~isempty(regexpi(modality, 'CT'))
  ct_flag = 1;
end

if ct_flag
  counter = 1;
  for i = 1:length(fnames)
    imtype = getfield(dicominfo(fnames{i}),'ImageType');
    if isempty(regexpi(imtype, 'LOCALIZER'))
      fnames2{counter} = fnames{i};
      counter = counter + 1;
    end
  end
  fnames = fnames2;    
end

if sortflag
  for fi = 1:length(fnames)
    posvec(fi) = getfield(dicominfo(fnames{fi}),'InstanceNumber');
  end
  [sv si] = sort(posvec);
  fnames = fnames(si);
end

vol=[];
M = eye(4);
nfiles = length(fnames);
fname=char(fnames{1});
if ~exist(fname,'file')
  fprintf('%s: ERROR: file %s not found\n',mfilename,fname);
  vol=[];
  return;
end;
dcminfo_1 = dicominfo(fname);
fname=char(fnames{end});
if ~exist(fname,'file')
  fprintf('%s: ERROR: file %s not found\n',mfilename,fname);
  vol=[];
  return;
end;
dcminfo_end = dicominfo(fname);
M(1:3,1:2) = [dcminfo_1.PixelSpacing(1)*dcminfo_1.ImageOrientationPatient(1:3) dcminfo_1.PixelSpacing(2)*dcminfo_1.ImageOrientationPatient(4:6)];
M(1:3,3) = (dcminfo_end.ImagePositionPatient-dcminfo_1.ImagePositionPatient)/(nfiles-1);
M(1:3,4) = dcminfo_1.ImagePositionPatient-M(1:3,:)*[1 1 1 1]'; % Adjust for Matlab 1-based indexing
M = M_LPH_TO_RAS*M; % Convert from DICOM LPH to RAS coordinates

dim1 = dcminfo_1.Columns;
dim2 = dcminfo_1.Rows;
dim3 = nfiles;
vol = zeros(dim1,dim2,dim3);
for n = 1:nfiles
  fname = char(fnames{n});
  if ~exist(fname,'file')
    fprintf('%s: ERROR: file %s not found\n',mfilename,fname);
    vol=[];
    return;
  end;
  try
    x = double(dicomread(fname));
    hdr = dicominfo(fname);

    if rescale_flag && isfield(hdr,'RescaleIntercept') && isfield(hdr,'RescaleSlope')  % AMD: Rescale image values, if fields exist
      x = hdr.RescaleIntercept + hdr.RescaleSlope*x;
    end

  catch
    fprintf('%s: ERROR: dicom file %s may be corrupt\n',mfilename,fname);
    vol=[];
    return;
  end;
  if(isempty(x))
    fprintf('%s: ERROR: could not load pixel data from %s\n',mfilename,fname);
    vol=[];
    return;
  end
  vol(:,:,n) = x'; %
end

warning(warnstatussave);
