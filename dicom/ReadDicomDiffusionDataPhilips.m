function [vol, Mvxl2ras, qmat, bvals, gwinfo, info, inds_synth] = ReadDicomDiffusionDataPhilips(indir)

file_list = recursive_dir(indir);
ref_file = file_list{1};
ref_info = dicominfo(ref_file);

[gwinfo, errmsg] = mmil_get_gradwarpinfo(ref_info);

enhanced_flag = 0;
if isfield(ref_info, 'PerFrameFunctionalGroupsSequence')
  enhanced_flag = 1;
end


if enhanced_flag % Enhanced DICOM ------------------------------------------------------

  M_LPH = read_dicom_M(ref_file);
  Mvxl2ras = M_LPH_TO_RAS * M_LPH;
   
  info = ref_info;

  frames = info.NumberOfFrames;
  posmat = NaN(frames, 9);
  bvals = NaN(frames, 1);
  qmat = NaN(frames, 3);

  for i = 1:frames
    item_str = sprintf('Item_%d', i);

    ImagePositionPatient = info.PerFrameFunctionalGroupsSequence.(item_str).PlanePositionSequence.Item_1.ImagePositionPatient;
    ImageOrientationPatient = info.PerFrameFunctionalGroupsSequence.(item_str).PlaneOrientationSequence.Item_1.ImageOrientationPatient;
    posmat(i,:) = cat(2, ImagePositionPatient', ImageOrientationPatient');

    bval = info.PerFrameFunctionalGroupsSequence.(item_str).MRDiffusionSequence.Item_1.DiffusionBValue;
    bvals(i) = bval;

    if isfield(info.PerFrameFunctionalGroupsSequence.(item_str).MRDiffusionSequence.Item_1, 'DiffusionGradientDirectionSequence')
      qvec = info.PerFrameFunctionalGroupsSequence.(item_str).MRDiffusionSequence.Item_1.DiffusionGradientDirectionSequence.Item_1.DiffusionGradientOrientation';
      qmat(i,:) = qvec;
    end

  end

  [C, IA, IC] = unique(posmat,'stable','rows');
  slices = length(C);
  frame_vols = frames / slices;

  vol_unsorted = dicomread(ref_file);
  [rows, cols, ~] = size(vol_unsorted);
  vol = zeros(rows, cols, slices, frame_vols);
  for i = 1:slices
    for j = 1:frame_vols
      vol(:,:,i,:) = vol_unsorted(:,:,:,IC==j);
    end
  end

  bvals = bvals(IC==1); 
  qmat = qmat(IC==1,:);


else % Classic DICOM -----------------------------------------------------------------------

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

  M_LPH = read_dicom_M(fnames);
  Mvxl2ras = M_LPH_TO_RAS * M_LPH;

  nr = double(info.Rows);
  nc = double(info.Columns);
  slices = length(unique(slicelocation));
  nframes = length(instancenumber) / slices;

  fprintf('%s -- %s.m:    Loading DICOM data...\n',datestr(now),mfilename);
  vol = zeros(nr, nc, slices, nframes);
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

  qmat = qmat(1:nframes,:);
  bvals = bvals(1:nframes);

end


% Check for synthesized volumes
ind_b_nonzero = bvals > 0;
ind_nan = isnan(qmat);
ind_nan = sum(ind_nan, 2) == 3;
ind_q0 = qmat == 0;
ind_q0 = sum(ind_q0, 2) == 3;
inds_synth = ind_b_nonzero & (ind_nan | ind_q0);

if any(inds_synth)
   fprintf('WARNING: DWI data contains synthesized volume(s)\n');
end


end
