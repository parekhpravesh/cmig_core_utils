function [M_v1_to_v2, min_cost, sf] = QD_rbreg_vol2vol_EKF(vol1, vol2, volmask, varargin)
% Multiscale Rigid body registration using EKF
%       
% [M_reg, min_cost, sf] = QD_rbreg_vol2vol_EKF(vol1, vol2, volmask, [numiters], [bdispiter], [mstep], [bsmooth])
%
% Input:
%   vol1: template vol structure
%   vol2: regsitering vol structure
%   volmask; Mask volume structure for ROI. make sure it is the same dim as vol1
%   numiters: number of iEKF iterations
%   bdispiter: show debug
%   mstep: sampling in the mask; default = 1;
%   bsmooth: smooth input volume (default=false);
%
%
% Output:
%   M_v1_to_v2: Registration matrix from Vol1 to Vol2
%   min_const:  Minimization error
%   sf:         Scaling factor for Vol1/Vol2;
%  
%  02/27/2011 - nwhite

numiters = 20;
if nargin >= 4
  numiters = varargin{1};
end

bdispiter=false;
if nargin >= 5
  bdispiter = varargin{2};
end

mstep=1;
if nargin >= 6
  mstep = varargin{3};
end

bsmooth=false;
if nargin >= 7
  bsmooth = varargin{4};
end

if (bsmooth)
  if bdispiter
    disp    'Smoothing volume...'
  end
  volf1=vol_filter(vol1, 1);
  clear vol1;
  vols1=vol_filter(volf1, 1);
  clear volf1;
  volf1=vol_filter(vol2, 1);
  clear vol2;
  vols2=vol_filter(volf1, 1);
  clear volf1;
  volsmskf1=vol_filter(volmask, 1);
  clear volmask
  volsmsk=vol_filter(volsmskf1, 1);
  clear volsmskf1
else
  vols1=vol1;
  clear vol1;
  vols2=vol2;
  clear vol2;
  volsmsk = volmask;
  clear volmask
end

