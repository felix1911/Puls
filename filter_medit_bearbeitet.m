

medit = VarName1;
fs = 100;
[b, a] = butter(4,[0.7] /(fs/2),'high');

[d, c] = butter(2,[3]/(fs/2));
figure;
data_filt_1 = filtfilt(b,a,medit);
data_filt_1_sqr = data_filt_1.^2;

data_filt_2 = filtfilt(d,c,data_filt_1_sqr);

close all;
% figure;
% plot(data_filt_1);
% figure;
% plot(data_filt_1_sqr);
% figure;
% plot(data_filt_2);



n = 1;
data = ones(5,300);
data_xcorr_all = ones(5,599);

while n<=5
            data(n,:)=data_filt_2(((n-1)*300)+1:n*300,:);
           
            data_high_n = (data(n,:)-mean(data(n,:)))/std(data(n,:));
            data_xcorr_all(n,:) = xcorr(data_high_n,'coeff'); 
  
            
         
            data_xcorr = data_xcorr_all(n,:);
            max_index = size(data,2);
            
            data_relevant = data_xcorr(max_index+33:max_index+150);%Nur Daten ab +33, da bei x=0 das Max. liegt(Signal identisch mit sich selbst)

            [y, x] = max(data_relevant);    %Max. Wert und x-Wert ermitteln
            
            index_peak = x +33; %x_Wert des Max. in data_all
            max_peak = y;   %y-Wert des Max. in data_relevant
            max_n = floor(index_peak / 33);%Anzahl der max. Perioden (max. Puls = 180bpm)
            
            i = 2;
            
            while i<=max_n
                check_peak = index_peak / i;    %x-Wert in dessen Umgebung nach Maximum(Toleranz 0.3) gesucht wird
                data_check = data_relevant(max(1,ceil(check_peak-33-3)):floor(check_peak-33+3));
                [y_check, x_check] = max(data_check);
                if y_check>= 0.8*max_peak
                    x = x_check+ceil(check_peak-33-3);
                    y= y_check;
                end
                i=i+1;
            end
            
            figure;
            plot(data_xcorr(max_index:2*max_index-1));
            hold on;
            plot(x+33,y,'o','MarkerSize',10);
            
            
            n = n+1;
            
end
