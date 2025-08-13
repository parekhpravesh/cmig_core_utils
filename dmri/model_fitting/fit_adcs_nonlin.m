function [vol_adc, vol_s0] = fit_adcs_nonlin(vol_dwi, bvals, options)

% Computes ADC map via nonlinear fitting of DWI images acquired at multiple b-values

fn_decay = @(x, xdata) x(1).*exp(-xdata.*x(2));
% x(1) => S0
% x(2) => ADC

lb = [0 0]';
ub = [1e4 3e-2]';
if bvals(1) == 0
   ub(1) = max(vol_dwi(:));
end

if ~exist('options', 'var')
   options.Display = 'off';
   options.CountVoxels = true;
end

[rows, cols, slices, ~] = size(vol_dwi);
num_voxels = numel(vol_dwi(:,:,:,1));

flat_data = zeros(length(bvals), num_voxels);
for i = 1:length(bvals)
    vol_b = vol_dwi(:,:,:,i);
    flat_data(i, :) = vol_b(:);
end

vec_s0 = zeros(1, num_voxels);
vec_adc = zeros(1, num_voxels);
for i = 1:num_voxels

    si_curve = flat_data(:,i);
    if sum(si_curve) == 0
       continue
    end

    x0 = [si_curve(1) 5e-4]';
    x_fit = lsqcurvefit(fn_decay, x0, bvals, si_curve, lb, ub, options);
    vec_s0(i) = x_fit(1);
    vec_adc(i) = x_fit(2);

    if isfield(options, 'CountVoxels') 
      if options.CountVoxels
	fprintf('%d/%d\n', i, num_voxels);
      end
    end

end

vol_adc = reshape(vec_adc, rows, cols, slices);
vol_s0 = reshape(vec_s0, rows, cols, slices);

end
