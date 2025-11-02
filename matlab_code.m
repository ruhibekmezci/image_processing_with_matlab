clear; 
clc; 
close all; 

%% 1. ADIM: KALİBRASYON
% Bu adım, sistemi piksel bağımlılığından kurtaracak.
% Önce 1 TL'yi referans alıp, diğer paraları ona göre oranlayacağız.

fprintf('Kamera başlatılıyor...\n');
try
    % cam = webcam(2) yerine varsayılan kamerayı (genellikle 1) bul
    cam = webcam(); 
catch
    % Kamera bulunamazsa veya meşgulse hata ver
    errordlg('Kamera bulunamadı. Başka bir uygulama kamerayı kullanıyor olabilir.', 'Kamera Hatası');
    return;
end

% Kullanıcıya ne yapacağını söyle
msgbox('Kalibrasyon Başlıyor... Lütfen kameranın önüne SADECE BİR TANE 1 TL yerleştirin ve Tamam''a basın.', 'Kalibrasyon');

% Referans görüntüsünü al
resim_ref = snapshot(cam);
A_ref = rgb2gray(resim_ref);
% Görüntüyü yumuşat (gürültü ve yansımaları azaltmak için)
A_ref_filt = imgaussfilt(A_ref, 2); 

% Referans daireyi ara (Geniş aralıkta, çünkü henüz ölçeği bilmiyoruz)
[c_ref, r_ref, m_ref] = imfindcircles(A_ref_filt, [50 150], 'Sensitivity', 0.92);

% Kalibrasyonun başarılı olup olmadığını kontrol et
if isempty(r_ref) || length(r_ref) > 1
    errordlg('Referans 1 TL bulunamadı veya birden fazla nesne algılandı. Lütfen tekrar deneyin.', 'Kalibrasyon Hatası');
    clear cam; % Kamerayı serbest bırak
    return;
end

% Referans yarıçapı piksel olarak kaydet
r_referans_1TL = r_ref(1); 
fprintf('Referans 1 TL yarıçapı: %.2f piksel olarak ayarlandı.\n', r_referans_1TL);


%% GERÇEK FİZİKSEL ORANLARI HESAPLAMA
% Paraların gerçek çaplarını (mm) kullanarak oranlarını hesaplıyoruz
% (Bu verileri internetten buldum)
DIA_1TL = 26.15;    % 1 TL
DIA_50KR = 23.85;   % 50 Kuruş
DIA_25KR = 20.5;    % 25 Kuruş
DIA_10KR = 18.5;    % 10 Kuruş
DIA_5KR = 17.5;     % 5 Kuruş

% 1 TL'ye göre oranları hesapla
RATIO_1TL = DIA_1TL / DIA_1TL;     % 1.0
RATIO_50KR = DIA_50KR / DIA_1TL;   % ~0.912
RATIO_25KR = DIA_25KR / DIA_1TL;   % ~0.784
RATIO_10KR = DIA_10KR / DIA_1TL;   % ~0.707
RATIO_5KR = DIA_5KR / DIA_1TL;     % ~0.669

% Bu oranlarda ufak sapmalar olabilir, %3.5'luk bir tolerans ekliyoruz
TOLERANS = 0.035; 

% Artık daire arama aralığını (range) da dinamik hale getirdik.
% En küçük para (5 Kr) ve en büyük para (1 TL) oranlarına göre
r_min_pixel = r_referans_1TL * (RATIO_5KR - TOLERANS);
r_max_pixel = r_referans_1TL * (RATIO_1TL + TOLERANS);
radius_range = [round(r_min_pixel) round(r_max_pixel)];

fprintf('Dinamik arama yarıçapı: [%d %d] piksel olarak ayarlandı.\n', radius_range(1), radius_range(2));

msgbox('Kalibrasyon tamamlandı. Artık paraları sayabilirsiniz. Çıkmak için görüntü penceresini kapatın.', 'Hazır');

% Görüntü için bir pencere aç
hFig = figure; 
hFig.WindowState = 'maximized'; % Tam ekran yap

%% 2. ADIM: SÜREKLİ PARA SAYMA DÖNGÜSÜ

while ishandle(hFig) % Görüntü penceresi açık olduğu sürece döngüye devam et
    resim = snapshot(cam);
    s = size(resim);
    ix = s(2)/2; % Orta noktalar
    iy = s(1)/2;
    toplam = 0;
    
    % Görüntü İşleme
    A = rgb2gray(resim);
    A_filt = imgaussfilt(A, 2); % Aynı filtrelemeyi burada da yap
    
    % Daireleri Bul (Artık PİKSEL DEĞİL, dinamik referans aralığı ile)
    [c, r, m] = imfindcircles(A_filt, radius_range, 'Sensitivity', 0.92);
    
    % Sonuçları göster
    imshow(resim); % Orijinal renkli resmi göster (gri değil)
    viscircles(c, r,'EdgeColor','b');
    
    % Bulunan her daire için tek tek işlem yap
    for n=1:length(r)
        spara ='';
        % KİLİT NOKTA: Bulunan piksel yarıçapını, referans 1TL'ye bölerek ORAN bul
        bulunan_oran = r(n) / r_referans_1TL; 
        
        % Sınıflandırma (Artık sabit piksel değil, oranlara göre)
        if (bulunan_oran > RATIO_1TL - TOLERANS) && (bulunan_oran < RATIO_1TL + TOLERANS)
            toplam=toplam + 100;
            spara = '1 Lira';
        elseif (bulunan_oran > RATIO_50KR - TOLERANS) && (bulunan_oran < RATIO_50KR + TOLERANS)
            toplam=toplam + 50;
            spara = '50 Kurus';
        elseif (bulunan_oran > RATIO_25KR - TOLERANS) && (bulunan_oran < RATIO_25KR + TOLERANS)
            toplam=toplam + 25;
            spara = '25 Kurus';
        elseif (bulunan_oran > RATIO_10KR - TOLERANS) && (bulunan_oran < RATIO_10KR + TOLERANS)
            toplam=toplam + 10;
            spara = '10 Kurus';
        elseif (bulunan_oran > RATIO_5KR - TOLERANS) && (bulunan_oran < RATIO_5KR + TOLERANS)
            toplam=toplam + 5;
            spara = '5 Kurus';
        end
        
        % Para bulunduysa üzerine yaz
        if length(spara)>0
            x = c(n,1);
            y = c(n,2);
            % Yazının daha okunaklı olması için rengi sarı yaptım
            text(x,y,spara,'FontSize', 10,'fontweight', 'bold', 'Color', 'yellow', 'HorizontalAlignment', 'center');
        end
    end
    
    % Toplamı ekrana yaz
    toplam = toplam / 100;
    yaz = [num2str(toplam, '%.2f') ' Lira']; % %.2f formatı (örn: 1.75)
    
    % Yazının daha okunaklı olması için ortaya ve beyaz renkte yazdır
    h = text(ix,iy,yaz,'FontSize', 30,'fontweight', 'bold', 'HorizontalAlignment', 'center');
    set(h, 'Color','white', 'EdgeColor', 'black', 'LineWidth', 1);
    
    drawnow; % Görüntüyü anlık olarak güncelle
end

% Döngü bitince (kullanıcı pencereyi kapatınca) kamerayı serbest bırak
clear cam; 
disp('Program sonlandırıldı.');
