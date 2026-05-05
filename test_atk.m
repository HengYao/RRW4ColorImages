clc
clear
close all
disp("running...")

%%
Messlength = 128; 
num_n = 2000;
QS = 16;

Img_rgb = imread("USC_SIPI_Color/512/001.tiff");

c1 = Img_rgb(:,:,1);
c2 = Img_rgb(:,:,2);
c3 = Img_rgb(:,:,3);

[Maxorder,capacity] = getMaxorder(Messlength);
[plate1,rho,theta] = meshplate(c1);
[plate2,~,~] = meshplate(c2);
[plate3,~,~] = meshplate(c3);

Pnm_1 = PHFM_De(plate1,rho,theta,Maxorder);
Pnm_2 = PHFM_De(plate2,rho,theta,Maxorder);
Pnm_3 = PHFM_De(plate3,rho,theta,Maxorder);

[Pnm_e1,Pnm_e2,Pnm_e3,watermark] = CoreEmbed_3Channel...
    (Pnm_1,Pnm_2,Pnm_3,Maxorder,Messlength,num_n,QS);

Pnm_diff_1 = Pnm_e1 - Pnm_1;
fxy_diff_1 = PHFM_Re(Pnm_diff_1,plate1,rho,theta,Maxorder);
[fxy_diff_1,~,~] = meshplate(fxy_diff_1);
temp = double(c1)+real(fxy_diff_1);
c1_e = uint8(temp);

Pnm_diff_2 = Pnm_e2 - Pnm_2;
fxy_diff_2 = PHFM_Re(Pnm_diff_2,plate2,rho,theta,Maxorder);
[fxy_diff_2,~,~] = meshplate(fxy_diff_2);
temp = double(c2)+real(fxy_diff_2);
c2_e = uint8(temp);

Pnm_diff_3 = Pnm_e3 - Pnm_3;
fxy_diff_3 = PHFM_Re(Pnm_diff_3,plate3,rho,theta,Maxorder);
[fxy_diff_3,~,~] = meshplate(fxy_diff_3);
temp = double(c3)+real(fxy_diff_3);
c3_e = uint8(temp);

Img_rgb_e(:,:,1) = c1_e;
Img_rgb_e(:,:,2) = c2_e;
Img_rgb_e(:,:,3) = c3_e;

%% no atk test
% PSNR = psnr(Img_rgb_e,Img_rgb)
% figure
% imshow(Img_rgb_e)

