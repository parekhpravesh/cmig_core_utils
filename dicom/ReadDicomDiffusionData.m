function [vol, Mvxl2ras, qmat, bvals, gwinfo, info] = ReadDicomDiffusionData(indir,ignoreGradInfo,varargin)
% ReadDicomDiffusionData  Read DICOM diffusion data

if ~exist('ignoreGradInfo','var')
    ignoreGradInfo = false;
end

if iscell(indir)
    file_list = indir;
else
    file_list = recursive_dir(indir);
end

epi2 = 1; % vs some research (or product) acquisition with a different pulse sequence
          % Defaults to epi2

totfiles = length(file_list);
fnames = {};
instancenumber = [];
slicelocation = [];
qmat = [];
bvals = [];
iter = 1;
fprintf('%s -- %s.m:    Reading DICOM headers...',datestr(now),mfilename);
for i = 1:totfiles
    fname = char(file_list(i));
    try
        info = dicominfo(fname);
	info = fix_impax_dcm_tags(info);
	if ~isfield(info, 'Private_0019_109c')
	  epi2 = 0;
	elseif isfield(info, 'Private_0019_109c') && strcmp(info.Private_0019_109c, 'epi2') ~= 1
	  epi2 = 0;
	end

        instancenumber(iter) = info.InstanceNumber;
	slicelocation(iter) = info.SliceLocation;
	
        if ~ignoreGradInfo

	  if isfield(info, 'Private_0019_10bb')
	    diff_dir_x = info.Private_0019_10bb;
	    diff_dir_y = info.Private_0019_10bc;
	    diff_dir_z = info.Private_0019_10bd;
	  elseif isfield(info, 'DiffusionDirectionX')
	    diff_dir_x = info.DiffusionDirectionX;
	    diff_dir_y = info.DiffusionDirectionY;
	    diff_dir_z = info.DiffusionDirectionZ;
	  else
	    diff_dir_x = NaN;
	    diff_dir_y = NaN;
	    diff_dir_z = NaN;
	  end

	  if strcmp(class(info.Private_0043_1039), 'char') == 1
	     bval_num = str2num(info.Private_0043_1039);
	     bvals = [bvals; bval_num(1)];
	     qvecs = [diff_dir_x diff_dir_y diff_dir_z];
	     qmat = [qmat; qvecs];

	  elseif epi2 == 1
            bval_string = num2str(info.Private_0043_1039(1));
	    if length(bval_string)>5
	      bval_string = bval_string(2:end);
	      indx = regexp(bval_string, '[1-9]0*');
	      if ~isempty(indx)
		bval_string = bval_string(indx:end);
	      else
		bval_string = '0';
	      end
	    end
	    bval = str2double(bval_string);
	    bvals = [bvals; bval];
	    qvecs = [diff_dir_x diff_dir_y diff_dir_z];
	    qmat = [qmat; qvecs];

	  else
	     bval = info.Private_0043_1039(1);
	     if bval >= 1000
		bval = round(bval, -2);
	     end
	     bvals = [bvals; bval];
	     qvecs = [diff_dir_x diff_dir_y diff_dir_z];
	     qmat = [qmat; qvecs];
	  end

        end
        fnames{iter} = fname;
        iter = iter+1;
    catch ME
        warning(sprintf('%s - %s\n',ME.message,fname))
        continue
    end
end
fprintf('\n');

if isempty(fnames);error('%s - Cant find any DICOM files in %s\n',mfilename,indir);end
fprintf('%s -- %s.m:    Loading DICOMs...\n',datestr(now),mfilename);

[tmp,sortindx] = sort(instancenumber);
if ~ignoreGradInfo
    qmat_sort = qmat(sortindx,:);
    bvals_sort = bvals(sortindx);
end

nr = info.Rows;
nc = info.Columns;

if isfield(info, 'Private_0021_104f')
  ns = info.Private_0021_104f;
else
  slicelocation = unique(slicelocation);
  ns = length(slicelocation);
end

if length(ns) > 1
    fprintf('Warning: Expecting single integer value for private tag 0021_104f\n');
    fprintf('Warning: Using first index for number of slices = %d\n',ns(1));
    ns = double(ns(1));
end

nreps = info.ImagesInAcquisition/ns;

% TODO: Cross reference with QD_Read_DICOM_3D_Directory gwinfo calculation 
% make sure isocenter flag is computed properly

[gwinfo,errmsg] = mmil_get_gradwarpinfo(info);
% if isfield(gwinfo, 'ambiguousgwtype')
%     if gwinfo.ambiguousgwtype == 1
%         gwinfo.gwtype = ctx_get_gwtype(vol, 'isoctrflag', gwinfo.isoctrflag, 'gwtypelist', [2 3 7 8]);
%     end
% end

if ~ignoreGradInfo
    qmat = qmat_sort(1:ns:end,:); % single diffusion direction per volume is standard.
    bvals = bvals_sort(1:ns:end);   % single b-value per volume as well.
end

if isempty(varargin)
    [vol,Mvxl2ras] = read_dicom_4dvol(fnames(sortindx),nr,nc,ns,nreps); % based on read_dicomvol.m
else
    nr = varargin{1}(1);
    nc = varargin{1}(2);
    ns = varargin{1}(3);
    nreps = varargin{1}(4);
    
    [vol,Mvxl2ras] = read_dicom_4dvol(fnames(sortindx),nr,nc,ns,nreps); % based on read_dicomvol.m
end
 


end
