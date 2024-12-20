function ctx_vol = uncrop_volume(ctx_vol_cropped, col_inds, uncropped_col_count)

% Assumes empty regions are A/P

vol_cropped = ctx_vol_cropped.imgs;
vol = zeros( size(vol_cropped,1), uncropped_col_count, size(vol_cropped,3), size(vol_cropped,4) );
vol(:,col_inds,:,:) = vol_cropped;

ctx_vol = ctx_vol_cropped;
ctx_vol.imgs = vol;
ctx_vol.dimc = uncropped_col_count;

end
