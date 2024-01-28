%profile on

%Başlangıç Parametrelerinin Girilmesi

filename = "ANK200TUR_S_20233320000_01D_GN.rnx";
rinex_data = rinexread(filename);
gnss_data = rinex_data.GPS;
starting_time = datetime(2023,11,27,10,00,00); 
[satID] = unique(gnss_data.SatelliteID); 
gnss_data1    = gnss_data(satID,:); %  
timeElapsed = 0:1:1441; 
t = starting_time + minutes(timeElapsed);
timeElapsedHours = 0:1:24;
t_hours = starting_time + hours(timeElapsedHours);
baslangicKonumu = [40.9950 39.768 86.6317];
baslangicKonumuEcef = lla2ecef(baslangicKonumu);
receiverPos = [40.9950 39.768 86.6317];
receiverPosEcef = lla2ecef(receiverPos);

receiverPosT = receiverPos';
receiverPosEcefT = receiverPosEcef';
maskAngle = 5;
numSamples = numel(t);
numSamplesHours = numel(t_hours);

%Matrislerin Oluşturulması

lla = zeros(1,3);
lla0 = [46.017 7.750 1673];
lla0_array = zeros(numSamples,3);
lla0_array(:,1) = lla0(1);
lla0_array(:,2) = lla0(2);
lla0_array(:,3) = lla0(3);

HDOP= zeros(1,numSamples);
VDOP= zeros(1,numSamples);
PDOP= zeros(1,numSamples);
Error = zeros(numSamples,3);
Pu = zeros(1,3);
Pu_array = zeros(numSamples,3);
visible_sat_prns = zeros(12,1);
BaslangicKonumu = zeros(numSamples, 3);
BaslangicKonumu(:,1) = baslangicKonumu(1);
BaslangicKonumu(:,2)= baslangicKonumu(2);
BaslangicKonumu(:,3) = baslangicKonumu(3);

% Zaman dizisi olarak baz aldığımız örnekleme ile for döngüsü oluşturularak
% uydu konumu , pseudorange , visible uydular gibi verilerin elde edilmesi

for ii = 1:numSamples
    [satPos] = gnssconstellation(t(ii),gnss_data1,GNSSFileType="RINEX"); 
    satPosT = satPos'; 
    [az,el,vis]    = lookangles(baslangicKonumu, satPos, maskAngle);  
    visible_sat_prns = find(vis == 1);  
    p = pseudoranges(baslangicKonumu,satPos(visible_sat_prns,:));   
    satPosVisible = satPos(visible_sat_prns,:);  
    delta_r = [100;100;100];
    delta_r_norm = Inf;

    DOP = zeros(3, 3);

    maxIter = 1000;  % Maksimum iterasyon sayısı
    iter = 0; %iterasyon sayısı

    %LSE (Least Square Estimation) Denklemlerinin Oluşturulması


    while iter<maxIter

        pr_noise = p + abs(10*randn(size(p)));      %observable pseudorangenin hesaplanan pseudorange gürültü eklenerek bulunması
        delta_x= satPosVisible(:,1) - receiverPosEcef(1);
        delta_y = satPosVisible(:,2) - receiverPosEcef(2);
        delta_z = satPosVisible(:,3) - receiverPosEcef(3);
        delta_xyz = [delta_x, delta_y, delta_z];          %Tasarım Matrisi elemanlarının Oluşturulması
 
        R = norm(delta_xyz);   
        H = (delta_xyz)./ R;             %Tasarım Matrisinin Oluşturulması

        delta_pr = pr_noise' - p';
        H_T = H';
        DOP = inv(H_T*H);                    %DOP Formülleri
        H_terms = (DOP)*(H_T);
        delta_r = H_terms.*delta_pr;

        receiverPosEcef = delta_r(1:3) + receiverPosEcefT;
        iter = iter + 1;

    end
%% 

    Pu = baslangicKonumuEcef + delta_r(1:3);   %Elde edilen konum tahminleriyle konum dizisinin oluşturulması
    Pu_array(ii,1) = Pu(1);
    Pu_array(ii,2) = Pu(2);
    Pu_array(ii,3) = Pu(3);

    %DOP formülleri ile VDOP , HDOP ve PDOP değerlerinin bulunması

    VDOP(ii) = sqrt(DOP(3,3)); 
    HDOP(ii) = sqrt(DOP(1,1) + DOP(2,2));
    PDOP(ii) = sqrt(DOP(1,1) + DOP(2,2) + DOP(3,3));



end
Pu_lla = ecef2lla(Pu_array);
VDOP_array = VDOP(1:60:1442);
PDOP_array = PDOP(1:60:1442);
HDOP_array = HDOP(1:60:1442);

%Konum Kestirim Hatalarının Bulunması

startingNedPos = lla2ned(BaslangicKonumu,lla0_array,"ellipsoid");
calculatedNedPos = lla2ned(Pu_lla,lla0_array,"ellipsoid");
PositionError = startingNedPos - calculatedNedPos;

%Elde edilen Verilerin Grafiğe Dökülmesi

figure;
subplot(2, 1, 1);
geoscatter(BaslangicKonumu(:,1), BaslangicKonumu(:,2), 'blue', 'filled', 'SizeData', 50)
geobasemap("topographic")
geolimits([40.9945 40.9955], [39.7675 39.7690]);
hold on;
geoscatter(Pu_lla(:,1), Pu_lla(:,2), 'red', 'filled','SizeData',17)
legend('True Position','Estimated Position')
hold off;

subplot(2, 1, 2);
plot(t, BaslangicKonumu(:,3),'blue')
hold on;
scatter(t, Pu_lla(:,3), 'o', 'filled','red','SizeData',17)
title('Yükseklik vs. Time of Week');
xlabel('Time of Week');
ylabel('Yükseklik');
grid on
hold off;

figure;
subplot(1,1,1);
stairs(t_hours,HDOP_array);
hold on
stairs(t_hours,VDOP_array);
stairs(t_hours,PDOP_array);
legend('HDOP','VDOP','PDOP');
xlabel("time");
ylabel("DOP Values");

figure
subplot(3,1,1);
plot(t,PositionError(:,1));
xlabel("time");
ylabel("Error(m)")
legend("North Error")

subplot(3,1,2);
plot(t,PositionError(:,2));
xlabel("time");
ylabel("error (m)")
legend("East Error")

subplot(3,1,3);
plot(t,PositionError(:,3))
xlabel("time")
ylabel("error (m)")
legend("Down Error")