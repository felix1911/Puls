%plot(medit);
fs = 100;
[b, a] = butter(2,[0.7 10]/(fs/2));
%figure;
%plot(filtfilt(b,a,medit));
%figure;
%plot(filtfilt(b,a,medit).^2);
[d, c] = butter(2,[3]/(fs/2));
figure;
data_filt= filtfilt(d,c,filtfilt(b,a,medit).^2);

%plot(data_filt);

close all;

n = 1;
data = ones(5,300);
data_xcorr = ones(5,599);

while n<=5
            data(n,:)=data_filt(((n-1)*300)+1:n*300,:);
           
            data_high_n = (data(n,:)-mean(data(n,:)))/std(data(n,:));
            data_xcorr(n,:) = xcorr(data_high_n,'coeff'); 
            figure;
            plot(data_xcorr(n,:));
            n = n+1;
            
end



