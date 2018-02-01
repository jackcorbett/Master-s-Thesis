%Import GV2a Pump Data
%% 
%GV2a
[~,SheetNames_GV2a_pump]  = xlsfinfo('GV2_Data_Management_v0.94_A_Pump.xlsm');

nSheets_GV2a_pump = length(SheetNames_GV2a_pump);

for iSheet = 1:nSheets_GV2a_pump
  Name = SheetNames_GV2a_pump{iSheet}; 
  Data = readtable('GV2_Data_Management_v0.94_A_Pump.xlsm','Sheet',Name) ; 
  GV2a_pump(iSheet).Name = Name;
  GV2a_pump(iSheet).Data = Data;
end

%Import General Demographic Info
%%
[~,SheetNames_GV2]  = xlsfinfo('GV2_Data_Management_Demo_Profile_Flow_v0.95.xlsx');

nSheets_GV2 = length(SheetNames_GV2);

for iSheet = 1:nSheets_GV2
  Name = SheetNames_GV2{iSheet}; 
  Data = readtable('GV2_Data_Management_Demo_Profile_Flow_v0.95.xlsx','Sheet',Name) ; 
  GV2(iSheet).Name = Name;
  GV2(iSheet).Data = Data;
end

%Import sheets from demographic info for all subjects
info = GV2(1).Data;
basal_profile = GV2(2).Data;
carb_ratio = GV2(3).Data;
ISF = GV2(4).Data;
goal_glucose = GV2(5).Data;

%GV2a Pump
for i=1:length(SheetNames_GV2a_pump)
    subject_num = str2double(SheetNames_GV2a_pump(i));
    
    %Medical data from data collection/control/experimental periods of study
    subj_data = GV2a_pump(i);

    %Make new folder    
%%
    %Makes new folder for control data
    path = 'C:\\Users\\jpc5s\\Dropbox\\Fall2017\\Optimization\\Project\\GV2_opt_data\\';
    n = num2str(subject_num)
    mkdir(sprintf('%s%s_control',path,n));

    %Basal
    %%
    %Basal Injections
    %Grab UI column to make sure data was collected during control
    basal_UI = subj_data.Data.D_BasalBolus_UI;
    
    %Collect meal times for corr and meal boluses
    basal_time = subj_data.Data.D_BasalBolus_DT;
    basal_time = datetime(basal_time,'ConvertFrom','datenum','Format','M/dd/yyyy'' ''hh:mm:ss a');
    
    %Collect bolus amounts
    basal_vol = subj_data.Data.D_BasalBolus_Vol;
    basal_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    for i=1:length(basal_UI)
        if strcmp(basal_UI{i},'Control') == 1
                        
            %ID
            basal{basal_iter,1} = basal_iter;
            %Time
            basal{basal_iter,2} = basal_time(i);
            %Amount
            basal{basal_iter,3} = basal_vol(i);
            %Created at
            basal{basal_iter,4} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             basal{basal_iter,5} = 0;
            %Subject Number
            basal{basal_iter,6} = subject_num;
            
            %Update index variable
            basal_iter = basal_iter + 1;

        end
    end
    
    %Convert to table and store as csv
    basal_table = cell2table(basal,'VariableNames',{'Id','Readingtakenat','Reading','Createdat','Updatedat','Patient'});
    writetable(basal_table,sprintf('%s%s_control\\basal.csv',path,n),'Delimiter',',')
    
    %Boluses    
    %%
    
    %Boluses
    %Grab UI column to make sure data was collected during control
    b_meal_UI = subj_data.Data.D_MealBolus_UI;
    b_corr_UI = subj_data.Data.D_CorrBolus_UI;
    b_UI = vertcat(b_meal_UI,b_corr_UI);
    
    %Collect meal times for corr and meal boluses
    b_meal_time = subj_data.Data.D_MealBolus_DT;
    b_corr_time = subj_data.Data.D_CorrBolus_DT;
    b_time = vertcat(b_meal_time,b_corr_time);
    b_time = datetime(b_time,'ConvertFrom','datenum','Format','M/dd/yyyy'' ''hh:mm:ss a');
    
    %Collect bolus amounts
    b_meal_vol = subj_data.Data.D_MealBolus_Vol;
    b_corr_vol = subj_data.Data.D_CorrBolus_Vol;
    b_vol = vertcat(b_meal_vol,b_corr_vol);
    bolus_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    %TODO does it matter if they are not in order?
    for i=1:length(b_UI)
        if strcmp(b_UI{i},'Control') == 1
                        
            %ID
            bolus{bolus_iter,1} = bolus_iter;
            %Time
            bolus{bolus_iter,2} = b_time(i);
            %Amount
            bolus{bolus_iter,3} = b_vol(i);
