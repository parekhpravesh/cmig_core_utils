function vox_shift_map = estimate_B0shift_imreg(ctxvol_DWI_fwd, ctxvol_DWI_rev)

% This function computes a voxel displacement map that can be applied to correct B0 distortion
% Inputs are the "forward" and "reverse" multi-shell DWI volumes, *averaged at each b-value*
% Inputs must be ctx structures
%        E.g., for a protocol with 5 b-values, ctxvol_DWI_fwd.imgs would have size [rows x columns x slices x 5]
% The output displacement map is also a ctx structure
% To apply the output displacement map to correct for B0 distortion, use the function: apply_displacement_field.m


% For now, only defined for protocols where the "reverse" scan has the same number of 
% b-values as the "forward" scan
if size(ctxvol_DWI_rev.imgs, 4) ~= size(ctxvol_DWI_fwd.imgs, 4)
   error('Reverse scan has different number of b-values than the forward scan');
end


vol_DWI_fwd = ctxvol_DWI_fwd.imgs;
vol_DWI_fwd = permute(vol_DWI_fwd, [2 1 3 4]);

vol_DWI_rev = ctxvol_DWI_rev.imgs;
vol_DWI_rev = permute(vol_DWI_rev, [2 1 3 4]);

vol1 = vol_DWI_fwd ./ sum(vol_DWI_fwd, 4); 
vol1(~isfinite(vol1)) = 0;
vol2 = vol_DWI_rev ./ sum(vol_DWI_rev, 4);
vol2(~isfinite(vol2)) = 0;

dims = size(vol1);
voxsz = sqrt(sum(ctxvol_DWI_fwd.Mvxl2lph(:,1:3).^2));
smf = 10;
vol1_sm = vol1; 
vol2_sm = vol2;
for fi = 1:dims(4)
  vol1_sm(:,:,:,fi) = real( smooth3d(vol1(:,:,:,fi), smf/voxsz(1), smf/voxsz(2), smf/voxsz(3)) );
  vol2_sm(:,:,:,fi) = real( smooth3d(vol2(:,:,:,fi), smf/voxsz(1), smf/voxsz(2), smf/voxsz(3)) );
end 

shiftfun = @(x,k) circshift_amd(x,k);

% Initialize pixel shift estimate
divol = zeros(dims(1:3)); 
divol_sm = zeros(dims(1:3));
niter = 3;
for iter = 1:niter
  errvol_sum = 0;

  if iter == 1
    lambda = 1e-4; 
  else 
    lambda = 1e-3; 
  end

  for fi = 1
    vol1_tmp = vol1_sm(:,:,:,fi); 
    vol2_tmp = vol2_sm(:,:,:,fi);

    dilist = linspace(-40, 40, 101);
    errvol = NaN([size(vol1_tmp) length(dilist)]);

    for dii = 1:length(dilist)
      di = dilist(dii);
      vol1_shift = shiftfun(vol1_tmp, di);
      vol2_shift = shiftfun(vol2_tmp, -di);
      errvol0 = 1e-4*di.^2 + abs(vol1_shift-vol2_shift).^2;
      errvol1 = lambda*(divol_sm-di).^2 + abs(vol1_shift-vol2_shift).^2; % Shrink towards 0
      errvol_tmp = errvol1;
      ivec = ~isfinite(errvol_tmp);
      errvol_tmp(ivec) = errvol0(ivec);
      errvol(:,:,:,dii) = errvol_tmp;
    end
    errvol_sum = errvol_sum + errvol;
  end

  errvol = errvol_sum;
  for dii = 1:length(dilist)
    errvol_sm(:,:,:,dii) = smoothn(errvol(:,:,:,dii), 1); % Smooth error vols
  end

  [mv_sm, mi_sm] = min(errvol_sm, [], 4);  
  divol = dilist(mi_sm);
  for fi = 1:size(divol_sm,3)
    divol_sm(:,:,fi) = smoothn(divol(:,:,fi),100,'robust');
  end

end

% Displacement polarity of circshift_amd is opposite that of RPG/topup
vox_shift_map = -divol;

ctx = ctxvol_DWI_fwd;
ctx.imgs = permute(vox_shift_map, [2 1 3]);
vox_shift_map = ctx;

end
