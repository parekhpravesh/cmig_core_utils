function corr_final = B0_Optimization(fname_f, fname_r, B0optFlag, corrmin)

if ~exist('B0optFlag','var')
    B0optFlag = 1;
end
if ~exist('corrmin','var')
    corrmin=.95;
end

[fpath fname ext] = fileparts(fname_f);
fname_f_B0uw = sprintf('%s/%s_B0uw_exe.mgz',fpath,fname);
fname_dx = sprintf('%s/%s_B0dx_exe.mgz',fpath,fname);
[fpath fname ext] = fileparts(fname_r);
fname_r_B0uw = sprintf('%s/%s_B0uw_exe.mgz',fpath,fname);
fname_avg = sprintf('%s/avgEIP.mgz',fpath);
fname_dif = sprintf('%s/difEIP.mgz',fpath);

% B0 Optimization
[vol_f Mf] = QD_load_mgh(fname_f);
[vol_r Mr] = QD_load_mgh(fname_r);
mu = (vol_f + vol_r)/2;
sig = mean(mu(find(mu>0)));
volmask = zeros(size(mu));
volmask(find(mu>.7*sig)) = 1;
volmask = double(real(smooth3d(single(volmask),15,15,15))); % Smooth and dilate mask
volmask = 1.0*(volmask>0.1);
inds = find(volmask);

if B0optFlag == 2 % full opt
    
    kvec = [4:2:20];
    lvec = [100:200:1000 3000:500:5000];
    cormat = zeros(length(kvec),length(lvec));
    
    for i = 1:length(kvec)
        kernelWidthMax = kvec(i);
        for j = 1:length(lvec)
            lambda2 = lvec(j);
            QD_Estimate_B0(fname_f, fname_r, kernelWidthMax, lambda2);
            vol_f_B0uw = QD_load_mgh(fname_f_B0uw);
            vol_r_B0uw = QD_load_mgh(fname_r_B0uw);
            cormat(i,j) = corr(vol_f_B0uw(inds),vol_r_B0uw(inds));
            fprintf('%s -- %s.m:    Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
	    if cormat(i,j) >= corrmin
                fname_out = sprintf('%s/%s_B0opt_kernelWidthMax_%g_lamda2_%g_cost_%g',fpath,fname,kernelWidthMax,lambda2,cormat(i,j));
                unix(sprintf('touch %s',fname_out));
                fprintf('%s -- %s.m:    Final Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
                corr_final = cormat(i,j);
                return
            end
        end
    end
    
    [i, j] = find(cormat==max(cormat(:)));
    kernelWidthMax = kvec(i(1));
    lambda2 = lvec(j(1));
    fname_out = sprintf('%s/%s_B0opt_kernelWidthMax_%g_lamda2_%g_cost_%g',fpath,fname,kernelWidthMax,lambda2,cormat(i,j));
    unix(sprintf('touch %s',fname_out));
    fprintf('%s -- %s.m:    Final Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
    QD_Estimate_B0(fname_f, fname_r, kernelWidthMax, lambda2);
    corr_final = cormat(i,j);
    
elseif B0optFlag == 1 % partial opt
    
    kvec = [25 23 27 29 31 33 35];
    lvec = [1100 900 1300:200:2500];
    cormat = zeros(length(kvec),length(lvec));
    
    for i = 1:length(kvec)
        kernelWidthMax = kvec(i);
        for j = 1:length(lvec)
            lambda2 = lvec(j);
            QD_Estimate_B0(fname_f, fname_r, kernelWidthMax, lambda2);
            vol_f_B0uw = QD_load_mgh(fname_f_B0uw);
            vol_r_B0uw = QD_load_mgh(fname_r_B0uw);
            cormat(i,j) = corr(vol_f_B0uw(inds),vol_r_B0uw(inds));
            fprintf('%s -- %s.m:    Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
            if cormat(i,j) >= corrmin
                fname_out = sprintf('%s/%s_B0opt_kernelWidthMax_%g_lamda2_%g_cost_%g',fpath,fname,kernelWidthMax,lambda2,cormat(i,j));
                unix(sprintf('touch %s',fname_out));
                fprintf('%s -- %s.m:    Final Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
                corr_final = cormat(i,j);
                return
            end
        end
    end
    
    [i, j] = find(cormat==max(cormat(:)));
    kernelWidthMax = kvec(i(1));
    lambda2 = lvec(j(1));
    fname_out = sprintf('%s/%s_B0opt_kernelWidthMax_%g_lamda2_%g_cost_%g',fpath,fname,kernelWidthMax,lambda2,cormat(i,j));
    unix(sprintf('touch %s',fname_out));
    fprintf('%s -- %s.m:    Final Distortion correlation - %g.\n',datestr(now),mfilename,cormat(i,j));
    QD_Estimate_B0(fname_f, fname_r, kernelWidthMax, lambda2);
    corr_final = cormat(i,j);
    
else
    
    QD_Estimate_B0(fname_f, fname_r);
    vol_f_B0uw = QD_load_mgh(fname_f_B0uw);
    vol_r_B0uw = QD_load_mgh(fname_r_B0uw);
    fprintf('%s -- %s.m:    Distortion correlation - %g.\n',datestr(now),mfilename,corr(vol_f_B0uw(inds),vol_r_B0uw(inds)));
    corr_final = corr(vol_f_B0uw(inds),vol_r_B0uw(inds));

end

end
