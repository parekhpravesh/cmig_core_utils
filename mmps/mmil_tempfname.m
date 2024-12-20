function [tempfname] = mmil_tempfname(prefix,outdir)
% function [tempfname] = mmil_tempfname(prefix,outdir)
%
% Optional Input:
%   prefix: prefix of new temp filename
%   outdir: preferred output location
%
% Output:
%   tempfname: Unique temp filename
%
% Created:                09/05/17 by Feng Xue
% Prev Mod:               03/28/18 by Feng Xue
% Last Mod:               09/30/20 by Don Hagler
%

  [~,tmp_stem,~] = fileparts(tempname);

%  rand('twister',sum(100*clock));
%% NOTE: twister is deprecated in later versions
%%       but RandStream not found for 2007
  stream = RandStream.create('mt19937ar','Seed',sum(100*clock));
%  RandStream.setDefaultStream(stream);
  RandStream.setGlobalStream(stream);
  if exist('prefix','var') && ~isempty(prefix)
    tmp_stem = [prefix '_' tmp_stem '_' num2str(round(rand(1)*10000000))];
  else
    tmp_stem = [tmp_stem '_' num2str(round(rand(1)*10000000))];
  end

  if ~exist('outdir','var') || isempty(outdir)
    tmpdir = getenv('SCRATCHROOT');
    if isempty(tmpdir), tmpdir = '/scratch'; end;
    if ~exist(tmpdir,'dir'), tmpdir = '/tmp'; end;
  else
    tmpdir = outdir;
  end
  if strcmp(tmpdir,'./'), tmpdir = pwd; end;

  % test if we can write to output directory
  tmpfile = [tmpdir '/' tmp_stem]; 
  fid = fopen(tmpfile,'wt');
  if fid>0 % can write to this directory
    delete(tmpfile);
    fclose(fid);
  else
    tmpdir = '/tmp';
%    tmpdir = '.';
  end;
  if ~exist(tmpdir,'dir')
    error('tmpdir %s not found',tmpdir);
  end;

  tempfname = regexprep(sprintf('%s/%s',tmpdir,tmp_stem),'//','/');
return;
