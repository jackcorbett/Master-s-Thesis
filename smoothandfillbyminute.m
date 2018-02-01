function [smoothed_cgm_t_minutes, smoothed_cgm_v_minutes] = smoothandfillbyminute(cgm_t, cgm_v)

[cgm_t, ind] = sort(cgm_t);
cgm_v = cgm_v(ind);

begin_minute = round(cgm_t(1)*1440);
end_minute = round(cgm_t(end)*1440);
cgm_time_relative_minutes = [0:(end_minute-begin_minute)]';
cgm_value_relative_minutes = NaN(end_minute-begin_minute+1,1);

for i = 1:length(cgm_t),
    ind = round(cgm_t(i)*1440-begin_minute)+1;
    cgm_value_relative_minutes(ind) = cgm_v(i);
end

[interpolated_cgm_value_relative_minutes, maxgap] = interpolate_cgm(cgm_value_relative_minutes);

% smoothed_cgm_v_minutes = NaN(length(cgm_time_relative_minutes),1);
% pp = csaps_octave(cgm_time_relative_minutes,interpolated_cgm_value_relative_minutes,0.99999);
% for i = 1:length(cgm_time_relative_minutes)
%     smoothed_cgm_v_minutes(i,1) = ppval(pp,cgm_time_relative_minutes(i));
% end

smoothed_cgm_v_minutes = smooth(interpolated_cgm_value_relative_minutes,10);
smoothed_cgm_t_minutes = (cgm_time_relative_minutes + begin_minute)/1440;
