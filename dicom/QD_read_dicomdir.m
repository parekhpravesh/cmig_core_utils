function vol = QD_read_dicomdir(dirname, fmt, rescale_flag)

if ~exist('fmt','var')
  fmt = '';
end

if ~exist('rescale_flag', 'var')
   rescale_flag = 1;
end

if ~isempty(fmt)
  flist = dir(sprintf('%s/%s',dirname,fmt));
else
  flist = dir(sprintf('%s/',dirname));
  flist = flist(3:end);
end
fnames = strcat(sprintf('%s/',dirname),{flist.name}');
nfiles = length(fnames);

slocvec = NaN(1,nfiles);
for fi = 1:length(fnames)
  hdr = dicominfo(fnames{fi});
  if isfield(hdr,'SliceLocation')
    slocvec(fi) = hdr.SliceLocation;
  end
end

if isfinite(sum(slocvec)) && ~issorted(slocvec)
  [sc si] = sort(slocvec,'ascend');
  fnames = fnames(si);
end

[vol,M] = QD_read_dicomvol(fnames, rescale_flag);

vol = ctx_mgh2ctx(vol,M);

