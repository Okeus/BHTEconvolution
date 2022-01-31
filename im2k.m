function out=im2k(im)
    out=fftshift(fft2(im));
end