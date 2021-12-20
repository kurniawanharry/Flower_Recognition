% Harry Kurniawan

clc; clear; close all;

%%% Proses Pelatihan
%membaca file citra
nama_folder = 'data latih';
nama_file = dir(fullfile(nama_folder,'*.jpg'));
jumlah_file = numel(nama_file);

%inisialiasi variable ciri latih
ciri_latih = zeros(jumlah_file,5);

for n=1:jumlah_file
    
    %membaca citra RGB    
    Img = imread(fullfile(nama_folder,nama_file(n).name));
    
    %resize citra
    Img_resize = imresize(Img,[240 240]);
    
    %Ambil nilai luas image
    rows  = size(Img_resize,1);
    cols  = size(Img_resize,2);
    Img_size = rows*cols;
    
    %konversi citra RGB menjadi greyscale    
    Img_grey = rgb2gray(Img_resize);
   
    %thresholding
    bw = im2bw(Img_grey,graythresh(Img_grey));
    bw = bwareaopen(bw,500);
    
    %operasi morfologi
    ser = strel('disk',1);
    se = strel('disk',2);
    bw = imclose(bw,se);
    bw = imopen(bw,ser);
    bw = imfill(bw,'holes');
    
    %mask
    maskedRgbImage = bsxfun(@times, Img_resize, cast(bw, 'like', Img_resize));

    %ekstraksi ciri warna HSV
    HSV = rgb2hsv(maskedRgbImage);
    H = HSV(:,:,1);
    S = HSV(:,:,2);
    V = HSV(:,:,3);
    
    H(~bw) = 0;
    S(~bw) = 0;
    V(~bw) = 0;
    
    Hue = sum(sum(H))/sum(sum(bw));
    Saturation = sum(sum(S))/sum(sum(bw));
    Value = sum(sum(V))/sum(sum(bw));
    
    %ekstraksi ciri bentuk eccentricity dan metric
    stats = regionprops(bw,'All');
    perimeter = stats.Perimeter;
    maj = stats.MajorAxisLength;
    mij = stats.MinorAxisLength;
    area = stats.Area;
    eccentricity = stats.Eccentricity;
    metric = 4*pi*area/perimeter^2;
    
    %mengisi hasil ekstraksi ciri pada variabel ciri_latih
    ciri_latih(n,1) = Hue;
    ciri_latih(n,2) = Saturation;
    ciri_latih(n,3) = Value;
    ciri_latih(n,4) = eccentricity;
    ciri_latih(n,5) = metric;
end

kelas_latih = cell(jumlah_file,1);

for k=1:40
    kelas_latih{k} = 'buttercup';
end

for k=41:80
    kelas_latih{k} = 'daisy';
end

for k=81:120
    kelas_latih{k} = 'dandelion';
end

for k=121:160
    kelas_latih{k} = 'sunflower';
end

for k=161:200
    kelas_latih{k} = 'windflower';
end

%klasifikasi dengan Naive Bayes
Mdl = fitcnb(ciri_latih,kelas_latih);

%menyimpan hasil variabel-variabel hasil pelatihan
save hasil_pelatihan Mdl

