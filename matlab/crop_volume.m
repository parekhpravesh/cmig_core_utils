function [ctx_vol_cropped, col_inds] = crop_volume(ctx_vol, col_start, col_end)

% Assumes empty regions are A/P

vol = ctx_vol.imgs;

if ~exist('col_start', 'var')

  col_start = 1;
  for j = 1:size(vol,2)
    sample = vol(:,j,:,:);
    if any(sample)
      col_start = j;
      break;
    end
  end

  col_end = size(vol,2);
  for j = size(vol,2):-1:1
    sample = vol(:,j,:,:);
    if any(sample)
      col_end = j;
      break;
    end
  end

end

col_count = col_end - col_start + 1;
col_inds = col_start:col_end;

ctx_vol_cropped = ctx_vol;
ctx_vol_cropped.imgs = vol(:,col_inds,:,:);
ctx_vol_cropped.dimc = col_count;

end
