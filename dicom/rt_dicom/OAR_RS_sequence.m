function sequence = OAR_RS_sequence(in_struct)
% function sequence = OAR_RS_sequence(in_struct)

for id1 = 1:numel(in_struct)
	temp = in_struct(id1); 
	sequence.(sprintf('Item_%i', id1)) = temp; 
	clear temp;
end
return
