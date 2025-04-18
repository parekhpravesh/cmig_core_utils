function OAR_write_dicom(vol, dicomdir, outputdir, SeriesDescription, SeriesNumber, SeriesType, newmetadata)

% vol - volume (as ctx struct) to be written into dicom
% dicomdir - template dicoms
% outputdir - directory to save created dicoms
% SeriesDescription - SeriesDescription
% SeriesNumber
% SeriesType - Modality, e.g., 'MR' or 'CT' 
% newmetadata - For overwriting DICOM tags with custom values

if ~exist('SeriesNumber','var'); SeriesNumber = 10000; end
if ~exist('SeriesType', 'var'); SeriesType = 'MR'; end

SeriesInstanceUID = dicomuid;
mkdir(outputdir);

if iscell(dicomdir)
    file_list = dicomdir;
else
    file_list = recursive_dir(dicomdir);
end
totfiles = length(file_list);

for i = 1:totfiles
  x = dicomread(file_list{i});
  if ~isempty(x)
    ref_dcminfo = dicominfo(file_list{i});
  end
end

mosaic_flag = 0;
if isfield(ref_dcminfo, 'ImageType')
  mosaic_flag = ~isempty(regexpi(ref_dcminfo.ImageType, 'MOSAIC'));
end

rtdose_flag = 0;
if isfield(ref_dcminfo, 'Modality')
  rtdose_flag = ~isempty(regexpi(ref_dcminfo.Modality, 'RTDOSE'));
end

multiframe_flag = 0;
if isfield(ref_dcminfo, 'NumberOfFrames')
  multiframe_flag = 1;
  [rows, cols, slices, frames] = size(vol.imgs);
end

fprintf('%s -- %s | Reading DICOM info...\n', datestr(now), mfilename);
if mosaic_flag || rtdose_flag || multiframe_flag
  dcminfo = ref_dcminfo;

else
  ivec = NaN(1,totfiles);
  for i = 1:totfiles;
    fnametmp = char(file_list(i));
    dcminfo{i} = dicominfo(fnametmp);
    ivec(i) = dcminfo{i}.InstanceNumber;
    if isequal( unique(ivec(~isnan(ivec))), 1:vol.dimd )
      break
    end
  end

  ivec = ivec(~isnan(ivec));
  [ivec, sortinds] = sort(ivec);
  dcminfo = dcminfo(sortinds);

end

maxvol = max(vol.imgs(:));
dat = vol.imgs;
[hc hv] = hist(dat(find(dat>0)),1000);
cdf_hc = cumsum(hc)/sum(hc);
val1 = min(hv(find(cdf_hc>0.99)));
val2 = min(hv(find(cdf_hc>0.10)));
val3 = min(hv(find(cdf_hc>0.90)));

fprintf('%s -- %s | Writing DICOM images...\n', datestr(now), mfilename);

total_files = size(vol.imgs,3) * size(vol.imgs,4);
if multiframe_flag
   total_files = 1;
end

rgb_flag = 0;
if exist('newmetadata', 'var')
  if isfield(newmetadata, 'PhotometricInterpretation')
    if strcmp(newmetadata.PhotometricInterpretation, 'RGB')
      total_files = size(vol.imgs,3);
      rgb_flag = 1;
    end
  end
end

