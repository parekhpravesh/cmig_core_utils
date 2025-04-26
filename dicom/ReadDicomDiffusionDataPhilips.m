function [vol, Mvxl2ras, qmat, bvals, gwinfo, info] = ReadDicomDiffusionDataPhilips(indir)

file_list = recursive_dir(indir);
ref_file = file_list{1};
ref_info = dicominfo(ref_file);

enhanced_flag = 0;
if isfield(ref_info, 'PerFrameFunctionalGroupsSequence')
  enhanced_flag = 1;
end

totfiles = length(file_list);
fnames = {};
instancenumber = [];
slicelocation = [];
qmat = [];
bvals = [];
iter = 1;
fprintf('%s -- %s.m:    Reading DICOM headers...\n',datestr(now),mfilename);
for i = 1:totfiles
  fname = char(file_list(i));

  try
    info = dicominfo(fname);
    instancenumber(iter) = info.InstanceNumber;
    slicelocation(iter) = info.SliceLocation;

    bval = info.DiffusionBValue;
    bvals = [bvals; bval];
    qvec = info.DiffusionGradientOrientation';
    qmat = [qmat; qvec];

    fnames{iter} = fname;
    iter = iter+1;

  catch ME
    warning(sprintf('%s - %s\n',ME.message,fname))
    continue
  end

end

info = ref_info; % Sometimes(?) the last file isn't a regular image file, so reset the dicominfo variable

[instancenumber, sortindx] = sort(instancenumber);
qmat = qmat(sortindx,:);
bvals = bvals(sortindx);
slicelocation = slicelocation(sortindx);
fnames = fnames(sortindx);

nr = double(info.Rows);
nc = double(info.Columns);
ns = length(unique(slicelocation));
nframes = length(instancenumber) / ns;

fprintf('%s -- %s.m:    Loading DICOM data...\n',datestr(now),mfilename);
vol = zeros(nr, nc, ns, nframes);
for i = 1:nframes

  vol_indxs = i:nframes:length(fnames);
  vol_files = fnames(vol_indxs);

  for j = 1:length(vol_files)
    im = double(dicomread(vol_files{j}))';
    finfo = dicominfo(vol_files{j});
    rescale_slope = finfo.RescaleSlope;
    rescale_intercept = finfo.RescaleIntercept;
    scale_slope = double(finfo.MRScaleSlope);
    im = (im * rescale_slope + rescale_intercept) / (rescale_slope * scale_slope);
    vol(:,:,j,i) = im;
  end

end

M_LPH = read_dicom_M(vol_files);
Mvxl2ras = M_LPH_TO_RAS * M_LPH;

[gwinfo,errmsg] = mmil_get_gradwarpinfo(info);

qmat = qmat(1:nframes,:);
bvals = bvals(1:nframes);

if bvals(end)>0 && all(qmat(end,:)==[0 0 0])
   fprintf('WARNING: Last volume appears to be synthesized\n');
end

end
