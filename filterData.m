function y = filterData(data)
figure(1)
clf;
plot(data)      %Rohdaten ausgeben

data_high = high(data);     %Hochpass auf Rohdaten anwenden.....z.B. Atmung "rausschmeissen" 


data_high_n = (data_high-mean(data_high))/std(data_high);       %Hochpassgefilterte Daten normieren für Autokorr.

data_xcorr = xcorr(data_high_n,'coeff');    %Autokorr. auf normierte, hochpassgefilterte Rohdaten anwenden
figure(3);
clf;
plot(data_xcorr)

max_index = size(data,1);   %max_index ist Symmetrieachse von data_xcorr

data_all = data_xcorr(max_index:size(data_xcorr),:);    %Da data_xcorr spiegelsymm., betrachte nur rechte Seite
data_relevant = data_xcorr((max_index+15):2*size(data,1)-1,:);%Nur Daten ab +15, da bei x=0 das Max. liegt(Signal identisch mit sich selbst)

[y, x] = max(data_relevant);    %Max. Wert und x-Wert ermitteln

index_peak = x +15; %x_Wert des Max. in data_all
max_peak = y;   %y-Wert des Max. in data_relevant
max_n = ceil((index_peak / 33));%Anzahl der max. Perioden (max. Puls = 180bpm)

n=2;

while n<=max_n
    check_peak = index_peak / n;    %x-Wert in dessen Umgebung nach Maximum(Toleranz 0.3) gesucht wird
    data_check = data_relevant(round(check_peak-15-3):round(check_peak-15+3),:);
    [y_check, x_check] = max(data_check);
    if y_check>= 0.7*max_peak
         x = x_check+check_peak-4 - 15;
         y= y_check
    end
    n=n+1;
end


figure(4);
clf;
plot(data_all);
hold on;
plot(x+15,y,'o','MarkerSize',10);


frequenz = 60/(x+15);
disp(['Der Puls beträgt ', num2str(frequenz * 100), ' Schläge pro Minute']);

y=frequenz;

