function [...
    dSMBG_extended_day,...
    dU_extended_day,...
    bolus_extended_day,...
    basal_extended_day,...
    meal_mgpmin_extended_day,...
    dates_extended_day,...
    siopt,...
    fastingBG,...
    BW,...
    avgbasalprofilerate_mUpmin...
    ] = parseExtendedDaysStep1( search_path_input, patient_number )

disp('Parsing extended days (step 1)...')

% compute the net effect
addpath(search_path_input);
all_data = importdata(['database_for_BROM' num2str(patient_number) '.mat']);

% At this stage don't eliminate any days based on missing CGM data
if isfield(all_data, 'FNEValid') == 1
    FNEValid_orig = all_data.FNEValid;
elseif isfield(all_data, 'FNEValid') == 0
    FNEValid_orig = 0;
end
FNEValid = ones(length(FNEValid_orig),1);
StartDay = all_data.StartDay;

%select the days from the data for the net effect
days_sim = sum(FNEValid);
idx1 = find(all_data.cgmd>=StartDay, 1, 'first');
ind_training_day = zeros(days_sim, 288);
idx2 = 1;
for i=1:length(FNEValid)
    if FNEValid(i)==1
        ind_training_day(idx2,:) = (idx1+(i-1)*288):(idx1+i*288-1);
        idx2 = idx2 + 1;
    end
end

minutes_before = 8*60/5;
minutes_after = 4*60/5;

hours = [];
for i=1:24
    hours = [hours i*ones(1,12)];
end
hours_days =[];
for i=1:days_sim
    hours_days = [hours_days; hours];
end

hours_before = [];
for i=17:24
    hours_before = [hours_before i*ones(1,12)];
end

hours_after = [];
for i=1:4
    hours_after = [hours_after i*ones(1,12)];
end
hours_total_day =[];
for i=1:days_sim
    hours_total_day = [hours_total_day; [hours_before hours_days(i,:) hours_after]];
end
ind_total_day = [];
for i=1:days_sim
    ind_total_day = [ind_total_day; [[ind_training_day(i,:) - minutes_before:ind_training_day(i,:) - 1] ind_training_day(i,:)  [ind_training_day(i,end)+1:ind_training_day(i,end) + minutes_after]]];
end

% Get SI, fastingBG, BW
nomsi = all_data.si;
siopt = nomsi;
fastingBG = all_data.fastingBG;
BW = all_data.BW;
avgbasalprofilerate_mUpmin = all_data.avgbasalprofilerate_mUpmin;

% Net effect calculations
dSMBG_extended_day = [];
dU_extended_day =[];
bolus_extended_day = [];
basal_extended_day = [];
meal_mgpmin_extended_day = [];
dates_extended_day = [];

%Bug Description: ind_total_day(1,:) goes from 257-688 where smbg and all
%others go from 1-546 this above issue is caused by throwing out the first
%day in the data set

for i=1:days_sim
    %   disp(['i=' num2str(i)]);
    
    % Extract
    dSMBG_extended = all_data.smbg(ind_total_day(i,:))-fastingBG;
    dU_extended = all_data.dU(ind_total_day(i,:));
    bolus_extended = all_data.BOLUS(ind_total_day(i,:));
    basal_extended = all_data.BASAL(ind_total_day(i,:));
    meal_mgpmin_extended = all_data.meals_mgpmin(ind_total_day(i,:));
    dates_extended = all_data.cgmd(ind_total_day(i,:));
    
    % Add to the record
    dSMBG_extended_day = [dSMBG_extended_day dSMBG_extended];
    dU_extended_day =[dU_extended_day dU_extended];
    bolus_extended_day = [bolus_extended_day bolus_extended];
    basal_extended_day = [basal_extended_day basal_extended];
    meal_mgpmin_extended_day = [meal_mgpmin_extended_day meal_mgpmin_extended];
    dates_extended_day = [dates_extended_day dates_extended];
    
end