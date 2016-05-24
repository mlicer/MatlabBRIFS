function rr = sta_vs_lta(data,lta,sta)

data_lta = smooth(abs(data),lta,'sgolay');
data_sta = smooth(abs(data),sta,'sgolay');
rr = data_sta./data_lta;