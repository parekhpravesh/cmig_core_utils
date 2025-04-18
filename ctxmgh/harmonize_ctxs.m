function ctx = harmonize_ctxs(ctx_source, ctx_target)

M_s = ctx_source.Mvxl2lph;
M_t = ctx_target.Mvxl2lph;

rps_s = norm(M_s(1:3,1));
cps_s = norm(M_s(1:3,2));
slcthk_s = norm(M_s(1:3,3));
rdir_s = M_s(1:3,1) / rps_s;
cdir_s = M_s(1:3,2) / cps_s;
sdir_s = M_s(1:3,3) / slcthk_s;

rps_t = norm(M_t(1:3,1));
cps_t = norm(M_t(1:3,2));
slcthk_t = norm(M_t(1:3,3));
rdir_t = M_t(1:3,1) / rps_t;
cdir_t = M_t(1:3,2) / cps_t;
sdir_t = M_t(1:3,3) / slcthk_t;

ctx = ctx_source;
M_new = M_s;
[rows, cols, slices, ~] = size(ctx.imgs);

if sign(rdir_s(1)) == -sign(rdir_t(1))
  ctx.imgs = flip(ctx.imgs, 1);
  M_new(1:3,4) = M_new(1:3,4) + (rows * rdir_s * rps_s);
  M_new(1:3,1) = -M_new(1:3,1);
  ctx.DirCol = -ctx.DirCol;
end

if sign(cdir_s(2)) == -sign(cdir_t(2))
  ctx.imgs = flip(ctx.imgs, 2);
  M_new(1:3,4) = M_new(1:3,4) + (cols * cdir_s * cps_s);
  M_new(1:3,2) = -M_new(1:3,2);
  ctx.DirRow = -ctx.DirRow;
end

if sign(sdir_s(3)) == -sign(sdir_t(3))
  ctx.imgs = flip(ctx.imgs, 3);
  M_new(1:3,4) = M_new(1:3,4) + (slices * sdir_s * slcthk_s);
  M_new(1:3,3) = -M_new(1:3,3);
  ctx.DirDep = -ctx.DirDep;
end

ctx.Mvxl2lph = M_new;
c = [rows/2 cols/2 slices/2 1]';
ctx.lphcent = ctx.Mvxl2lph * c;
ctx.lphcent = ctx.lphcent(1:3);

end