slice_counter = 1;
vol_counter = 1;
for i = 1:total_files

  if slice_counter > size(vol.imgs,3)
    slice_counter = 1;
    vol_counter = vol_counter + 1;
  end

  if mosaic_flag || rtdose_flag || multiframe_flag
    metadata = dcminfo;
  else
    metadata = dcminfo{find(ivec == slice_counter)};
  end

  %% Image geometry
  ipp = vol.Mvxl2lph*[1 1 slice_counter 1]';
  metadata.ImagePositionPatient = ipp(1:3);
  metadata.SliceLocation = ipp(3);
  metadata.SliceThickness = abs(vol.Mvxl2lph(3,3));
  metadata.PixelSpacing = [vol.Mvxl2lph(1,1) vol.Mvxl2lph(2,2)]';

  metadata.InstanceNumber = i;
  metadata.LargestImagePixelValue = maxvol;
  metadata.SmallestImagePixelValue = 0;
  metadata.WindowWidth = (val1-val2);
  metadata.WindowCenter = val3;
  metadata.SeriesDescription = sprintf('%s', SeriesDescription);
  metadata.SeriesNumber = SeriesNumber;
  metadata.SeriesInstanceUID = SeriesInstanceUID;
  metadata.Modality = SeriesType;
  metadata.RescaleSlope = 1;
  metadata.RescaleIntercept = 0;

  if strcmp(SeriesType, 'MR')
    metadata.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
    metadata.SOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
  end

  if strcmp(SeriesType, 'CT')
    metadata.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
    metadata.SOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
  end

  duid = dicomuid;
  metadata.MediaStorageSOPInstanceUID = duid;
  metadata.SOPInstanceUID = duid;
  metadata.ImageType = 'DERIVED\SECONDARY';	

  if exist('newmetadata', 'var')
    if ~isempty(newmetadata)
      tags = fieldnames(newmetadata);
      for t = 1:length(tags)
	metadata.(tags{t}) = newmetadata.(tags{t});
      end
    end
  end

  fname_out = sprintf('%s/im%3.4i.dcm',outputdir,i);

  switch metadata.BitDepth
    case 8
      metadata.BitsAllocated = 8;
      metadata.BitsStored = 8;
      metadata.HighBit = 7;
      if multiframe_flag
	dat = reshape(dat, [rows, cols, frames, slices]);
	dicomwrite( uint8( permute(dat, [2 1 3 4]) ), fname_out, metadata, 'CreateMode', 'copy', 'MultiframeSingleFile', 'true' );
      elseif ~rgb_flag
	dicomwrite( uint8( squeeze(dat(:,:,slice_counter,vol_counter))' ), fname_out, metadata, 'CreateMode', 'copy' );
      else
	dicomwrite( uint8( permute(squeeze(dat(:,:,slice_counter,:)), [2 1 3]) ), fname_out, metadata, 'CreateMode', 'copy' );
      end
    case 16
      metadata.BitsAllocated = 16;
      metadata.BitsStored = 16;
      metadata.HighBit = 15;
      if multiframe_flag
	dat = reshape(dat, [rows, cols, frames, slices]);
	dicomwrite( uint16( permute(dat, [2 1 3 4]) ), fname_out, metadata, 'CreateMode', 'copy', 'MultiframeSingleFile', 'true' );
      elseif ~rgb_flag
	dicomwrite( uint16( squeeze(dat(:,:,slice_counter,vol_counter))' ), fname_out, metadata, 'CreateMode', 'copy' );
      else
	dicomwrite( uint16( permute(squeeze(dat(:,:,slice_counter,:)), [2 1 3]) ), fname_out, metadata, 'CreateMode', 'copy' );
      end
    otherwise
      metadata.BitsAllocated = 16;
      metadata.BitsStored = 16;
      metadata.HighBit = 15;
      if multiframe_flag
	dat = reshape(dat, [rows, cols, frames, slices]);
	dicomwrite( uint16( permute(dat, [2 1 3 4]) ), fname_out, metadata, 'CreateMode', 'copy', 'MultiframeSingleFile', 'true' );
      elseif ~rgb_flag
	dicomwrite( uint16( squeeze(dat(:,:,slice_counter,vol_counter))' ), fname_out, metadata, 'CreateMode', 'copy' );
      else
	dicomwrite( uint16( permute(squeeze(dat(:,:,slice_counter,:)), [2 1 3]) ), fname_out, metadata, 'CreateMode', 'copy' );
      end
  end

  slice_counter = slice_counter + 1;

  fprintf('%s\n', num2str(i));

end
fprintf('\n%s - Finished \n',mfilename);

end
