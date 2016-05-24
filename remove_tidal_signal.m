function timeseries_out = remove_tidal_signal(timeseries_in, dt, T)
% removes tidal frequency band from the signal spectrum and return detided
% signal:
% timeseries_in: input signal
% dt: temporal resolution (default 1h)
% T: filter half-amp period [hrs] (Default T=33h)

timeseries_out=pl66tn(timeseries_in, dt, T);