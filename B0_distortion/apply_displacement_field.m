function ctx_vol_resampled = apply_displacement_field(ctx_vol, ctx_field)

% Applies displacement in A/P direction only
% The field better be in units of voxel displacement

vol = permute(ctx_vol.imgs, [2 1 3 4]);
field = permute(ctx_field.imgs, [2 1 3]);
  
dims = size(vol);
flat_field = reshape(field, [dims(1), dims(2).*dims(3)]);
if length(dims) < 4
  flat_vol = reshape(vol, [dims(1), dims(2).*dims(3)]);
else
  flat_vol = reshape(vol, [dims(1), dims(2).*dims(3), dims(4)]);
end

resampled_voxel_inds = [1:dims(1)]' + flat_field;

vol_resampled = zeros(size(flat_vol));
for f = 1:size(flat_vol,3)
  disp(['Resampling frame ' num2str(f)]);
  for j = 1:size(flat_vol,2)
    vol_resampled(:,j,f) = interp1(flat_vol(:,j,f), resampled_voxel_inds(:,j), 'linear');
  end
end

vol_resampled(isnan(vol_resampled)) = 0;
vol_resampled = reshape(vol_resampled, dims);
ctx_vol_resampled = ctx_vol;
ctx_vol_resampled.imgs = permute(vol_resampled, [2 1 3 4]);

end
