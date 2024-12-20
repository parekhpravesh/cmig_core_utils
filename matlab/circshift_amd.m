function y = noncircshift(x,k,dim)

if ~exist('dim','var'), dim = min(find(size(x)>1)); dim = condexp(isempty(dim),1,dim); end 

if k==0
  y = x;
  return;
end

dims_x = size(x);
permvec = [dim setdiff([1:length(dims_x)],dim)];
x_tmp = permute(x,permvec);
dims_tmp = size(x_tmp);
x_tmp = reshape(x_tmp,[dims_tmp(1) prod(dims_tmp(2:end))]);
y_tmp0 = circshift(x_tmp,floor(k));
y_tmp1 = circshift(x_tmp,floor(k)+1);

kf = k-floor(k);
y_tmp = (1-kf)*y_tmp0 + kf.*y_tmp1;

y_tmp = reshape(y_tmp,dims_x);
y = ipermute(y_tmp,permvec);

