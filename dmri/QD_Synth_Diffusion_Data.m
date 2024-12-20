function volSynth = QD_Synth_Diffusion_Data(volDT,qmat,bvals)
%

[nx,ny,nz] = deal(size(volDT,1),size(volDT,2),size(volDT,3));
nf = size(qmat,1);

rvec = zeros(size(qmat));
for i = 1:nf;
    tmpvec = qmat(i,:);
    rvec(i,:) = tmpvec./max(norm(tmpvec),eps);
end

B = zeros(nf,7);
B(:,7) = 1; % S0
for i = 1:nf
  outerprod = -bvals(i)*rvec(i,:)'*rvec(i,:);
  B(i,1:3) = diag(outerprod)';
  B(i,4) = 2*outerprod(1,2);
  B(i,5) = 2*outerprod(1,3);
  B(i,6) = 2*outerprod(2,3);
end

volSynth = zeros(nx,ny,nz,nf);
Dmat = zeros(nx*ny,7);
for i = 1:nz
    T = reshape(volDT(:,:,i,:),[nx*ny,7])';
    tmp_mat = exp(B*T);
    volSynth(:,:,i,:) = reshape(tmp_mat',[nx ny nf]);
end
