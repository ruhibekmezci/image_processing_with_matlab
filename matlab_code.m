cam = webcam(2) %webcam'i aktiflestiriyoruz
preview(cam);
resim = snapshot(cam); % resimi okuyoruz
s = size(resim); % resimin boyutlarini aldik
ix = s(2)/2; % orta noktalari
iy = s(1)/2;
toplam =0; % toplam parayi programın basinda sifirladik
A = rgb2gray(resim); % resmi siyah beyaza cevirdik
imshow(A);
[c, r, m] = imfindcircles(A,[50 100]); % resimdeki yuvarlak nesneleri buluyoruz, c merkez nokta, r yaricap
viscircles(c, r,'EdgeColor','b'); % paralarin etrafini ciziyoruz.

for n=1:length(r) %tüm bulunan yuvarlak nesneleri taramak icin dongu
    spara ='';     % paranin uzerine yazilacak yazi, her seferinde ici bosaltiliyor.
    if r(n)>75 && r(n)<82   % 1 lira icin boyut limitleri
        toplam=toplam + 100; % 1 lira 100 kurus olarak toplama eklendi
        spara = '1 Lira';   % yazilacak metin
    elseif r(n)>65 && r(n)<75
        toplam=toplam + 50;
        spara = '50 Kurus';
    elseif r(n)>58 && r(n)<65
        toplam=toplam + 25;
        spara = '25 Kurus';
    elseif r(n)>54 && r(n)<58
        toplam=toplam + 10;
        spara = '10 Kurus';
    elseif r(n)>50 && r(n)<54
        toplam=toplam + 5;
        spara = '5 Kurus';
    end
    if length(spara)>0 % eger para bulunmussa, yazilacak metin varsa
        x = c(n,1);    % paranÄ±n degerinin yazilacagi nokta koordinatlari
        y = c(n,2);
        text(x,y,spara,'FontSize', 10,'fontweight', 'bold'); % paranin degerinin yazilmasi
    end
end
toplam = toplam / 100; % toplam kurus olarakti, liraya ceviriyoruz
yaz = [num2str(toplam)  ' Lira']; %stringe ceviriyoruz
h = text(ix,iy,yaz,'FontSize', 30,'fontweight', 'bold'); %yaziyoruz
set(h, 'Color','w');                                     % rengini degistiriyoruz
%set(h, 'BackgroundColor','w');          % arka planini degistiriyoruz
