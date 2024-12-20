function [dce_data, t] = load_dce_data(path_dce_dir)

files = dir(path_dce_dir);
dcminfo = dicominfo( fullfile(files(end).folder, files(end).name) );

rows = double(dcminfo.Rows);
cols = double(dcminfo.Columns);
frames = double(dcminfo.NumberOfTemporalPositions) + 1;
slices = (length(files)-2) ./ frames;

files_by_vol(frames,1).fnames = {};
t = NaN(length(files)-2, 1);
for i = 3:length(files)
  fname = fullfile(files(i).folder, files(i).name);
  dcminfo = dicominfo(fname);
  if ~isfield(dcminfo, 'TemporalPositionIdentifier')
    files_by_vol(1,1).fnames = cat(2, files_by_vol(1,1).fnames, {fname});
    t(i-2) = 0;
  else
    indx = double(dcminfo.TemporalPositionIdentifier) + 1;
    files_by_vol(indx,1).fnames = cat(2, files_by_vol(indx,1).fnames, {fname});
    t(i-2) = dcminfo.TriggerTime;
  end
end

vol4d = zeros(rows, cols, slices, frames);
for i = 1:length(files_by_vol)
  [vol, M] = QD_read_dicomvol(files_by_vol(i).fnames);
  vol4d(:,:,:,i) = vol;
end
dce_data = mgh2ctx(vol4d, M);

t = sort(t);
t = t(1:slices:end);

end
