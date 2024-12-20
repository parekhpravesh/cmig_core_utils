function ds = OAR_RS_AddReferencedFrameOfReference(ds, dcminfo)
% function ds = OAR_RS_AddReferencedFrameOfReference(ds, dcminfo)

for id1 = 1:numel(dcminfo)
        %contour_image_sequence(id1).ReferencedSOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
	contour_image_sequence(id1).ReferencedSOPClassUID = dcminfo{id1}.SOPClassUID; 
        contour_image_sequence(id1).ReferencedSOPInstanceUID = dcminfo{id1}.SOPInstanceUID;
end
contour_image_sequence = OAR_RS_sequence(contour_image_sequence);
rt_refd_series_sequence(1).SeriesInstanceUID = dcminfo{1}.SeriesInstanceUID;
rt_refd_series_sequence(1).ContourImageSequence = contour_image_sequence;
rt_refd_series_sequence = OAR_RS_sequence(rt_refd_series_sequence);
rt_refd_study_sequence(1).ReferencedSOPClassUID = dcminfo{1}.SOPClassUID;;
rt_refd_study_sequence(1).ReferencedSOPInstanceUID = dcminfo{1}.StudyInstanceUID;
rt_refd_study_sequence(1).RTReferencedSeriesSequence = rt_refd_series_sequence;
rt_refd_study_sequence = OAR_RS_sequence(rt_refd_study_sequence);
refd_frame_of_ref_sequence(1).FrameOfReferenceUID = dcminfo{1}.FrameOfReferenceUID;
refd_frame_of_ref_sequence(1).RTReferencedStudySequence = rt_refd_study_sequence;
refd_frame_of_ref_sequence = OAR_RS_sequence(refd_frame_of_ref_sequence);
ds.ReferencedFrameOfReferenceSequence = refd_frame_of_ref_sequence;

return
