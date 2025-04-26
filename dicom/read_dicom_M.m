function M_LPH = read_dicom_M(fnames)

if ~iscell(fnames), fnames = {fnames}; end;
nfiles = length(fnames);

% Check for multiframe file
if nfiles == 1
   dcminfo_mf = dicominfo(fnames{1});
   if isfield(dcminfo_mf, 'GridFrameOffsetVector')
      gfov = dcminfo_mf.GridFrameOffsetVector;
   end
end

fname=char(fnames{1});
if ~exist(fname,'file')
  fprintf('%s: ERROR: file %s not found\n',mfilename,fname);
  M=[];
  return
end
dcminfo_1 = dicominfo(fname);

fname=char(fnames{end});
if ~exist(fname,'file')
  fprintf('%s: ERROR: file %s not found\n',mfilename,fname);
  M=[];
  return
end
dcminfo_end = dicominfo(fname);

rvec = dcminfo_1.PixelSpacing(2)*dcminfo_1.ImageOrientationPatient(1:3);
rdir = rvec ./ norm(rvec);
cvec = dcminfo_1.PixelSpacing(1)*dcminfo_1.ImageOrientationPatient(4:6);
cdir = cvec ./ norm(cvec);
sdir = cross(rdir, cdir);

M = eye(4);
M(1:3,1:2) = [rvec cvec];
if exist('gfov', 'var') 
  M(1:3,3) = (gfov(2)-gfov(1)) * sdir;
else
  M(1:3,3) = (dcminfo_end.ImagePositionPatient-dcminfo_1.ImagePositionPatient)/(nfiles-1);
end
M(1:3,4) = dcminfo_1.ImagePositionPatient-M(1:3,:)*[1 1 1 1]'; % Adjust for Matlab 1-based indexing

M_LPH = M;

end
