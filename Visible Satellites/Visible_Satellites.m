
% Receiver Position

latitude     = 40.9950021;  % alıcı enlemi (φ)
longitude    = 39.7683797;  % alıcı boylamı (λ)
height    = 86.6317215;  %  yükseklik (h)
maskAngle = 5;                 % maske açısı
receiver_position    = [latitude,longitude,height];  % Geodetic / Elipsoidal coordinate sistemine göre alıcı konumu (position)
receiver_velocity    = [0,0,0];   % Alıcı hızı (velocity)

loop = true;
while loop
            message = "Küresel uydu konumlama sistemlerinden birini seçiniz :\n" + ...
        "1 --> GPS\n" + ...
        "2--> GALILEO\n" + ...
        "3--> Exit\n";
        
    x = input(message);
    gnss_num = x;
    disp(gnss_num);
    if gnss_num == 1
        filename = "ANK200TUR_S_20233030000_01D_GN (1).rnx";
        rinex_data = rinexread(filename);
        gnss_data = rinex_data.GPS;
        starting_time = datetime(2023,10,29,12,00,00); % başlangıç zam
        
    elseif gnss_num == 2
        filename = "ANK200TUR_S_20233030000_01D_EN.rnx";
        rinex_data = rinexread(filename);
        gnss_data = rinex_data.Galileo;
        starting_time = datetime(2023,10,29,12,00,00); % başlangıç zamanı

    elseif gnss_num == 3
       break;
        
    end

    [satID] = unique(gnss_data.SatelliteID); % GNSS verileri içerisindeki uydu PRN numaralarını tek tek alıyor
    gnss_data1    = gnss_data(satID,:); % Sadece belirlenen satID satırlarını ve tüm sütunları seçer
    disp(gnss_data1);
    satPRN = gnss_data1.SatelliteID; %gnss_data1 içerisinden uydu numaralarını çekiyor
    fprintf('Uydu Sayısı =%d ' , length(satPRN));

    numHours = 24;
    timeElapsed = 0:1:(numHours);  % 1 saat aralıkla artan bir zaman dizisi oluşturuyoruz
    t = starting_time + hours(timeElapsed); % başlangıç zamanına 1 saat sırayla ekleniyor

    numSats = numel(satPRN); %toplam uydu sayısı
    numSamples = numel(t);  %Örnekleme Sayısı

    %vis = false(numSamples,numSats);   %vis = visibility   logical array (0'lardan yani falselerden oluşuyor)

    for ii = 1:numSamples
        fprintf('\n*======================*====*=========*=========*================*\n');
        fprintf(  '|  Time                |PRN | Azimuth |Elevation|Pseudoranges(km)|\n');
        fprintf('\n*======================*====*=========*=========*================*\n');
        [satellite_position, satellite_velocity] = gnssconstellation(t(ii), gnss_data1, GNSSFileType="RINEX");
    
        % alınan zaman ve gnss dosyasına  göre uydu konumu ve hızını hesaplar

        [az, el, vis]    = lookangles(receiver_position, satellite_position, maskAngle);
        % lookangles gnss komutu ile belirlediğimiz alıcı konumu ve uydu konumu
        % alınarak  azemuth , elevation açısı belirlenir. maskAngle ile ise
        % uyduların görünürlükleri belirlenir.

        visible_sat_prns = find(vis == 1); 
         % visibility matrixinin içindeki true yani 1 değerleri bulunarak
        % visibility uydular belirleniyor.

        p = pseudoranges(receiver_position,satellite_position(visible_sat_prns,:));
        % gnns kütüphanesinden bulunan pseudoranges komutu ile alıcı konumu ve
        % görünür uyduların konumları alınarak görünür uydular ve alıcı
        % arasındaki mesafe olan pseudorange değeri hesaplanıyor.

        skyplot(az(visible_sat_prns),el(visible_sat_prns),satPRN(visible_sat_prns))
    
        % görünür uyduların azemuth , elevation açıları ve uydu numaraları

        for j=1:length(visible_sat_prns)
            fprintf('| %s | %02d | %.2f° | %.2f° |   %.2f\n', t(ii),satPRN(visible_sat_prns(j)),az(visible_sat_prns(j)),el(visible_sat_prns(j)),p(j)/1000);
        end
        drawnow 
    end




% Belirlenen tarihin skyplot grafiğini yazdırma
    w = true;
    while w
        message_3 = "İşlem Seçiniz :\n" + ...
            "1 - Geri Dön\n" +...
            "2 - Skyplot Grafiği İçin Tarih Gir\n" + ...
            "3 - Çıkış";
        menu = input(message_3);
        islem = menu;
        if islem == 1
            loop = true;
            w = false;
            break;
        elseif islem == 2
            prompt = {'Yıl:','Ay','Gün','Saat','Dakika'};
            dlgtitle = 'Tarih';
            fieldsize = [1 45; 1 45; 1 45; 1 45; 1 45];
            answer = inputdlg(prompt,dlgtitle,fieldsize);
            ttt = datetime(str2double(answer{1}),str2double(answer{2}),str2double(answer{3}),str2double(answer{4}),str2double(answer{5}),0);
            disp(ttt);
            fprintf('\n*======================*====*=========*=========*================*\n');
            fprintf(  '|  Time                |PRN | Azimuth |Elevation|Pseudoranges(km)|\n');
            fprintf('\n*======================*====*=========*=========*================*\n');
            [satellite_position, satellite_velocity] = gnssconstellation(ttt, gnss_data1, GNSSFileType="RINEX");
            [az, el, vis]    = lookangles(receiver_position, satellite_position, maskAngle);
            visible_sat_prns = find(vis == 1);
            p = pseudoranges(receiver_position,satellite_position(visible_sat_prns,:));

            for j=1:length(visible_sat_prns)

                fprintf('| %s | %02d | %.2f° | %.2f° |   %.2f\n', ttt,satPRN(visible_sat_prns(j)),az(visible_sat_prns(j)),el(visible_sat_prns(j)),p(j)/1000);
            end

            skyplot(az(visible_sat_prns),el(visible_sat_prns),satPRN(visible_sat_prns));
        elseif islem == 3
            loop = false;
            break;

        end
        
    end
end


