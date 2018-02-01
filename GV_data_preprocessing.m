function [] =  GV_data_preprocessing(search_path_input, patient_number)

  if ispc
    DirStr = '\';
  else
    DirStr = '/';
  end


load('C:\Users\jpc5s\Dropbox\Personal\Master''s Thesis\GV_Control\GV_patientdata.mat', 'GV_patientdata')
subj = patient_number;
subj_n = subj+40100;

%% Get fastingBG
load(['.\GV_Control\',num2str(subj_n),'_control\DP3_database',num2str(subj_n)]);
HbA1c_subject = HbA1c;
fastingBG = 28.7*HbA1c_subject-46.7;


% %%% ********only for the sample database to align the CGM time********
%   cgm_time = cgm_time + 32;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sort CGM
%handle the CGM data, remove repeated readings
cgm_time = GV_patientdata(subj).cgm_t;
cgm_value = GV_patientdata(subj).cgm_v;
[cgm_times_U,m,~] = unique(datenum(cgm_time),'first');
cgm_values_Uc=cgm_value(m);
cgm_values_U = cgm_values_Uc;
%   cgm_values_U=[];
%   for i=1:length(cgm_times_U)
%       cgm_values_U=[cgm_values_U; (cgm_values_Uc(i,1))];
%   end

%time order the CGM measurement data
[cgm_times_U_sorted,im]= sortrows(cgm_times_U);
cgm_values_U_sorted=cgm_values_U(im);

cgm_t=cgm_times_U_sorted;
cgm_v=cgm_values_U_sorted;

ind = find(isnan(cgm_values_U_sorted));
cgm_t(ind)=[];
cgm_v(ind)=[];

%% Evaluate Net Effect Criteria
teval = cgm_t - floor(cgm_t(1));
thead = 8/24;
ttail = 4/24;
if ceil(teval(end))<=2
    error('Error. Only one-day data. Not eough data for analysis.');
    
elseif teval(end)<1+ttail
    error('Error. Less than 4-hr tailed-data. Not enough data for analysis.');

% Commented out so this can run on admission data (<48 hrs)
% elseif teval(1)>1-thead && teval(end)<3+ttail
%     error('Error. Less than 8-hr before day 1 and less than 4-hour after day 3. Not enough data for analysis.');
    
else
    
    % count of active Net Effect days
    if teval(end)-floor(teval(end))<ttail
        CntNEDay = floor(teval(end)) - 1;  % not enough 4-hr tailed data
        %       EndDay = floor(cgm_t(end)) - 1;
    else
        CntNEDay = floor(teval(end));
        %       EndDay = floor(cgm_t(end));
    end
    
    
    if teval(1) > 1-thead
        tstart = 2; % starting from day 2 midnight
        %       IdxNEDay = 2;
        CntNEDay = CntNEDay - 2;
        StartDay = floor(cgm_t(1)) + 2;
    else
        tstart = 1; % starting from day 1 midnight
        %       IdxNEDay = 1;
        CntNEDay = CntNEDay - 1;
        StartDay = floor(cgm_t(1)) + 1;
    end
    
    % Flag vector of validated Net Effect: 0-Not Valid; 1-Valid
    FNEValid = zeros(CntNEDay, 1);
    IdxNEDay = 1;
    
    id2 = find(teval>tstart+1+ttail, 1, 'first');
    while ~isempty(id2)
        id1 = find(teval>=tstart-thead, 1, 'first');
        
        % create Net Effect evaluation vector: 8-hr head + whole day + 4-hr tail
        ttmp = [tstart-thead; teval(id1:id2-1); tstart+1+ttail];
        
        % compare time difference between neiboring time stamps
        tdiff = diff(ttmp);
        
        % locate time spans greater than 5 minutes
        todd = tdiff(round(tdiff*1440/5)>=2);
        
        % cond.1: the largest gap <= 3 hours per day
        % cond.2: total missed samples of 5-min steps <= 60 (time span <= 5 hours) per day
        %   Be noted that when 'todd' has more than one member (more than one segment of gap), then each segment is minus 1 to get the count of samples.
        if max(tdiff)<=3/24 && sum(round(todd*1440/5)-1)<=60
            FNEValid(IdxNEDay) = 1;
        end
        
        IdxNEDay = IdxNEDay + 1;
        tstart = tstart + 1; % move Net Effect starting point
        id2 = find(teval>tstart+1+ttail, 1, 'first');
        
    end % while
    
end % if


%% SMBG - DP3 version
ind = find(isnan(GV_patientdata(subj).smbgvalues)<.5);
SMBG_times_U_sorted = GV_patientdata(subj).cgm_t(ind);
SMBG_values_U_sorted = GV_patientdata(subj).smbgvalues(ind);

SMBG_timen=SMBG_times_U_sorted(1);
SMBG_valuesn=SMBG_values_U_sorted(1);
if length(SMBG_times_U_sorted) > 2,
    for i=2:length(SMBG_times_U_sorted)
        if ((SMBG_times_U_sorted(i)-SMBG_times_U_sorted(i-1))*1440) > 10
            SMBG_timen=[SMBG_timen; SMBG_times_U_sorted(i)];
            SMBG_valuesn=[SMBG_valuesn; SMBG_values_U_sorted(i)];
        else
            SMBG_timen(end)=[];
            SMBG_valuesn(end)=[];
            SMBG_timen=[SMBG_timen; SMBG_times_U_sorted(i)];
            SMBG_valuesn=[SMBG_valuesn; SMBG_values_U_sorted(i)];
            
        end
    end
    SMBG_time=SMBG_timen;
    SMBG_values=SMBG_valuesn;
else
    SMBG_time=[];
    SMBG_values=[];
end



% %% Retrofit
% 
% [cgm_t cgm_v cgm_interp_time cgm_interp_values]=retrofit_for_module2_Latest_Actionable_Risk_BI(cgm_t, cgm_v, SMBG_time, SMBG_values);
% 
% cgm_time = cgm_interp_time(1:5:end);
% cgm=cgm_interp_values(1:5:end);

%% smoothandfillbyminute
[smoothed_cgm_t_minutes, smoothed_cgm_v_minutes] = smoothandfillbyminute(cgm_t, cgm_v);
% figure(14)
% plot(smoothed_cgm_t_minutes, smoothed_cgm_v_minutes)

%% Final cgm and cgm_time
cgm_time = smoothed_cgm_t_minutes(1:5:end);
cgm = smoothed_cgm_v_minutes(1:5:end);

[cgmd,cgmt] = strtok(floor(cgm_time));
[cgmdu,cgmdi]=unique(datenum(cgmd));


%% Link SMBG to cgm_time -> smbg
smbg = NaN(length(cgm_time),1);
for i = 1:length(SMBG_time),
    [dist,ind] = min(abs(cgm_time-SMBG_time(i)));
    smbg(ind(1)) = SMBG_values(i);
end


%% dCGM
dCGM = cgm-fastingBG;               % (mg/dl), relative to 140 mg/dl


%% meals_mgpmin
meals = GV_patientdata(subj).carbs;
ind_nan = find(isnan(meals) > .5);
ind_notnan = find(isnan(meals) < .5);
% if ~isempty(ind_notnan)
%    for i = 1:length(ind_notnan)
%        if meals(ind_notnan(i)) < .01,
%            disp(['Report of zero-carb meal at ' num2str(cgm_time(ind(i)))]) 
%        end
%    end
% end
meals_mgpmin = 1000*meals/5;    % this needs to be numerical for the net effect calculation
meals_mgpmin(ind_nan) = 0;      % "

%% BOLUS
BOLUS_raw = GV_patientdata(subj).bolus; % U
ind = find(isnan(BOLUS_raw) > .5);
BOLUS_raw(ind) = 0;

% now make a pass and convert all extended boluses into point boluses
BOLUS = zeros(length(BOLUS_raw(:,1)),1);
if BOLUS_raw(1) > 0,
    flag = 1;
    slo = 1;
    shi = 1;
else
    flag = 0;
    slo = -1;
    shi = -1;
end
t = 2;
while t <= length(BOLUS_raw)
    if flag == 1,
        if BOLUS_raw(t) > 0,
            shi = t;
        else
            % tbolus = floor((slo+shi)/2); % puts the discrete bolus at the center of the wave
            tbolus = slo;  % puts the discrete bolus at the beginning of the wave
            BOLUS(tbolus) = sum(BOLUS_raw(slo:shi,1));
            slo = -1;
            shi = -1;
            flag = 0;
        end
    else
        if BOLUS_raw(t) > 0,
            slo = t;
            shi = t;
            flag = 1;
        end
    end
    t = t+1;
end
if flag == 1;
    tbolus = floor((slo+shi)/2);
    BOLUS(tbolus) = sum(BOLUS_raw(slo:shi,1));
end    


%% BSL_PRF_mUpmin, avgbasalprofilerate, avgbasalprofilerate_mUpmin, dUprf, dU, BSL_mUpmin
BSL_PRF_mUpmin = 1000*(GV_patientdata(subj).basalprofile)/60;
dUprf = 1000*(GV_patientdata(subj).basal-GV_patientdata(subj).basalprofile)/60 + BOLUS*1000/5; %mU/min
avgbasalprofilerate = GV_patientdata(subj).meanbasal;
avgbasalprofilerate_mUpmin = 1000*avgbasalprofilerate/60;
dU = dUprf + (BSL_PRF_mUpmin-avgbasalprofilerate_mUpmin);
BSL_mUpmin = 1000*(GV_patientdata(subj).basal)/60;
BASAL = GV_patientdata(subj).basal;

%% BW
BW = GV_patientdata(subj).bw;


%% SI calculation below

% Estimate TDI
TDIest = avgbasalprofilerate*24*2; % U/hr

% Now use regression for SI
SIbase = exp(-6.4417-0.063546*TDIest+0.057944*24*avgbasalprofilerate); % Cf. net effect chapter
si = SIbase;

% si = 1e-4;
pn = patient_number-40100;
save([search_path_input DirStr 'database_for_BROM' num2str(pn) '.mat'],...
    'fastingBG','si','dCGM','dU','avgbasalprofilerate_mUpmin','meals_mgpmin',...
    'BSL_mUpmin','BOLUS','BASAL','cgm','cgm_time','cgmdu','cgmd','smbg','BW','FNEValid','StartDay');