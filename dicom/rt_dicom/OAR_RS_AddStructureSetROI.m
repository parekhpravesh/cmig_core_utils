function ds = OAR_RS_AddStructureSetROI(ds, dcminfo, segSTRUCT)
% function ds = OAR_RS_AddStructureSetROI(ds, dcminfo, segSTRUCT)

for id1 = 1:numel(segSTRUCT)
	structure_set_roi_sequence(id1).ROINumber = segSTRUCT(id1).number; 
	structure_set_roi_sequence(id1).ReferencedFrameOfReferenceUID = dcminfo{1}.FrameOfReferenceUID; 
	structure_set_roi_sequence(id1).ROIName = segSTRUCT(id1).name; 
	structure_set_roi_sequence(id1).ROIGenerationAlgorithm = 'MANUAL';
end
structure_set_roi_sequence = OAR_RS_sequence(structure_set_roi_sequence); 
ds.StructureSetROISequence = structure_set_roi_sequence; 
return
