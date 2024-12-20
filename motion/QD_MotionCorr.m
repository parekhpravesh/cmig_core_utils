function [vol_corr qmat_corr Mreg_mat] = QD_MotionCorr(vol,M,qmat,bvals);
%
% Registers each frame (volume) to synthesized frame (i.e. mean)
% but keeps registration locked to first b = 0 frame

[nx ny nz nf] = size(vol);

% synthesize dataset from corrected images
volmask = QD_Compute_Volmask(vol(:,:,:,1));
DTfit = QD_Fit_Tensor(vol,qmat,bvals,1,volmask);
DTSynth = QD_Synth_Diffusion_Data(DTfit.D,qmat,bvals);

% initialize
vol_corr = zeros(size(vol));
qmat_corr = zeros(size(qmat));
vol_corr(:,:,:,1) = vol(:,:,:,1); % b=0
qmat_corr(1,:) = qmat(1,:);

M_tmp = eye(4);
M_d1 = eye(4);
Mreg_mat = zeros(nf,4,4);
Mreg_mat(1,:,:) = M_tmp;

% register original data to synthesized data
for i = 2:nf
    fprintf('%s -- %s.m:    Registering frame %d of %d\n',datestr(now),mfilename,i,nf);
    
    vol_orig = mgh2ctx(vol(:,:,:,i),M);
    vol_ref = mgh2ctx(DTSynth(:,:,:,i),M);
    numiters = 20; bdispiter = false; mstep = 1; bsmooth = false;
    M_tmp = QD_rbreg_vol2vol_EKF(vol_ref,vol_orig,mgh2ctx(volmask,M));

    % lock registration to first diffusion weighted scan  
    if i == 2;M_d1 = M_tmp;end
    M_reg = inv(M_d1)*M_tmp;

    Mreg_mat(i,:,:) = M_reg;

    % resample original data
    vol_orig_reg = vol_resample(vol_orig,vol_ref,M_reg,1);
    vol_corr(:,:,:,i) = vol_orig_reg.imgs;

    % rotate qmat
    M_v1_to_v2_RAS = M_LPH_TO_RAS*M_reg*M_RAS_TO_LPH;
    qmat_corr(i,:) = (inv(M_v1_to_v2_RAS(1:3,1:3))*qmat(i,:)')';
end
fprintf('%s -- %s.m:    Finished successfully.\n',datestr(now),mfilename)
