function [x,resnorm,residual] = lsqnonneg_amd(C,d)

ncombos = 2^size(C,2)-1; nvox = size(d,2);
betamat = zeros(size(C,2),nvox,ncombos);
costmat = NaN(nvox,ncombos+1);  costmat(:,1) = sum(d.^2,1);
for comboi = 1:ncombos
  bitvec = logical(bitget(comboi,[1:size(C,2)]'));
  betahat = zeros(size(C,2),nvox);
  betahat(bitvec,:) = pinv(C(:,bitvec)) * d;
  betahat = max(0,betahat);
  costvec = sum((d-C*betahat).^2,1);
  betamat(:,:,comboi+1) = betahat;
  costmat(:,comboi+1) = costvec;
end

[mv, mi] = min(costmat,[],2);
for j = 1:size(costmat,2)
  ivec = find(mi==j);
  betahat(:,ivec) = betamat(:,ivec,j);
  costvec(ivec) = costmat(ivec,j);
end

x = betahat;
d_pred = C*x;
residual = d_pred-d;
resnorm = norm(residual);

return

ncombos = 2^size(C,2)-1; nvox = size(d,2);
betahat = zeros(size(C,2),nvox);
costvec_min = sum(d.^2,1);
for comboi = 1:ncombos
  bitvec = bitget(comboi,[1:size(C,2)]');
  betahat_tmp = betahat;
  betahat_tmp(bitvec==1,:) = C(:,bitvec==1)\d;
  costvec = sum((d-C*betahat_tmp).^2,1);
  costvec(find(min(betahat_tmp,[],1)<0)) = Inf;
  betahat(:,costvec<costvec_min) = betahat_tmp(:,costvec<costvec_min);
  costvec_min = min(costvec_min,costvec);
end

x = betahat;
d_pred = C*x;
residual = d_pred-d;
resnorm = norm(residual);

