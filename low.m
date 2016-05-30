function y = doFilter(x)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.0 and the DSP System Toolbox 9.2.
% Generated on: 14-May-2016 17:29:16

persistent Hd;

if isempty(Hd)
    
    N     = 4;     % Order
    Fpass = 0.15;  % Passband Frequency
    Fstop = 0.2;   % Stopband Frequency
    
    h = fdesign.lowpass('n,fp,fst', N, Fpass, Fstop);
    
    Hd = design(h, 'equiripple', ...
        'StopbandShape', 'flat');
    
    
    
    set(Hd,'PersistentMemory',true);
    
end

y = filter(Hd,x);
