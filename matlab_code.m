subplot(5,1,1);
resim = imread('C:\Users\user\Desktop\resim1.png');
imshow(resim);
title('Original Image');

subplot(5,1,2);
image = rgb2gray(resim);
level = graythresh(image);
bw = im2bw(image, level);
imshow(bw);
title('2D image converted to grayscale');

subplot(5,1,3);
bw = imcomplement(bw);
imshow(bw);
title('Added image negativity');

subplot(5,1,4);
bw = imfill(bw,'holes');
bw = bwareaopen(bw,30);
imshow(bw);
title('Stuffed the holes');

subplot(5,1,5);
se = strel('disk',11);
bw2 = imerode(bw,se);
imshow(bw2);
title('coin sorting process');

[B,L] = bwboundaries(bw2);
stats = regionprops(bw2, 'Area','Centroid');
figure(6),imshow(resim);

toplam = 0;
    for n=1:length(B)
        a = stats(n).Area;
        centroid=stats(n).Centroid;
            if a > 1200
                toplam = toplam + 1;
                text(centroid(1),centroid(2),'1Lira');
            elseif a > 800 && a < 1050
                toplam = toplam + 0.5;
                text(centroid(1),centroid(2),'50Krþ');
            elseif a > 500 && a < 650
                toplam = toplam + 0.25;
                text(centroid(1),centroid(2),'25Krþ');
            elseif a > 360 && a < 380
                toplam = toplam + 0.10;
                text(centroid(1),centroid(2),'10Krþ');
            else
                toplam = toplam + 0.05;
                text(centroid(1),centroid(2),'5Krþ');
            end
    end
    
    title(['Total Coin = ',num2str(toplam), ' Lira']);