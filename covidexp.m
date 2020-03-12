local_init; visFlag = true
%% Load daily data 
outfilename = websave('newcases.csv','https://cowid.netlify.com/data/new_cases.csv');
prompt = 'Country name: ';
countryName = input(prompt,'s');
[~,~,data] = xlsread(outfilename);
table = readtable(outfilename);
Countries = table.Properties.VariableNames;
[tf, iColumn] = ismember(countryName, Countries);
 if ~tf
     error('Country not in the list.')
 end
 cases = table2array(table(:,iColumn));
 times = find(~isnan(cases));
 x_real = cases(times,1);
 pzero   = table{times(1),1};
%% Original training data
% foamset = questdlg('Select country', ...
%     'Country',...
% 	'UK','Italy','Russia',''); % 'Hubei','India',
% switch foamset
%     case 'UK'
%         x_train = [0 0 0 0 0 1 0 0 1 4 0 1 0 0 0 0 0 0 0 0 0 0 4 0 0 0 3 4 3 13 4 10 34 28 48 42 69 42 64 77 134];
%         x_real  = [0 0 0 0 0 1 0 0 1 4 0 1 0 0 0 0 0 0 0 0 0 0 4 0 0 0 3 4 3 13 4 10 34 28 48 42 69 42 64 77 134];
%         pzero   = datetime(2020,2,1);
%     case 'Italy'
%         x_train =  [2 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 16 59 73 77 95 130 202 234 239 566 342 466 587 769 778 1247 1492 1797 977 2313  2651];
%         x_real =  [2 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 16 59 73 77 95 130 202 234 239 566 342 466 587 769 778 1247 1492 1797 977 2313  2651];
%         pzero   = datetime(2020,2,9);
%     case 'Hubei'
%         x_train =  [2 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 16 59 73 77 95 130 202 234 239 566 342 466 587 769 778 1247 1492 1797 977 2313  2651];
%         pzero   = datetime(2020,2,9);
%     case 'India'
%         x_train =  [2 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 16 59 73 77 95 130 202 234 239 566 342 466 587 769 778 1247 1492 1797 977 2313  2651];
%         pzero   = datetime(2020,2,9);
%     case 'Russia'
%         x_train = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 3 0 0 0 0];
%         x_real = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 3 0 0 0 0];
% 
%         pzero   = datetime(2020,2,1);
% end
x_train = cases(times,1);
t_train = [1:length(x_train)]'-1;
y_train = cumsum(x_train);
f = fit(t_train,y_train,'exp1')
figure('Name','Training data','NumberTitle','off','visible',visFlag);
subplot(2,1,1);
plot(x_train);
xlabel('days from patient zero'); ylabel('new cases');
subplot(2,1,2);
plot(y_train);
xlabel('days from patient zero'); ylabel('total cases');
%% Predicttion
ndays = 14;
today = date;
func = @(x) f.a*exp(f.b*x);
t2      = [t_train(end):t_train(end)+ndays];
y2      = func(t2);
y2      = round(y2);
y_old   = func(t_train);
figure('Name','Prediction','NumberTitle','off','visible',visFlag);
plot(t_train,y_old,'k','Linewidth',2); hold on;
plot(t_train(end),y_train(end),'*','Linewidth',5); hold on;
plot(t2,y2,'-o'); hold on;
legend('Fitted curve',today,'Prediction','Location','northwest');
xlabel('days from patient zero'); ylabel('total cases');
%% Reality check
t_real = [1:length(x_real)]'-1;
y_real = cumsum(x_real);
y_model = func(t_real);
y_model = round(func(t_real));
pe      = y_model - y_real;
figure('Name','Validation','NumberTitle','off','visible',visFlag);
subplot(2,1,1)
plot(t_real,y_model,'-'); hold on;
scatter(t_real,y_real,'filled'); hold on;
for t = 1:length(t_real)
    line([t_real(t) t_real(t)],[y_real(t) y_model(t)]); hold on;
end
xlabel('days from patient zero'); ylabel('total cases');
legend('Modelled data','True data','Location','northwest');
subplot(2,1,2)
plot(t_real,pe,'--'); hold on;
plot([t_real(1) t_real(t)],[0 0],'--k');
xlabel('days from patient zero'); ylabel('prediction bias');
