function write_dicom_seg(seg_fields, path_output, path_venv)

if ~exist(path_output, 'dir')
  mkdir(path_output);
end

fname_seg_fields = fullfile(path_output, 'fields.mat');
save(fname_seg_fields, 'seg_fields');

py_script = which('create_dicom_seg.py');
cmd = [path_venv '/bin/python3 ' py_script ' ' fname_seg_fields ' ' path_output];
fprintf('%s\n', cmd);
system(cmd);

delete(fname_seg_fields);

end
