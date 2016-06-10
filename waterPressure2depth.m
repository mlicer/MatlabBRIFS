function waterPressure2depth(struct)

fields = fieldnames(struct);

rho_sea = 1028; 
g = 9.86;
p0 = 1013;

for k = 1:numel(fields)
    if struct.(stations{k}).dataExists && any(struct.(stations{k}).(fieldname))
    struct.WTR_DEPTH =  (struct.(stations{k}).WTR_PRE*100 - p0) ./ (rho_sea * g);
end