% Img_rgb_w = Img_rgb_e;
% c1_w = Img_rgb_w(:,:,1);
% c2_w = Img_rgb_w(:,:,2);
% c3_w = Img_rgb_w(:,:,3);
% 
% [plate1_w,rho,theta] = meshplate(c1_w);
% [plate2_w,~,~] = meshplate(c2_w);
% [plate3_w,~,~] = meshplate(c3_w);
% 
% Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
% Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
% Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
% 
% watermark_ex = CoreExtract_3Channel...
%     (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
% 
% BER = sum(abs(watermark_ex-watermark)/Messlength);

%% atk test
% rotation
% atk_r = [10, 20, 30, 40, 50, 60, 70, 80, 90];
% for i=1:length(atk_r)
%     Img_rgb_e_r = imrotate(Img_rgb_e,atk_r(i),"bilinear","crop");
%     c1_w = Img_rgb_e_r(:,:,1);
%     c2_w = Img_rgb_e_r(:,:,2);
%     c3_w = Img_rgb_e_r(:,:,3);
%     [plate1_w,rho,theta] = meshplate(c1_w);
%     [plate2_w,~,~] = meshplate(c2_w);
%     [plate3_w,~,~] = meshplate(c3_w);
%     Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
%     Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
%     Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
%     watermark_ex_atk_r = CoreExtract_3Channel...
%         (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
%     BER_atk_r(i) = sum(abs(watermark_ex_atk_r-watermark)/Messlength);
% end

% sacling
% atk_s = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0];
% for i=1:length(atk_s)
%     Img_rgb_e_s = imresize(Img_rgb_e,atk_s(i),"bilinear");
%     c1_w = Img_rgb_e_s(:,:,1);
%     c2_w = Img_rgb_e_s(:,:,2);
%     c3_w = Img_rgb_e_s(:,:,3);
%     [plate1_w,rho,theta] = meshplate(c1_w);
%     [plate2_w,~,~] = meshplate(c2_w);
%     [plate3_w,~,~] = meshplate(c3_w);
%     Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
%     Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
%     Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
%     watermark_ex_atk_s = CoreExtract_3Channel...
%     (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
%     BER_atk_s(i) = sum(abs(watermark_ex_atk_s-watermark)/Messlength);
% end

% GWN
% atk_n = [0.005, 0.010, 0.015, 0.020, 0.025, 0.030, 0.035, 0.040, 0.045];
% for i=1:length(atk_n)
%     Img_rgb_e_n = imnoise(Img_rgb_e,"gaussian",0,atk_n(i));
%     c1_w = Img_rgb_e_n(:,:,1);
%     c2_w = Img_rgb_e_n(:,:,2);
%     c3_w = Img_rgb_e_n(:,:,3);
%     [plate1_w,rho,theta] = meshplate(c1_w);
%     [plate2_w,~,~] = meshplate(c2_w);
%     [plate3_w,~,~] = meshplate(c3_w);
%     Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
%     Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
%     Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
%     watermark_ex_atk_n = CoreExtract_3Channel...
%     (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
%     BER_atk_n(i) = sum(abs(watermark_ex_atk_n-watermark)/Messlength);
% end

% JPEG
% atk_c = [10, 20, 30, 40, 50, 60, 70, 80, 90];
% for i=1:length(atk_c)
%     imwrite(Img_rgb_e, 'temp.jpg', 'jpg', 'Quality', atk_c(i));
%     Img_rgb_e_c = imread('temp.jpg');
%     c1_w = Img_rgb_e_c(:,:,1);
%     c2_w = Img_rgb_e_c(:,:,2);
%     c3_w = Img_rgb_e_c(:,:,3);
%     [plate1_w,rho,theta] = meshplate(c1_w);
%     [plate2_w,~,~] = meshplate(c2_w);
%     [plate3_w,~,~] = meshplate(c3_w);
%     Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
%     Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
%     Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
%     watermark_ex_atk_c = CoreExtract_3Channel...
%     (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
%     BER_atk_c(i) = sum(abs(watermark_ex_atk_c-watermark)/Messlength);
% end

% JPEG2000
% atk_c2 = [10, 20, 30, 40, 50, 60, 70, 80, 90];
% for i=1:length(atk_c2)
%     imwrite(Img_rgb_e, 'temp.jp2', 'jp2', 'CompressionRatio', atk_c2(i));
%     Img_rgb_e_c2 = imread('temp.jp2');
%     c1_w = Img_rgb_e_c2(:,:,1);
%     c2_w = Img_rgb_e_c2(:,:,2);
%     c3_w = Img_rgb_e_c2(:,:,3);
%     [plate1_w,rho,theta] = meshplate(c1_w);
%     [plate2_w,~,~] = meshplate(c2_w);
%     [plate3_w,~,~] = meshplate(c3_w);
%     Pnm_1_w = PHFM_De(plate1_w,rho,theta,Maxorder);
%     Pnm_2_w = PHFM_De(plate2_w,rho,theta,Maxorder);
%     Pnm_3_w = PHFM_De(plate3_w,rho,theta,Maxorder);
%     watermark_ex_atk_c2 = CoreExtract_3Channel...
%     (Pnm_1_w,Pnm_2_w,Pnm_3_w,Maxorder,Messlength,num_n,QS);
%     BER_atk_c2(i) = sum(abs(watermark_ex_atk_c2-watermark)/Messlength);
% end



