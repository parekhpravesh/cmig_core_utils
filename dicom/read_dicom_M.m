function M_LPH = read_dicom_M(fnames)

if ~iscell(fnames); fnames = {fnames}; end;
nfiles = length(fnames);

ref_info = dicominfo(fnames{1});

% Check for multiframe file
if nfiles == 1
   if isfield(ref_info, 'GridFrameOffsetVector')
      gfov = ref_info.GridFrameOffsetVector;
   end
end

% Check for enhanced DICOM
enhanced_flag = 0;
if isfield(ref_info, 'PerFrameFunctionalGroupsSequence')
  enhanced_flag = 1;
end

dcminfo_1 = ref_info;
if ~enhanced_flag

   PixelSpacing = dcminfo_1.PixelSpacing;
   ImageOrientationPatient = dcminfo_1.ImageOrientationPatient;
   ImagePositionPatient = dcminfo_1.ImagePositionPatient;
   SpacingBetweenSlices = dcminfo_1.SpacingBetweenSlices;

else

  if isfield(dcminfo_1.PerFrameFunctionalGroupsSequence.Item_1,'PixelMeasuresSequence')
    PixelSpacing = dcminfo_1.PerFrameFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.PixelSpacing;
    SpacingBetweenSlices = dcminfo_1.PerFrameFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.SpacingBetweenSlices;
  else
    PixelSpacing = dcminfo_1.SharedFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.PixelSpacing;
    SpacingBetweenSlices = dcminfo_1.SharedFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.SpacingBetweenSlices;
  end

  ImageOrientationPatient = dcminfo_1.PerFrameFunctionalGroupsSequence.Item_1.PlaneOrientationSequence.Item_1.ImageOrientationPatient;
  ImagePositionPatient = dcminfo_1.PerFrameFunctionalGroupsSequence.Item_1.PlanePositionSequence.Item_1.ImagePositionPatient;

end

row_orientation = ImageOrientationPatient(1:3);
col_orientation = ImageOrientationPatient(4:6);
slice_orientation = cross(col_orientation, row_orientation); % Because MGH convention is transposed

step_along_row = PixelSpacing(2) * row_orientation;
step_along_col = PixelSpacing(1) * col_orientation;

if exist('gfov', 'var')
  step_along_slice = (gfov(2)-gfov(1)) * slice_orientation;
else
  step_along_slice = SpacingBetweenSlices * slice_orientation;
end

M = eye(4);
M(1:3,1:3) = [step_along_row step_along_col step_along_slice];
M(1:3,4) = ImagePositionPatient-M(1:3,:)*[1 1 1 1]'; % Adjust for Matlab 1-based indexing

M_LPH = M;

end
