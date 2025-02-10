function ctx_seg = loadSegmentation(path_RTst, path_ref_dcms) 
% path_RTst = path to the RTst DICOM
% path_ref_dcms = path to the DICOM folder connected to the RTst DICOM

volumeCTX = QD_read_dicomdir(path_ref_dcms);

segmentationDicomInfo = dicominfo(path_RTst, 'UseVRHeuristic', false);
segmentationData = dicomContours(segmentationDicomInfo);
segnums = segmentationData.ROIs.Number;

min_coords = volumeCTX.Mvxl2lph * [1 1 1 1]';
max_coords = volumeCTX.Mvxl2lph * [size(volumeCTX.imgs) 1]';
referenceInfo = imref3d(size(volumeCTX.imgs), [min_coords(1) max_coords(1)], [min_coords(2) max_coords(2)], [min_coords(3) max_coords(3)]); % Check on order of x and y; handle oblique acquisition?

ctx_seg = volumeCTX;
ctx_seg.imgs = zeros([size(volumeCTX.imgs) length(segnums)]);
for i = 1:length(segnums)
  ctx_seg.imgs(:,:,:,i) = permute(double(createMask(segmentationData, segmentationData.ROIs.Name{i}, referenceInfo)), [2 1 3]);
  ctx_seg.labels{i} = segmentationData.ROIs.Name{i};
end

end
