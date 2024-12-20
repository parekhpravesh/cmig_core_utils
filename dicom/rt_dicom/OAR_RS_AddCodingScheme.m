function ds = OAR_RS_AddCodingScheme(ds)
% function ds = OAR_RS_AddCodingScheme(ds)

% Coding Sequence Identification
coding_scheme_identification_sequence(1).CodingSchemeDesignator = '99VMS_STRUCTCODE';
coding_scheme_identification_sequence(1).CodingSchemeUID = '1.2.246.352.7.3.10';
coding_scheme_identification_sequence(1).CodingSchemeName = 'Structure Codes';
coding_scheme_identification_sequence(1).CodingSchemeResponsibleOrganization = 'Unspecified';
coding_scheme_identification_sequence(2).CodingSchemeDesignator = 'FMA';
coding_scheme_identification_sequence(2).CodingSchemeUID = '2.16.840.1.113883.6.119';
coding_scheme_identification_sequence = OAR_RS_sequence(coding_scheme_identification_sequence); 

% Context Group Identification Sequence
context_group_identification_sequence(1).MappingResource = '99VMS';
context_group_identification_sequence(1).ContextGroupVersion = '20161209';
context_group_identification_sequence(1).ContextIdentifier = 'VMS011';
context_group_identification_sequence(1).ContextUID = '1.2.246.352.7.2.11';
context_group_identification_sequence = OAR_RS_sequence(context_group_identification_sequence); 

% Mapping Resource Identification Sequence 
mapping_resource_identification_sequence(1).MappingResource = '99VMS';
mapping_resource_identification_sequence(1).MappingResourceUID = '1.2.246.352.7.1.1';
mapping_resource_identification_sequence(1).MappingResourceName = 'Unspecified';
mapping_resource_identification_sequence = OAR_RS_sequence(mapping_resource_identification_sequence); 

ds.CodingSchemeIdentificationSequence = coding_scheme_identification_sequence;
ds.ContextGroupIdentificationSequence = context_group_identification_sequence;
ds.MappingResourceIdentificationSequence = mapping_resource_identification_sequence;


return
