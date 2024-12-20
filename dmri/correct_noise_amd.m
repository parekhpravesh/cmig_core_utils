function [DWI_vol_nc, vol_noise_sm] = correct_noise_amd(DWI_vol, bvals, smf)

if ~exist('smf','var') || isempty(smf)
  smf = 100.0;
end

ubvals = unique(bvals);

vol_mu = mean(DWI_vol(:,:,:,bvals==max(bvals)), 4);
vol_sd = std(DWI_vol(:,:,:,bvals==max(bvals)), [], 4);

vol_edge = true(size(vol_mu));
vol_edge(2:end-1,2:end-1,2:end-1) = false;

vol_zero = vol_mu==0;
vol_nz = ~vol_zero;

vol_zero_dil = imdilate(vol_zero|vol_edge,strel('cube',5));
vol_ambiguous = vol_zero_dil>vol_zero;

% The second half of this line identifies the noise voxels
vol_mask = imerode(~(vol_edge|vol_zero),strel('cube',3)) & ((mean(DWI_vol(:,:,:,bvals==ubvals(2)),4)-vol_mu)./max(eps,vol_sd)<1);

vol_noise = vol_mu;
vol_noise(~vol_mask) = NaN;
vol_noise_sm = smoothn(vol_noise, smf, 'robust');
DWI_vol_nc = DWI_vol - vol_noise_sm;

vol_set_to_zero = vol_zero | (vol_ambiguous & vol_mu<0.5*vol_noise_sm);
vol_noise_sm = (~vol_set_to_zero) .* vol_noise_sm;
DWI_vol_nc = (~vol_set_to_zero) .* DWI_vol_nc;

end


% ToDos
%   Look into using RSI fitting on non-noise corrected RSI data to estimate noise level?

