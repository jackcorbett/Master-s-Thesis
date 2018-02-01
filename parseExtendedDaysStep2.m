function [...
    dCGM_extended_day,...
    datesValidCGM_extended_day...
    ] = parseExtendedDaysStep2( search_path_input, patient_number )

disp('Parsing extended days (step 2)...')

% compute the net effect
addpath(search_path_input);
all_data = importdata(['database_for_BROM' num2str(patient_number) '.mat']);

% At this stage don't eliminate any days based on missing CGM data
if isfield(all_data, 'FNEValid') == 1
    FNEValid_orig = all_data.FNEValid;
elseif isfield(all_data, 'FNEValid') == 0
    FNEValid_orig = 1;
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


% Get fastingBG
fastingBG = all_data.fastingBG;

% Net effect calculations
dCGM_extended_day = [];
datesValidCGM_extended_day = [];

for i=1:days_sim
    
    % Extract
    dCGM_extended = all_data.cgm(ind_total_day(i,:))-fastingBG;
    datesValidCGM_extended = all_data.cgmd(ind_total_day(i,:));
    
    % Add to the record
    dCGM_extended_day = [dCGM_extended_day dCGM_extended];
    datesValidCGM_extended_day = [datesValidCGM_extended_day datesValidCGM_extended];
end