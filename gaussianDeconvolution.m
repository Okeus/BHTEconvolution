%This program uses deconvolution to solve for the intensity field from MRT
%measurements

%Transducer Percent Power and Acoustic Power
%15%,19.2 W
%20%,32.3 W
%25,48.1 W
%30,67.4 W (~2.7 MPa Ppk-pk)
%35,88.7 W
%40,110 W

%Regression of values above.
%Acoustic Power (Watts) = 3.671*Amplitude-40.01;
%Maximum acoustic power = 327 W.

clear all; clf; close all;
opengl software
tic

dt=1;

%The coordinates must be odd so the focal falls at an actual central
%coordinate.  Otherwise, the point will shift position.
xx=128;
yy=128;
zz=5;

dx=.001;dy=.001;dz=.005;
cx=64;cy=64;
amp=25;
Pa=48;
rho=1050; %density
ct=3617	; %specific heat of blood
alpa=1.6E-3; % need units Np.mm-1.  %attenuation absorption coefficient.

acoustic_power= Pa;
max_acoustic_power = 3.671*100-40.01;

%dc=0.05; %MR-ARFI
dc=0.90; %MRT
th=33; %heating time.  dynamics * time step.
tc=95; %cooling timme. dynamics * time step.
nsh=3; %number of shots
Tb=0;
tt=nsh*(th+tc); %total time
T=Tb*ones(xx,yy,tt,'double'); %initialize temperature matrix
X=.358; %Thermal diffusivity. E-6. units mm.
G2=zeros(size(T)); %initial Gaussian kernel.
%fill the kernel.
for rt=1:(th+tc)
    disp(rt)
    for i=1:xx
        for j=1:yy
            ww=(1/(4*pi*X*dt*rt))*exp(-((i-cx)*(i-cx)+(j-cy)*(j-cy))/(4*X*dt*rt));
            G2(i,j,rt)=ww;
        end
    end
%     imagesc(G2(:,:,rt))
%     amax=max(G2(:,:,rt),[],'all');
%     title(num2str(amax))
%     caxis([0 (1/(4*pi*X*dt*rt))]);
%     pause
end

%Load temperature field values form MRT measurements.
var=load('MRgHIFU_20210729_2_MRI_Temperature.mat');
T=var.temp_PRF;
T=T(:,:,15:end);

%Load temperature from convolution simulation and try to obtain the same
%intensity field as in the input file.
% var=load('conv_temp.mat');
% T=var.T;

[x,y,t]=size(T);

% for u=1:t
%     figure
%     subplot(2,2,1)
%     imagesc(T(:,:,2,u))
%     pause
% end

%Inverse Filtering Deconvolution
% figure('Position',[30 30 800 800])
% for u=2:t
%     %phio_deconv=k2im(im2k((T(:,:,u)-T(:,:,u-1))/(dt))./im2k(G2(:,:,u)-G2(:,:,u-1))); 
%     %phio_deconv=k2im(im2k((T(:,:,2,u)-T(:,:,2,1))/(u*dt))./im2k(G2(:,:,u)-G2(:,:,1))); 
%     %phio_deconv=k2im(im2k((T(:,:,u)-T(:,:,1))/(u*dt))./im2k(G2(:,:,u)-G2(:,:,1))); 
%     %phio_deconv=abs(fftshift(ifft2(abs(fft2(T(:,:,u)/((u-1)*dt)))./abs(fftshift(fft2(G2(:,:,(u-1)))))))); 
%     phio_deconv=abs(fftshift(ifft2(abs(fft2((T(:,:,u)-T(:,:,(u-1)))/(dt)))./abs(fftshift(fft2(G2(:,:,(1)))))))); 
%     intensity_field(:,:,u-1)=phio_deconv/(2*dc*amp*alpa);
%     %imagesc(intensity_field)
%     subplot(2,2,1)
%     title('FFT(T)')
%     imagesc(abs(ifft2(fft2(T(:,:,u)/((u-1)*dt)))));
%     subplot(2,2,2)
%     title('FFT(kernel)')
%     imagesc(abs(ifft2(fft2(G2(:,:,(u-1))))));
%     subplot(2,2,3)
%     title('abs(intensity)')
%     imagesc(abs(phio_deconv))
%     subplot(2,2,4)
%     title('FFT(intensity)')
%     imagesc(intensity_field(:,:,u-1))
%     pause()
% end

% phio_deconv=abs(fftshift(ifft2(abs(fft2((T(:,:,2)-T(:,:,(1)))/(dt)))./abs(fftshift(fft2(G2(:,:,(1)))))))); 
% intensity_field=phio_deconv;
% intensity_field(isnan(intensity_field))=0;
% save('deconv_int','intensity_field')
% 
% amax=max(intensity_field,[],'all')
% figure
% h = pcolor(intensity_field);
% set(h, 'EdgeColor', 'none');
% hc=colorbar; 
% title(hc,'I,W/mm2');
% caxis([0 amax]);
% pause()

%Info From:
%EE 367 / CS 448I Computational Imaging and Display
%Notes: Image Deconvolution (lecture 6)
%Gordon Wetzstein

%Weiner Deconvolution, this one works on the first iteration.....
%compare to the max values from the intensity field used in the initial
%calcualtion.

% load('int4d.mat');
% int4d=int4d(:,:,2); %use only 2d convolution
% phio=2*dc*(amp)*alpa*int4d; %converts intensity to heat. Q/mm3
% amax=max(int4d,[],'all')
% bmax=max(phio,[],'all')
% pause

figure('Position',[30 30 800 800])
snr=100000;
for u=2:t
    term1=fft2(T(:,:,u)/((u-1)*dt))./fft2(G2(:,:,(u-1)));
    term2=abs(fft2(G2(:,:,(u-1))).*fft2(G2(:,:,(u-1)))).^(2);
    term3=term2./(term2+1/snr);

%     term1=abs(fft2((T(:,:,u)-T(:,:,u-1))/(dt))./fft2(G2(:,:,(u-1))));
%     term2=abs(fft2(G2(:,:,(u-1))).*fft2(G2(:,:,(u-1)))).^(2);
%     term3=term2./(term2+1/snr);

    phio_deconv=abs(fftshift(ifft2(abs(term3.*term1)))); 
    intensity_field(:,:,u-1)=phio_deconv/(2*dc*amp*alpa);
    
    amax=max(phio_deconv,[],'all')
    bmax=max(intensity_field(:,:,u-1),[],'all')
    
    title('Intensity field')
    imagesc(abs(intensity_field(:,:,u-1)))
    pause(.01)
end

var=intensity_field(:,:,2);
%
save('intensity_deconvolution','var')

toc