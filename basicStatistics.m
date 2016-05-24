function out = basicStatistics(modelTime,modelData,observationTime,observationData)

% write input timeseries to output structure:
out.modelTime = modelTime;
out.modelData = modelData;

% filter out NaNs and write to output structure:
out.observationTime = observationTime(~isnan(observationData));
out.observationData = observationData(~isnan(observationData));

% interpolate model to observation times:
out.modelAtObsTimes = interp1(modelTime,modelData,out.observationTime);

% compute differences:
out.modelObservationDifference= out.modelAtObsTimes - out.observationData;

% bias:
out.bias = sum(out.modelObservationDifference(~isnan(out.modelObservationDifference)))/length(out.modelObservationDifference(~isnan(out.modelObservationDifference)));

% rmse:
out.rmse = sqrt(nansum(out.modelObservationDifference(~isnan(out.modelObservationDifference)).^2)/length(out.modelObservationDifference(~isnan(out.modelObservationDifference))));

% Pearson correlation coefficient:
out.pearsonCorrCoeff = corr(naninterp(out.modelAtObsTimes),naninterp(out.observationData));

% Pearson correlation coefficient on absolute deviations from zero:
out.pearsonCorrCoeffABS = corr(naninterp(abs(out.modelAtObsTimes)),abs(naninterp(out.observationData)));

end