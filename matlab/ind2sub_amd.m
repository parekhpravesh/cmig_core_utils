function submat = ind2sub_amd(siz,ndx)

siz = double(siz);
n = length(siz);
submat = zeros(length(ndx),n);

k = [1 cumprod(siz(1:end-1))];
for i = n:-1:1,
  vi = rem(ndx-1, k(i)) + 1;         
  vj = (ndx - vi)/k(i) + 1; 
  submat(:,i) = vj; 
  ndx = vi;     
end
