function out=k2im(im)
    inv_thr=ifftshift(im);
    inv_thr=ifft2(inv_thr);
    out=abs(inv_thr);
end
