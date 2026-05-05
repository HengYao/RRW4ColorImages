clc
clear
close all
disp("running...")

%%
Messlength = 128;
[Maxorder,capacity] = getMaxorder(Messlength);

path_imagefolder ="USC_SIPI_Color/512";
image_files = dir(fullfile(path_imagefolder,"*.tiff"));
images = cell(1, numel(image_files));

for i = 1:numel(image_files)
    path_image = fullfile(path_imagefolder, image_files(i).name);
    images{i} = imread(path_image);
end

for i = 1:numel(image_files)

    Img_rgb = images{i};
    c1 = Img_rgb(:,:,1);
    c2 = Img_rgb(:,:,2);
    c3 = Img_rgb(:,:,3);
    [plate1,rho,theta] = meshplate(c1);
    [plate2,~,~] = meshplate(c2);
    [plate3,~,~] = meshplate(c3);
    Pnm_1 = PHFM_De(plate1,rho,theta,Maxorder);
    Pnm_2 = PHFM_De(plate2,rho,theta,Maxorder);
    Pnm_3 = PHFM_De(plate3,rho,theta,Maxorder);

    outcount = 1;
    for num_n = 1000:1000:5000
        incount = 1;
        for QS = 10:2:20

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

            PSNR(incount,outcount) = psnr(Img_rgb_e,Img_rgb);
            incount = incount + 1;
        end
        outcount = outcount + 1;
    end
    data{i} = PSNR;
end





