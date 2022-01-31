%This program simulates HIFU heating using convolution of the Gaussian heat
%kernel

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

acoustic_power= Pa;
max_acoustic_power = 3.671*100-40.01;

%dc=0.05; %MR-ARFI
dc=0.90; %MRT
th=33; %heating time.  dynamics * time step.
tc=35; %cooling timme. dynamics * time step.
nsh=1; %number of shots
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

%alpa=0.154; %Np/m for water.
%alpa=1.61*1E-3; % need units Np.mm-1.  %attenuation absorption coefficient.
alpa=1.1E-3; % need units Np.mm-1.  %attenuation absorption coefficient.

% if exist('intensity3d','var') == 0
%     load('matrice3D_intensity.mat');
% end
% int4d=intensity3d(42:end-39,42:end-39,211-31:31:211+31); %get region corresponding to simulation size.

% load('int4d.mat');
% int4d=int4d(:,:,2); %use only 2d convolution
v=load('intensity_deconvolution.mat');
int4d=v.var;
phio=2*dc*(amp)*alpa*int4d; %converts intensity to heat. Q/mm3

% amax=max(int4d,[],'all')
% bmax=max(phio,[],'all')
% pause

%phio=2*dc*(acoustic_power)*alpa*int4d/max(int4d(:)); %converts intensity to heat. Q/mm3
T(:,:,1)=zeros([xx yy]);
tcf=0; %temperature at end of cooling.  initialized at zero.

%convolution of wave and volumentric heat field during heating.
%convolution of temperature field with wave, during cooling
tall(G2);tall(phio);tall(T);
for u=1:nsh
    idx=(u-1)*(th+tc)
    for n=idx+1:idx+th-1
        T(:,:,n+1)=tcf+(n-idx)*dt*conv2(G2(:,:,n-idx),phio,'same');
        %T(:,:,n+1)=tcf+(n-idx)*dt*conv2(G2(:,:,n-idx),phio,'same')+conv2(G2(:,:,2)-G2(:,:,1),T(:,:,n-idx),'same');
    end
    T(:,:,idx+th+1:idx+th+tc+1)=convn(G2(:,:,1:tc+1),T(:,:,th+idx),'same');
    tcf=T(:,:,idx+th+tc+1);
end
gather(G2);gather(phio);gather(T);

XXX=(0:tt);
size(XXX)
size(T)
%make_fp_plot(XXX,T)
%make_intTemp_plot(XXX,T)
make_fp_tint_plot(XXX,T)
%make_convolution_video(T,dt)

[x,y,t]=size(T);
amax=max(T,[],'all')
figure
for u=1:t
    h = pcolor(T(:,:,u));
    set(h, 'EdgeColor', 'none');
    hc=colorbar; 
    title(hc,'T,°C');
    caxis([0 amax]);
    pause(.05)
end
save('conv_temp.mat','T')



toc