%             %With Meal
%             bolus{bolus_iter,4} = 0;
%             %Created at
            bolus{bolus_iter,5} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             bolus{bolus_iter,6} = 0;
            %Subject Number
            bolus{bolus_iter,7} = subject_num;
            
            %Update index variable
            bolus_iter = bolus_iter + 1;

        end
    end
    
    %Convert to table and store as csv
    bolus_table = cell2table(bolus,'VariableNames',{'Id' 'Readingtakenat' 'Units' 'WithMeal' 'Createdat' 'Updatedat' 'Patient'});
    writetable(bolus_table,sprintf('%s%s_control\\bolus.csv',path,n),'Delimiter',',')
    
    %CGM    
%%
    %CGM Readings
    %Grab UI column to make sure data was collected during control
    cgm_UI = subj_data.Data.D_CGM_UI;
   
    %Collect cgm time
    cgm_time = subj_data.Data.D_CGM_DT;
    cgm_time = datetime(cgm_time,'ConvertFrom','datenum','Format','M/dd/yyyy'' ''hh:mm:ss a');
    
    %Collect cgm values
    cgm_val = subj_data.Data.D_CGM_BG;
    
    %cgm = {'Id','Reading taken at','Reading','Patient','Created at','Updated at','Cgmdatafile'};
    cgm_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    for i=1:length(cgm_UI)
        if strcmp(cgm_UI{i},'Control') == 1
                        
            %ID
            cgm{cgm_iter,1} = cgm_iter-1;
            %Date Time
            cgm{cgm_iter,2} = cgm_time(i);
            %BG
            cgm{cgm_iter,3} = cgm_val(i);
            %Subject Number
            cgm{cgm_iter,4} = subject_num;
%             %Created at
            cgm{cgm_iter,5} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             cgm{cgm_iter,6} = 0;
            %Cgmdatafile
            cgm{cgm_iter,7} = '';
            
            %Update index variable
            cgm_iter = cgm_iter + 1;

        end
    end
    
    %Convert to table and store as csv
    cgm_table = cell2table(cgm,'VariableNames',{'Id','Readingtakenat','Reading','Patient','Createdat','Updatedat','Cgmdatafile'});
    writetable(cgm_table,sprintf('%s%s_control\\cgm.csv',path,n),'Delimiter',',')
    
%Default Basal Pattern    
%%
    %Default Basal Profile
    default_basal_pattern_iter = 1;
    
    for j = 1:height(basal_profile)
        if basal_profile.Subject(j)==subject_num
            
            %Does this need to be Data collection or experimental
            if strcmp(basal_profile.Section{j},'Data Collection') == 1
            
                %ID
                default_basal_pattern{default_basal_pattern_iter,1} = default_basal_pattern_iter;
                %Patient
                default_basal_pattern{default_basal_pattern_iter,2} = basal_profile.Subject(j);
                %Start Time
                default_basal_pattern{default_basal_pattern_iter,3} = datetime(basal_profile.Time(j),'ConvertFrom','datenum','Format','hh:mm:ss a');
                %Rate
                default_basal_pattern{default_basal_pattern_iter,4} = basal_profile.Basal(j);
                %Created at
                default_basal_pattern{default_basal_pattern_iter,5} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
                %Updated at
                default_basal_pattern{default_basal_pattern_iter,6} = '';
                
                %Update index variable
                default_basal_pattern_iter = default_basal_pattern_iter + 1;
            end
        end
    end
    
    %Convert to table and store as csv
    default_basal_pattern_table = cell2table(default_basal_pattern,'VariableNames',{'Id','Patient','Starttime','Rate','Createdat','Updatedat'});
    writetable(default_basal_pattern_table,sprintf('%s%s_control\\default_basal_pattern.csv',path,n),'Delimiter',',')


%Insulin Carb Profile
%%
    %Carb Ratio
    icr_iter = 1;
    
    for j = 1:height(carb_ratio)
        if carb_ratio.Subject(j) == subject_num
            %Does this need to be Data collection or experimental
            if strcmp(carb_ratio.Section{j},'Data Collection') == 1
            
                %ID
                insulin_carb_profile{icr_iter,1} = icr_iter;
                %Patient
                insulin_carb_profile{icr_iter,2} = carb_ratio.Subject(j);
                %Start Time (not working)
                insulin_carb_profile{icr_iter,3} = datetime(str2double(carb_ratio.Time(j)),'ConvertFrom','datenum','Format','hh:mm:ss a');
                %Rate
                insulin_carb_profile{icr_iter,4} = carb_ratio.CR(j);
                %Created at
                insulin_carb_profile{icr_iter,5} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
                %Updated at
                insulin_carb_profile{icr_iter,6} = '';
                
                %Update index variable
                icr_iter = icr_iter + 1;
            end
        end
    end
    
    %Convert to table and store as csv
    insulin_carb_profile_table = cell2table(insulin_carb_profile,'VariableNames',{'Id','Patient','Crtime','CrValue','Createdat','Updatedat'});
    writetable(insulin_carb_profile_table,sprintf('%s%s_control\\insulin_carb_profile.csv',path,n),'Delimiter',',')
    
