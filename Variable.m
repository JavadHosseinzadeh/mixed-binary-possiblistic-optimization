p_load = p_inf;
p_rad = p_load;

mpc = case39;                                  % IEEE 39 Bus system
numgen=10;
numnode=39;
num_day = 365;                                   % Number of day
timeline = 24 * num_day;
SL_ch=0.8;                                      % storage efficiency charge
SL_dch=0.60;                                      % storage efficiency discharge
M=1e6;
Generator_Ramp_rate = 50;                                      % ramp rate
T=timeline;
PTDF = makePTDF(mpc.baseMVA, mpc.bus, mpc.branch, 31); % PTDF matrix
storage_efficiency = 0.99;
Spinning_Reserve = 500;
Min_discharge_period = 8;
Min_charge_period = 8;
CSP_lifetime = 25;
TES_lifetime = 25;
%%
eta_csp = 0.6;
SL_c2s = 0.95;
mu = 10000;
%%
Inflation_mu = 3.6312/100;
Inflation_sig = 2.3067/100;
if poss == 1
    Inflation = Inflation_mu - 2^(1/2)*Inflation_sig*(-log(p_inf))^(1/2);
end
if nec == 1
    Inflation = Inflation_mu + 2^(1/2)*Inflation_sig*(-log(1-p_inf))^(1/2);
end
CRF = (Inflation*(1+Inflation)^TES_lifetime)/(((1+Inflation)^TES_lifetime) - 1);
%%
CSP_lifetime_price = 4746000*0.7*0.7*0.85;
lifetime_price = 4746000*SL_dch;
Inflation_rate_Year_CSP = ((1+Inflation).^(0:CSP_lifetime-1).');
Inflation_rate_Year_TES = ((1+Inflation).^(0:TES_lifetime-1).');
Storage_Investment = (lifetime_price/TES_lifetime)*(Inflation_rate_Year_TES(2));
CSP_Investment = (CSP_lifetime_price/CSP_lifetime)*(Inflation_rate_Year_CSP(2));
%%
load('load_data_profiles.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if poss == 1
Data_RES_sum = Data_RES_mu + 2^(1/2)*Data_RES_sigma*(-log(p_load))^(1/2);
end
if nec == 1
Data_RES_sum = Data_RES_mu - 2^(1/2)*Data_RES_sigma*(-log(1-p_load))^(1/2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
General_Load = (data_COM_sum+Data_IND_sum+Data_RES_sum')*(4/5);
General_Load_daily = reshape(General_Load,24,365);
idx_sat=(1:7:365);
idx_sun=(7:7:365);
idx_weekend = sort([idx_sat idx_sun]);
Weekend_Load_Daily = General_Load_daily(:,idx_weekend);
days = 1:365;
idx_weekday = setdiff(days,idx_weekend);
Weekday_Load_Daily = General_Load_daily(:,idx_weekday);
Weekday_Load_Daily_avg = mean(Weekday_Load_Daily,2);

monthly__price = [173*ones(1,31*24) 173*ones(1,28*24) 174*ones(1,31*24) 173*ones(1,30*24)...
    175*ones(1,31*24) 178*ones(1,30*24) 178*ones(1,31*24) 177*ones(1,31*24)...
    178*ones(1,30*24) 177*ones(1,31*24) 168*ones(1,30*24) 169*ones(1,31*24)];

for i=1:365
    if sum(idx_weekend==i)==1
        P__daily(i*24-23:24*i) = ones(1,24);
    end
    if sum(idx_weekday==i)==1
        P__daily(i*24-23:24*i) = [0.5*ones(1,7) ones(1,3) 1.5*ones(1,11) ones(1,3)];
    end
end
P__MAX = monthly__price.*P__daily;
%%
idx = mpc.bus(:,3)~=0;
D_matrix = zeros(numnode,timeline);
D_matrix(1,:) = (mpc.bus(1,3)/sum(mpc.bus(:,3)))*General_Load; 
for i=2:39
    if idx(i)==1
        D_matrix(i,:) = (mpc.bus(i,3)/sum(mpc.bus(:,3)))*General_Load;
    end
end
%%
radiation_data = xlsread('radiation.csv');
%%
radiation_data_1 = circshift(radiation_data,-5);
radiation1 = radiation_data_1(:,1)/1e3;
if poss == 1
    radiation = radiation1 + 2^(1/2)*0.1*radiation1*(-log(p_rad))^(1/2);
end
if nec == 1
    radiation = radiation1 - 2^(1/2)*0.1*radiation1*(-log(1-p_rad))^(1/2);
end
