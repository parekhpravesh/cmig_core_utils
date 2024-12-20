function enhanced_flag = mmil_check_enhanced(dcminfo)
%function enhanced_flag = mmil_check_enhanced(dcminfo)
%
% Created:  09/23/2024 by Don Hagler
% Last Mod: 09/23/2024 by Don Hagler
%

enhanced_flag = 0;

if isfield(dcminfo,'PerFrameFunctionalGroupsSequence')
  if ~isempty(mmil_getfield(dcminfo.PerFrameFunctionalGroupsSequence,'Item_1',[]));
    enhanced_flag = 1;
  end
end