%Insulin Sensitivity Profile
%%
  %Insulin Sensitivity Profile
    isf_iter = 1;
    
    for j = 1:height(ISF)
        if ISF.Subject(j)==subject_num
            
            %Does this need to be Data collection or experimental
            if strcmp(ISF.Section{j},'Data Collection') == 1
            
                %ID
                insulin_sensitivity_profile{isf_iter,1} = isf_iter;
                %Patient
                insulin_sensitivity_profile{isf_iter,2} = ISF.Subject(j);
                %Start Time (not working)
                insulin_sensitivity_profile{isf_iter,3} = datetime(ISF.Time(j),'ConvertFrom','datenum','Format','hh:mm:ss a');
                %Rate
                insulin_sensitivity_profile{isf_iter,4} = ISF.ICF(j);
                %Created at
                insulin_sensitivity_profile{isf_iter,5} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
                %Updated at
                insulin_sensitivity_profile{isf_iter,6} = '';

                %Update index variable
                isf_iter = isf_iter + 1;
            end
        end
    end
    
    %Convert to table and store as csv
    insulin_sensitivity_profile_table = cell2table(insulin_sensitivity_profile,'VariableNames',{'Id','Patient','Isftime','IsfValue','Createdat','Updatedat'});
    writetable(insulin_sensitivity_profile_table,sprintf('%s%s_control\\insulin_sensitivity_profile.csv',path,n),'Delimiter',',')

%Meal
%%
    %Meals
    %Grab UI column to make sure data was collected during control
    meal_UI = subj_data.Data.D_Meal_UI;
    
    %Collect meal times for corr and meal boluses
    meal_time = subj_data.Data.D_Meal_DT;
    meal_time = datetime(meal_time,'ConvertFrom','datenum','Format','M/dd/yyyy'' ''hh:mm:ss a');
    
    %Collect bolus amounts
    meal_size = subj_data.Data.D_Meal_Size;
    meal_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    for i=1:length(meal_UI)
        if strcmp(meal_UI{i},'Control') == 1
                        
            %ID
            meal{meal_iter,1} = i;
            %Time
            meal{meal_iter,2} = meal_time(i);
            %Carb Amount
            meal{meal_iter,3} = meal_size(i);
%             %Fat Amount
%             meal{meal_iter,4} = 0;            
%             %With Bolus
%             meal{meal_iter,5} = 0;
%             %Created at
            meal{meal_iter,6} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             meal{meal_iter,7} = 0;
            %Subject Number
            meal{meal_iter,8} = subject_num;
            
            %Update index variable
            meal_iter = meal_iter + 1;

        end
    end

    %Convert to table and store as csv
    meal_table = cell2table(meal,'VariableNames',{'Id','Readingtakenat','CarbContent','FatCarbContent','WithBolus','Createdat','Updatedat','Patient'});
    writetable(meal_table,sprintf('%s%s_control\\meal.csv',path,n),'Delimiter',',')


%Meal Type
%%

    %Appears to just be a list of meal times
    %Add info to cell array if it was collected during the control period
    
    mealtype_iter = 1;
    
    for i=1:length(meal_UI)
        if strcmp(meal_UI{i},'Control') == 1
                        
            %ID
            mealtype{mealtype_iter,1} = i;
            %Time
            mealtype{mealtype_iter,2} = meal_time(i);
            %Control or No Control
%             meal{meal_iter,3} = '';
            %Created 
            mealtype{mealtype_iter,4} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             meal{meal_iter,5} = 0;
            %Subject Number
            mealtype{mealtype_iter,6} = subject_num;
            
            %Update index variable
            mealtype_iter = mealtype_iter + 1;
        end
    end

    
    %Convert to table and store as csv
    mealtype_table = cell2table(mealtype,'VariableNames',{'Id','Readingtakenat','ControlorNotControl','Createdat','Updatedat','Patient'});
    writetable(mealtype_table,sprintf('%s%s_control\\mealtype.csv',path,n),'Delimiter',',')

