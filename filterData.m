function y = filterData(data)



data_high = high(data);
data_high_abs = abs(data_high);
data_high_n = (data_high_abs-mean(data_high_abs))/std(data_high_abs);

data_xcorr = xcorr(data_high_n,'coeff');

[xcorr_low] = low(data_xcorr);

max_index = size(data) + 3;

data_all = xcorr_low(max_index:size(xcorr_low),:);
data_relevant = xcorr_low((max_index+30):(max_index+160),:);

[y, x] = max(data_relevant);

plot(data_all);
hold on;
plot(x+30,y,'o','MarkerSize',10);


frequenz = 60/(x+30);
disp(['Der Puls beträgt ', num2str(frequenz * 100), ' Schläge pro Minute']);

y=frequenz;
