function vox_shift_map = RPG_estimate_displacements(fname_fwd, fname_rev, params)

vol_fwd_orig = QD_ctx_load_mgh(fname_fwd);
vol_rev_orig = QD_ctx_load_mgh(fname_rev);

% Remove zero-padding 
[vol_fwd_cropped, col_inds_fwd] = crop_volume(vol_fwd_orig);
[vol_rev_cropped, col_inds_rev] = crop_volume(vol_rev_orig);
if length(col_inds_fwd) ~= length(col_inds_rev)
   col_inds_rev = col_inds_fwd;
   [vol_rev_cropped, ~] = crop_volume(vol_rev_orig, col_inds_rev(1), col_inds_rev(end));
end
QD_ctx_save_mgh(vol_fwd_cropped, fname_fwd);
QD_ctx_save_mgh(vol_rev_cropped, fname_rev);

% Run RPG
fprintf('%s -- %s.m:    Estimating B0 Distortions...\n', datestr(now), mfilename);
try
  B0_Optimization(fname_fwd, fname_rev, params);
  fprintf('%s -- %s.m:    Finished estimating B0 Distortions...\n', datestr(now), mfilename);
catch
  fprintf('%s -- %s.m:    ERROR: RPG B0 estimation failed...\n', datestr(now), mfilename);
  QD_ctx_save_mgh(vol_fwd_orig, fname_fwd);
  QD_ctx_save_mgh(vol_rev_orig, fname_rev);
  vox_shift_map = [];
  return;
end

% Put zero-padding back on all volumes
QD_ctx_save_mgh(vol_fwd_orig, fname_fwd);
QD_ctx_save_mgh(vol_rev_orig, fname_rev);

[fpath, fname, ext] = fileparts(fname_fwd);
fname_fwd_B0uw = sprintf('%s/%s_B0uw_exe.mgz', fpath, fname);
fname_dx = sprintf('%s/%s_B0dx_exe.mgz', fpath, fname);
[fpath, fname, ext] = fileparts(fname_rev);
fname_rev_B0uw = sprintf('%s/%s_B0uw_exe.mgz', fpath, fname);
fname_avg = sprintf('%s/avgEIP.mgz', fpath);
fname_dif = sprintf('%s/difEIP.mgz', fpath);

cols_fwd_orig = size(vol_fwd_orig.imgs, 2);
cols_rev_orig = size(vol_rev_orig.imgs, 2);

vol_fwd_B0uw = QD_ctx_load_mgh(fname_fwd_B0uw);
vol_fwd_B0uw = uncrop_volume(vol_fwd_B0uw, col_inds_fwd, cols_fwd_orig);
QD_ctx_save_mgh(vol_fwd_B0uw, fname_fwd_B0uw);

vol_rev_B0uw = QD_ctx_load_mgh(fname_rev_B0uw);
vol_rev_B0uw = uncrop_volume(vol_rev_B0uw, col_inds_rev, cols_rev_orig);
QD_ctx_save_mgh(vol_rev_B0uw, fname_rev_B0uw);

vol_dx = QD_ctx_load_mgh(fname_dx);
vol_dx = uncrop_volume(vol_dx, col_inds_fwd, cols_fwd_orig);
QD_ctx_save_mgh(vol_dx, fname_dx);

vol_avg = QD_ctx_load_mgh(fname_avg);
vol_avg = uncrop_volume(vol_avg, col_inds_fwd, cols_fwd_orig);
QD_ctx_save_mgh(vol_avg, fname_avg);

vol_dif = QD_ctx_load_mgh(fname_dif);
vol_dif = uncrop_volume(vol_dif, col_inds_fwd, cols_fwd_orig);
QD_ctx_save_mgh(vol_dif, fname_dif);

% Return estimated displacement field
vox_shift_map = vol_dx;

end