%SMBG
%%
    %SMBG Readings
    %Grab UI column to make sure data was collected during control
    smbg_UI = subj_data.Data.D_SMBG_UI;
   
    %Collect smbg time
    smbg_time = subj_data.Data.D_SMBG_DT;
    smbg_time = datetime(smbg_time,'ConvertFrom','datenum','Format','M/dd/yyyy'' ''hh:mm:ss a');
    
    %Collect smbg readings
    smbg_val = subj_data.Data.D_SMBG_Val;
    
    %Calibration or not
    smbg_cal = subj_data.Data.D_SMBG_Cal;
    
    smbg_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    for i=1:length(smbg_UI)
        %Should this include calibrations or not? currently does not
        if strcmp(smbg_UI{i},'Control') == 1
                        
            %ID
            smbg{smbg_iter,1} = i;
            %Date Time
            smbg{smbg_iter,2} = smbg_time(i);
            %BG
            smbg{smbg_iter,3} = smbg_val(i);
%             %Created at
            smbg{smbg_iter,4} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
%             %Updated at
%             smbg{smbg_iter,5} = 0;
            %Subject Number
            smbg{smbg_iter,6} = subject_num;
            %Cgmdatafile
            smbg{smbg_iter,7} = '';
            
            %Update index variable
            smbg_iter = smbg_iter + 1;

        end
    end

    %Convert to table and store as csv
    smbg_table = cell2table(smbg,'VariableNames',{'Id','Readingtakenat','Reading','Createdat','Updatedat','Patient','Smbgdatafile'});
    writetable(smbg_table,sprintf('%s%s_control\\smbg.csv',path,n),'Delimiter',',')
    
%SMBG Calibrations
%%
    %Calibration or not
    smbg_cal = subj_data.Data.D_SMBG_Cal;
    
    smbgcal_iter = 1;
    
    %Add info to cell array if it was collected during the control period
    for i=1:length(smbg_UI)
        %Should this include calibrations or not? currently does not
        if strcmp(smbg_UI{i},'Control') == 1
            if smbg_cal(i) == 1            
                %ID
                smbgcal{smbgcal_iter,1} = i;
                %Date Time
                smbgcal{smbgcal_iter,2} = smbg_time(i);
                %BG
                smbgcal{smbgcal_iter,3} = smbg_val(i);
                %Created at
                smbg{smbg_iter,4} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
    %             %Updated at
    %             smbg{smbg_iter,5} = 0;
                %Subject Number
                smbgcal{smbgcal_iter,6} = subject_num;
                %SMBGdatafile
                smbgcal{smbg_iter,7} = '';

                %Update index variable
                smbgcal_iter = smbgcal_iter + 1;
            end
        end
    end
    
    %Convert to table and store as csv
    smbgcal_table = cell2table(smbgcal,'VariableNames',{'Id','Readingtakenat','Reading','Createdat','Updatedat','Patient','Smbgdatafile'});
    writetable(smbgcal_table,sprintf('%s%s_control\\smbgcal.csv',path,n),'Delimiter',',')

%Steps
%%
    
    steps = {'','','','','',''};
    
    %Convert to table and store as csv
    steps_table = cell2table(steps,'VariableNames',{'Id','Readingtakenat','Reading','Createdat','Updatedat','Patient'});
    writetable(steps_table,sprintf('%s%s_control\\steps.csv',path,n),'Delimiter',',')
    
%Subject Info
%%

    %Subject Info
    subject_iter = 1;
    
    for j = 1:height(info)
        if strcmp(info.Var1(j),n) == 1
        
            %ID
            subject{subject_iter,1} = subject_iter;
            %Patient
            subject{subject_iter,2} = str2double(info.Var1{j});
            %Age
            subject{subject_iter,3} = str2double(info.Demo{j});
            %Weight
            subject{subject_iter,4} = str2double(info.Var17{j});
            %Hba1c
            subject{subject_iter,5} = str2double(info.Var19{j});
            %Height
            subject{subject_iter,6} = str2double(info.Var16{j});
            %Total Daily Units
            subject{subject_iter,7} = str2double(info.Var21{j});
%             %Subject
%             subject{subject_iter,8} = 0;
%             %Randomize
%             subject{subject_iter,9} = 0;
            %Created at
            subject{subject_iter,10} = datetime('now','Format','M/dd/yyyy'' ''hh:mm:ss a');
            %Updated at
            subject{subject_iter,11} = '';

            %Update index variable
            subject_iter = subject_iter + 1;
       
        end
    end

    %Convert to table and store as csv
    subject_table = cell2table(subject,'VariableNames',{'Id','Patient','Age','Weight','Hba1c','Height','Tdu','Subject','Randomize','Createdat','Updatedat'});
    writetable(subject_table,sprintf('%s%s_control\\subject.csv',path,n),'Delimiter',',')

end
