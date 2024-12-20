function ds = OAR_RS_AddRTROIObservation(ds, segSTRUCT)

for id1 = 1:numel(segSTRUCT)
	rtroi_observation(id1).ObservationNumber = segSTRUCT(id1).number;
	rtroi_observation(id1).ReferencedROINumber = segSTRUCT(id1).number; 
	
	rtroi_identification_code(1).CodeValue = 'NormalTissue';
	rtroi_identification_code(1).CodingSchemeDesignator = '99VMS_STRUCTCODE';
	rtroi_identification_code(1).CodingSchemeVersion = '1.0';
	rtroi_identification_code(1).CodeMeaning = 'Undefined Normal Tissue';
	rtroi_identification_code(1).MappingResource = '99VMS';
	rtroi_identification_code(1).ContextGroupVersion = '20161209';
	rtroi_identification_code(1).ContextIdentifier = 'VMS011';
	rtroi_identification_code(1).ContextUID = '1.2.246.352.7.2.11';
	rtroi_identification_code(1).MappingResourceUID = '1.2.246.352.7.1.1';
	rtroi_identification_code(1).MappingResourceName = 'Unspecified';
	rtroi_identification_code = OAR_RS_sequence(rtroi_identification_code); 

% 	rtroi_observation(id1).RTROIIdentificationCodeSequence = rtroi_identification_code;

	
	rtroi_observation(id1).RTROIInterpretedType = 'ORGAN';
	rtroi_observation(id1).ROIInterpreter = '';
		

end
rtroi_observation = OAR_RS_sequence(rtroi_observation); 
ds.RTROIObservationsSequence  = rtroi_observation;

return