ind = find(volsmsk.imgs>0);
tsize=length(ind);
inds = ind(1:mstep:tsize);
nvox = length(inds);
[I J K]=ind2sub(size(volsmsk.imgs), inds);
bvxl=ones(length(I),4);
bvxl(:,1)=I;
bvxl(:,2)=J;
bvxl(:,3)=K;
lphpos=(volsmsk.Mvxl2lph*bvxl')';
[vxlval1 inbound1]= vol_getvxlsval(lphpos, vols1, eye(4,4)); 
[vxlval2 inbound2]= vol_getvxlsval(lphpos, vols2, eye(4,4)); 
[vxlvalmsk inbound_msk]= vol_getvxlsval(lphpos, volsmsk, eye(4,4)); 

% Kalman Filter Priors
yhat = vxlval1; % predicted EKF measurements
ymeas = vxlval2; % EKF measurements
ymeas_norm = norm(ymeas);

smoothnessfactor = 1;
Q = (1/smoothnessfactor^2)*diag([1,1,1,pi/180,pi/180,pi/180].^2);
SNR = 30;
signal = sqrt(mean(ymeas.^2));
x0  = zeros(6,1);
P0  = Q;
weights = 1/smoothnessfactor*(signal/SNR)^(-2)*vxlvalmsk;
Rinv = spdiags(weights,0,nvox,nvox);

% start registration
if bdispiter
    disp    'Registering volumes...'
end

xhat = x0;Phat = P0;
np = length(xhat);
cost_prior = 1e10;
cost_change = 1;
for j = 1:numiters

    if cost_change>0.01
        
        [yhat inbound_yhat]= vol_getvxlsval(lphpos, vols1, xtoM(xhat));
        yhat_norm = norm(yhat);
        yhat_scaled = (ymeas_norm/yhat_norm)*yhat;
        cost_inn = (ymeas-yhat_scaled)'*Rinv*(ymeas-yhat_scaled)/2;
        cost_state = (x0-xhat)'*inv(P0)*(x0-xhat)/2;
        cost_total = cost_inn+cost_state;
        cost_change = (cost_prior-cost_total)/cost_prior;
        
        if bdispiter
            fprintf('iter = %d; cost_inn = %f; cost_state = %f; cost_total = %f;\n',j,cost_inn,cost_state,cost_total);
        end
        
        cost_prior = cost_total;
        
        % calculate gradient at xhat
        
        step_size = 1e-3;
        X = meshgrid(xhat)';
        xp = X + 0.5*step_size*eye(np,np);
        xn = X - 0.5*step_size*eye(np,np);
        
        H = zeros(nvox,np);
        for i = 1:np
            [yp inbound_yp] = vol_getvxlsval(lphpos, vols1, xtoM(xp(:,i)));
            [yn inbound_yn] = vol_getvxlsval(lphpos, vols1, xtoM(xn(:,i)));
            H(:,i) = (yp-yn)/step_size;
        end
        
        % view update
        if 0
            % find center slices
            [nx ny nz] = size(vols1.imgs);
            slices = round([nx/2 ny/2 nz/2]);
            
            % form gradient images
            H1 = zeros(size(vols1.imgs));H1(inds)=H(:,1);
            H2 = zeros(size(vols1.imgs));H2(inds)=H(:,2);
            H3 = zeros(size(vols1.imgs));H3(inds)=H(:,3);
            H4 = zeros(size(vols1.imgs));H4(inds)=H(:,4);
            H5 = zeros(size(vols1.imgs));H5(inds)=H(:,5);
            H6 = zeros(size(vols1.imgs));H6(inds)=H(:,6);
            
            % compute innovation image
            tmp = ymeas-yhat_scaled;
            Inn = zeros(size(vols1.imgs));Inn(inds)=tmp;
            
            % display results
            figure(1),clf
            subplot(6,3,1),imagesc(squeeze(H1(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,2),imagesc(squeeze(H1(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,3),imagesc(squeeze(H1(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,4),imagesc(squeeze(H2(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,5),imagesc(squeeze(H2(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,6),imagesc(squeeze(H2(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,7),imagesc(squeeze(H3(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,8),imagesc(squeeze(H3(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,9),imagesc(squeeze(H3(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,10),imagesc(squeeze(H4(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,11),imagesc(squeeze(H4(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,12),imagesc(squeeze(H4(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,13),imagesc(squeeze(H5(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,14),imagesc(squeeze(H5(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,15),imagesc(squeeze(H5(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,16),imagesc(squeeze(H6(:,:,slices(3))));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,17),imagesc(squeeze(H6(:,slices(2),:)));axis image,colormap(colormap_blueblackred);axis off
            subplot(6,3,18),imagesc(squeeze(H6(slices(1),:,:)));axis image,colormap(colormap_blueblackred);axis off
            figure(2),clf
            subplot(1,3,1),imagesc(squeeze(Inn(:,:,slices(3))));axis image,colormap(gray);axis off
            subplot(1,3,2),imagesc(squeeze(Inn(:,slices(2),:)));axis image,colormap(gray);axis off
            subplot(1,3,3),imagesc(squeeze(Inn(slices(1),:,:)));axis image,colormap(gray);axis off
            pause
        end
        
        H_scaled = (ymeas_norm/yhat_norm)*H;
        K = inv(H_scaled'*Rinv*H_scaled+inv(P0))*H_scaled'*Rinv;
        xhat = x0 + K*(ymeas-yhat-H_scaled*(x0-xhat));
        Phat = (eye(size(K*H_scaled)) - K*H_scaled)*P0;
        %g = -H_scaled'*Rinv*(ymeas-yhat)+inv(P0)*(xhat-x0); % gradient
        %Hess = H_scaled'*Rinv*H_scaled+inv(P0); % Hessian - should be equivalent to inv(Phat)
    
    else
        break
    end
end


M_v2_to_v1 = xtoM(xhat);
M_v1_to_v2 = inv(M_v2_to_v1);

vxlval2= vol_getvxlsval(lphpos, vols2, M_v1_to_v2);
ind=find(vxlval2>0);
sf=mean(vxlval1(ind)./ vxlval2(ind)); % need to check this
min_cost = cost_total; %check this