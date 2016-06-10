warning off

% remove all variability with periods above 
% (more precisely: variability of 40 normalized units will have 1e-3 = -3dB the amplitude of the initial signal):
cutOffPeriodInNormalizedUnits=20;

cutOffFrequency = 1/(cutOffPeriodInNormalizedUnits/2)

xvec = 0:2:1200;
xr = random('Normal',0,0.002,size(xvec));
yvec = sin(0.0001 *xvec).*exp(-0.0001 * (xvec-100).^2) + xr;


plot(xvec,yvec)


% design 4th-order ( = filter transfer function goes as 1/4th order polynomial p(s)) Butterworth filter
% (the higher the order the sharper the cutoff at cutOffFrequency):
% approximately:
% H(s) = 1/(1 + (frequency / cutoffFrequency)^(2*filterOrder))
filterOrder = 4;
h=fdesign.highpass('N,F3dB',filterOrder,cutOffFrequency);
d1 = design(h,'butter');

% perform filtering:
HighFrequencyPart = filtfilt(d1.sosMatrix,d1.ScaleValues,...
    naninterp(yvec));

figure(1);clf
subplot(3,1,1)
plot(xvec,yvec,'b',xvec,HighFrequencyPart,'-c',xvec,yvec-HighFrequencyPart,'-r')

% remove low frequencies and add high-pass filtered data to output
% structure:
% y_hf = y - lowFrequencyPart;
subplot(3,1,2)
plot(xvec,yvec-HighFrequencyPart,'-r')

subplot(3,1,3)
ffty = fft_h(HighFrequencyPart);
plot(ffty.period,ffty.power,'-k')
xlim([0 2*cutOffPeriodInNormalizedUnits])
