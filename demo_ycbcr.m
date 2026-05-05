clc
clear
close all
disp("running...")

%% Load image
Img_rgb = imread("USC_SIPI_Color/512/001.tiff");

Img_ycbcr = rgb2ycbcr(Img_rgb);

c1 = Img_ycbcr(:,:,1);
c2 = Img_ycbcr(:,:,2);
c3 = Img_ycbcr(:,:,3);

Messlength = 128; 
num_n = 5000;
QS = 26;

%% Embed
[Maxorder,capacity] = getMaxorder(Messlength);
[plate1,rho,theta] = meshplate(c1);
[plate2,~,~] = meshplate(c2);
[plate3,~,~] = meshplate(c3);

Pnm_1 = PHFM_De(plate1,rho,theta,Maxorder);
Pnm_2 = PHFM_De(plate2,rho,theta,Maxorder);
Pnm_3 = PHFM_De(plate3,rho,theta,Maxorder);

[Pnm_e1,Pnm_e2,Pnm_e3,watermark,dq] = CoreEmbed_3Channel...
    (Pnm_1,Pnm_2,Pnm_3,Maxorder,Messlength,num_n,QS);

% C1 embed
Pnm_diff_1 = Pnm_e1 - Pnm_1;
fxy_diff_1 = PHFM_Re(Pnm_diff_1,plate1,rho,theta,Maxorder);
[fxy_diff_1,~,~] = meshplate(fxy_diff_1);
temp = double(c1)+real(fxy_diff_1);
c1_e = uint8(temp);

% C2 embed
Pnm_diff_2 = Pnm_e2 - Pnm_2;
fxy_diff_2 = PHFM_Re(Pnm_diff_2,plate2,rho,theta,Maxorder);
[fxy_diff_2,~,~] = meshplate(fxy_diff_2);
temp = double(c2)+real(fxy_diff_2);
c2_e = uint8(temp);
% C3 embed
Pnm_diff_3 = Pnm_e3 - Pnm_3;
fxy_diff_3 = PHFM_Re(Pnm_diff_3,plate3,rho,theta,Maxorder);
[fxy_diff_3,~,~] = meshplate(fxy_diff_3);
temp = double(c3)+real(fxy_diff_3);
c3_e = uint8(temp);

Img_ycbcr_e(:,:,1) = c1_e;
Img_ycbcr_e(:,:,2) = c2_e;
Img_ycbcr_e(:,:,3) = c3_e;
Img_rgb_e = ycbcr2rgb(Img_ycbcr_e);

%%
PSNR = psnr(Img_rgb_e,Img_rgb)
figure
imshow(Img_rgb_e)

%% Extract
Img_rgb_w = Img_rgb_e;
Img_ycbcr_w = rgb2ycbcr(Img_rgb_w);
c1_w = Img_ycbcr_w(:,:,1);
c2_w = Img_ycbcr_w(:,:,2);
c3_w = Img_ycbcr_w(:,:,3);

[plate1_w,rho,theta] = meshplate(c1_w);
[plate2_w,~,~] = meshplate(c2_w);
[plate3_w,~,~] = meshplate(c3_w);

Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);

[Pnm_wr1,Pnm_wr2,Pnm_wr3,watermark_ex] = CoreExtract_3Channel( ...
    Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS,dq);

BER = sum(abs(watermark_ex-watermark)/Messlength);

%%
Pnm_diff_wr_1 = Pnm_1_w - Pnm_wr1;
fxy_diff_wr_1 = PHFM_Re(Pnm_diff_wr_1,plate1,rho,theta,Maxorder);
[fxy_diff_wr_1,~,~] = meshplate(fxy_diff_wr_1);
temp = double(c1_w)-real(fxy_diff_wr_1);
c1_wr = uint8(temp);

Pnm_diff_wr_2 = Pnm_2_w - Pnm_wr2;
fxy_diff_wr_2 = PHFM_Re(Pnm_diff_wr_2,plate2,rho,theta,Maxorder);
[fxy_diff_wr_2,~,~] = meshplate(fxy_diff_wr_2);
temp = double(c2_w)-real(fxy_diff_wr_2);
c2_wr = uint8(temp);

Pnm_diff_wr_3 = Pnm_3_w - Pnm_wr3;
fxy_diff_wr_3 = PHFM_Re(Pnm_diff_wr_3,plate3,rho,theta,Maxorder);
[fxy_diff_wr_3,~,~] = meshplate(fxy_diff_wr_3);
temp = double(c3_w)-real(fxy_diff_wr_3);
c3_wr = uint8(temp);

Img_ycbcr_wr(:,:,1) = c1_wr;
Img_ycbcr_wr(:,:,2) = c2_wr;
Img_ycbcr_wr(:,:,3) = c3_wr;

figure
subplot(121)
imshow(Img_ycbcr_w)
subplot(122)
imshow(Img_ycbcr_wr)

figure
subplot(121)
imshow(ycbcr2rgb(Img_ycbcr_w))
subplot(122)
imshow(ycbcr2rgb(Img_ycbcr_wr))

dr = Img_ycbcr - Img_ycbcr_wr;
dr1 = dr(:,:,1);
dr2 = dr(:,:,2);
dr3 = dr(:,:,3);

figure
subplot(131)
imshow(dr1*50)
subplot(132)
imshow(dr2*50)
subplot(133)
imshow(dr3*50)
