function PrintErrorStruct(varargin)

for MEi = 1:length(varargin)
  if length(varargin)>1
    fprintf(1,'\nErrorStruct #%d\n',MEi);
  end
  ME = varargin{MEi};
%  disp(getReport(ME))
  disp(ME.message)
  for li = 1:length(ME.stack)
    fprintf(1,'file: %s line: %d\n',ME.stack(li).file,ME.stack(li).line)
  end
end

