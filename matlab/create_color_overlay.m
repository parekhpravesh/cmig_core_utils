function vol_blend = create_color_overlay(vol_overlay, vol_underlay, crange, cmap, volmask, sig, alpha)
% 
%   Create a colorized image overlay.
%
%   Args:
%       vol_overlay: ctx volume that is to be colorized
%       vol_underlay: ctx volume for a grayscale background/underlay
%       crange: a length-2 vector containing the min and max values for
%           create the overlay. vol_overlay values less than the minimum
%           will show background; vol_overlay values greater than the
%           maximum will show the highest color in your colormap
%       cmap: a string for setting the colormap. Available values are
%           listed here: https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-6
%       volmask: binary ctx volume. The overlay is multiplied by the mask,
%           so areas where volmask.imgs == 0 will show background.
%       sig: ???
%       alpha: transparency value, floating point number 0...1
% 

% Set defaults
if ~exist('crange', 'var')
  crange = [min(vol_overlay.imgs(:)) max(vol_overlay.imgs(:))];
end
if ~exist('cmap', 'var')
  cmap = 'hot';
end
if ~exist('volmask', 'var')
  volmask = [];
end
if ~exist('sig', 'var')
  sig = [];
end
if ~exist('alpha', 'var')
  alpha = 1.0;
end


fprintf('Fusing data...\n');
vmin = crange(1);
vmax = crange(2);


colorMap = colormap(cmap); close
if strmatch(cmap,'fire'); colorMap = colorMap(1:58,:); end % remove white hot
if strmatch(cmap,'jet'); colorMap(1,:)=[0 0 0]; end % remove white hot

vvec = linspace(vmin, vmax, size(colorMap,1)); % fixed scale
vol_overlay_rgb = cat(4,interp1(vvec, colorMap(:,1), min(vmax,max(vmin,vol_overlay.imgs)),'nearest'),...
                        interp1(vvec, colorMap(:,2), min(vmax,max(vmin,vol_overlay.imgs)),'nearest'),...
                        interp1(vvec, colorMap(:,3), min(vmax,max(vmin,vol_overlay.imgs)),'nearest'));

vol_overlay_rgb = cat(4, min(1, max(0, vol_overlay_rgb(:,:,:,1))),...
			 min(1, max(0, vol_overlay_rgb(:,:,:,2))),...
                         min(1, max(0, vol_overlay_rgb(:,:,:,3))));

if size(vol_underlay.imgs, 4) == 3 % Already a color volume
  vol_underlay_rgb = vol_underlay.imgs;
else
  if isempty(sig)
    sig = mean(vol_underlay.imgs(find(vol_underlay.imgs)));
    sig = mean(vol_underlay.imgs(find(vol_underlay.imgs>2*sig)));
  end
  vol_underlay_rgb = cat(4, max(0, min(1, vol_underlay.imgs/sig)), max(0, min(1, vol_underlay.imgs/sig)), max(0, min(1, vol_underlay.imgs/sig)));
end

cell_overlay = zeros(size(vol_overlay_rgb));
f = sqrt(sum(vol_overlay_rgb.^2,4));

if max(f(:)) > 0
    f = alpha * max(0, min(1, f/max(f(:))));
    for i = 1:size(vol_underlay.imgs,3)
        im1 = squeeze(vol_underlay_rgb(:,:,i,:));
        if ~isempty(volmask)
            im0 = volmask.imgs(:,:,i); 
            im2 = squeeze(vol_overlay_rgb(:,:,i,:)) .* repmat(im0,[1 1 3]);
            t = repmat(f(:,:,i), [1 1 3]) .* repmat(im0,[1 1 3]);
        else
            im2 = squeeze(vol_overlay_rgb(:,:,i,:));
            t = repmat(f(:,:,i), [1 1 3]);
        end
        cell_overlay(:,:,i,:) = max(0,min(1.0,(1-t).*im1 + t.*im2));
    end

    vol_blend = vol_overlay;
    vol_blend.imgs = cell_overlay;
else
    vol_blend = vol_overlay;
    vol_blend.imgs = vol_underlay_rgb;
end

end
