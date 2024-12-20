function volmask = QD_Compute_Volmask(volb0);
%

sig = mean(volb0(find(volb0>0)));
volmask = zeros(size(volb0));
volmask(find(volb0>.7*sig))=1;
