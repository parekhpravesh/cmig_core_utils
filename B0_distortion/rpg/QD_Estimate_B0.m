function status = QD_Estimate_B0(fname_f, fname_r, kernelWidthMax, lambda2, params)

if ~exist('kernelWidthMax','var')
    kernelWidthMax = 25;
end
if ~exist('lambda2','var')
    lambda2 = 1100;
end

sys_echo = 0;
if isfield(params, 'PrintSysCalls')
  sys_echo = params.PrintSysCalls;
end

[outdir name etc] = fileparts(fname_f);
fname_f_B0uw = sprintf('%s_B0uw_exe.mgz',name);
fname_dx = sprintf('%s_B0dx_exe.mgz',name);

[path name etc] = fileparts(fname_r);
fname_r_B0uw = sprintf('%s_B0uw_exe.mgz',name);

voxel_resampling = 2; % mm
nchunksZ = 1; % Number of chunks in slice direction

if isfield(params, 'Installation') && ~isempty(regexpi(params.Installation,'docker'))
  use_docker = 1;
else
  use_docker = 0;
end

if isdeployed || use_docker
  cmd = sprintf('/bin/bash -c ''sudo docker run -v %s:%s rpg -f %s -r %s -fo %s -ro %s -do %s -kernelWidthMax %d -lambda2 %d -od %s -xs %d -ys %d -zs %d -resample -nchunksZ %u''', outdir, outdir, fname_f,fname_r,fname_f_B0uw,fname_r_B0uw,fname_dx,kernelWidthMax,lambda2,outdir,voxel_resampling,voxel_resampling,voxel_resampling,nchunksZ); 
else
  cmd = sprintf('/bin/bash -c ''epic -f %s -r %s -fo %s -ro %s -do %s -kernelWidthMax %d -lambda2 %d -od %s -xs %d -ys %d -zs %d -resample -nchunksZ %u''',fname_f,fname_r,fname_f_B0uw,fname_r_B0uw,fname_dx,kernelWidthMax,lambda2,outdir,voxel_resampling,voxel_resampling,voxel_resampling,nchunksZ);
end  
fprintf('%s\n', cmd);

fprintf('%s -- %s.m:    Estimating distortions...\n',datestr(now),mfilename);
if sys_echo
  status = system(cmd, '-echo');
else
  status = system(cmd);
end

if isdeployed || use_docker
  cmd2 = sprintf('/bin/bash -c ''sudo chmod o=rw %s/*''', outdir);
  if sys_echo
    status = system(cmd2, '-echo');
  else
    status = system(cmd2);
  end
end

if status ~= 0 
  fprintf('Error in %s -- %s',mfilename,result); 
  return
end

end
