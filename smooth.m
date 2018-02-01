%
% smooth - simple centered moving average filter
%
% inputs:
%
%   X = vector, no NaN entries allowed
%   T = width of moving average window
%
% outputs:
%
%   Y = vector of same dimensions as X whose
%       entries are the corresponding moving
%       average values
%
% notes:
%
% 1. This function can be used for example to smooth
%    imprecision in a CGM signal.
%
% 2. Window segments that extend beyond the indices
%    of X are dropped, so e.g. Y(1) = sum(X(1:T))/T
%


function [Y] = smooth(X,T)

Y = [];
if ~isempty(X),
    if ~isnan(sum(X)),
        n = length(X);
        if T >= 1,
            if T <= n,
                Y = X;
                for i = 1:n,
                    ilo = max(1,i-T);
                    ihi = min(n,i+T);
                    den = ihi-ilo+1;
                    Y(i) = sum(X(ilo:ihi))/den;
                end
            else
                disp('error in smooth_TZ: T > length(X)')
            end
        else
            disp ('error in smooth_TZ: T < 1')
        end
    else
        disp('error in smooth_TZ: NaN entries in X')
    end
else
    disp('error in smooth_TZ: X is empty')
end


