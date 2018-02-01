%Read in DP3_database#####.mat files and create single struct 

GV_patientdata = struct();
subjects = [40101,40105,40106];
%excluded: 40103,40108,,40108,40109,40110,40112,40115,40122,40123,40301,40303,40313,40315,40316,40317,40318,40320,40322,40324
for n=1:max(subjects)-40100%length(subjects)
    subject_num = n+40100%subjects(n);
    if ~isempty(subjects(subjects==subject_num))
        load(['.\GV_Control\',num2str(subject_num),'_control\DP3_database',num2str(subject_num)])
        load(['.\GV_Control\',num2str(subject_num),'_control\database_for_BROM',num2str(subject_num),'.mat'])

        GV_patientdata(n).subj = patient_number;
        GV_patientdata(n).cgm_t = cgm_time;
        GV_patientdata(n).cgm_v = cgm;
        GV_patientdata(n).carbs = meals_mgpmin/1000*5;
        GV_patientdata(n).basal = BASAL*12;
        GV_patientdata(n).bolus = BOLUS;
        GV_patientdata(n).bolus(isnan(GV_patientdata(n).bolus)) = 0;
        GV_patientdata(n).basalprofile = BSL_PRF_mUpmin/1000*60;
        GV_patientdata(n).meanbasal = avgbasalprofilerate_mUpmin/1000*60;
        GV_patientdata(n).differentialprofileinsulin = (BSL_PRF_mUpmin/1000*60)-(avgbasalprofilerate_mUpmin/1000*60);
        GV_patientdata(n).bw = BW;
        GV_patientdata(n).calibrationvalues = [];
        GV_patientdata(n).smbgvalues = smbg;
        GV_patientdata(n).ISFprofile = ISF_PRF;
        GV_patientdata(n).ICRprofile = ICR_PRF;
    end
end
save('.\GV_Control\GV_patientdata.mat','GV_patientdata')