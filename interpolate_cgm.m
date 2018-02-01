function [icgm, gapmax] = interpolate_cgm(cgm_dt_hist)

% Assumes that the last entry of cgm_dt_hist is not empty!!

T = length(cgm_dt_hist);
icgm = cgm_dt_hist;
gapmax = 0;
t = 1;
if isnan(cgm_dt_hist(1,1))
    
    gap = 0;
    not_done = 1;
    while not_done && t < T
        gap = gap + 1;
        t = t+1;
        if ~isnan(cgm_dt_hist(t,1))
            not_done = 0;
        end
    end
    if gap > gapmax,
        gapmax = gap;
    end
    icgm(1:t-1,1) = cgm_dt_hist(t,1)*ones(t-1,1);
    
end


while t < T,
    
    while t < T && ~isnan(cgm_dt_hist(t,1))
        t = t+1;
    end
    
    tfirstgappoint = t;
    gap = 0;
    not_done = 1;
    while not_done && t < T
        gap = gap + 1;
        t = t+1;
        if ~isnan(cgm_dt_hist(t,1))
            not_done = 0;
        end
    end
    if gap > gapmax,
        gapmax = gap;
    end
    
    % Now interpolate
    for i = tfirstgappoint:t-1
        icgm(i,1) = cgm_dt_hist(tfirstgappoint-1,1) + (i-(tfirstgappoint-1))*(cgm_dt_hist(t,1)-cgm_dt_hist(tfirstgappoint-1,1))/(gap+1);
    end
    
end
