function volDT = QD_Fit_Tensor(vol,qmat,bvals,numiters,volmask);
% 
% Tensor D is stored as 7-vector of form = | 1 4 5 | and 7 = log(b=0)
%                                          | 4 2 6 |
%                                          | 5 6 3 |
% 11/16/2010 - nwhite

if ~exist('numiters','var');numiters = 1;end
if ~exist('volmask','var')
    volb0 = vol(:,:,:,1);
    sig = mean(volb0(find(volb0)));
    volmask = zeros(size(volb0));
    volmask(find(volb0>.7*sig)) = 1;
end

fovmask = ones(size(vol(:,:,:,1)));
%fovmask = zeros(size(vol(:,:,:,1)));
%fovmask(find(vol(:,:,:,1)>0))=1; 
volDT.volmask = volmask.*fovmask;

[nx,ny,ns,nf] = size(vol);
if length(bvals) ~= size(qmat,1);error('bvals and qmat inconsistent lengths');end

rvec = zeros(size(qmat));
for i = 1:nf;
    tmpvec = qmat(i,:);
    rvec(i,:) = tmpvec./max(norm(tmpvec),eps);
end

% form B matrix and its inverse
B = zeros(nf,7);
B(:,7) = 1; % S0
for i = 1:nf
  outerprod = -bvals(i)*rvec(i,:)'*rvec(i,:);
  B(i,1:3) = diag(outerprod)';
  B(i,4) = 2*outerprod(1,2);
  B(i,5) = 2*outerprod(1,3);
  B(i,6) = 2*outerprod(2,3);
end
Binv = pinv(B);
newvol = vol;
volDT.D = zeros(nx,ny,ns,7);
volDT.B = B;
%DTmeas = {};
fprintf('%s -- %s.m:    Fitting tensors...\n',datestr(now),mfilename)
for iter = 1:numiters;
    for i = 1:ns
        y = reshape(newvol(:,:,i,:),[nx*ny,nf])';
        logy = log(max(1,min(repmat(y(1,:),[size(y,1),1]),y)));
        %logy = log(max(1,y));
        tmp = Binv*logy;
        volDT.D(:,:,i,:) = reshape(tmp',[nx ny 7]);
    end
    %DTmeas{iter} = QD_Calc_DTmeas(volDT);
    volSynth = QD_Synth_Diffusion_Data(volDT.D,qmat,bvals);
    volRes = ((volSynth-vol).^2).*repmat(volmask,[1 1 1 nf]);
    errvec = volRes(find(volRes));
    inds = find(volRes>(mean(errvec)+2*std(errvec)));
    newvol = vol;
    newvol(inds) = volSynth(inds);
end
fprintf('%s -- %s.m:    Finished successfully.\n',datestr(now),mfilename)

