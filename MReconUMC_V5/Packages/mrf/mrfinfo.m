function scaninfo = mrfinfo(MR)

scaninfo=struct();
scaninfo.TR=MR.Parameter.Scan.TR;
scaninfo.TE=MR.Parameter.Scan.TE;
scaninfo.Gss=MR.Parameter.GetValue('GR`s_ex:str');
scaninfo.RFdur=MR.Parameter.GetValue('RF`ex:dur');
%scaninfo.rfscale=MR.Parameter.GetValue('`UGN1_TOM_mrf_fascaling');
scaninfo.PhaseCycling='no';
scaninfo.PhaseCycling='yes';

if strcmpi(MR.Parameter.GetValue('RF`ex:shape'),'sg_100_100_0');
    scaninfo.rfshape=[0, 413, 859, 1337, 1847, 2389, 2962, 3568, 4204, 4870, ...
	5565, 6288, 7038, 7814, 8613, 9435, 10277, 11138, 12015, 12906, ...
	13809, 14721, 15640, 16563, 17487, 18409, 19327, 20237, 21136, 22023, ...
	22892, 23742, 24570, 25372, 26146, 26889, 27598, 28271, 28905, 29497, ...
	30046, 30549, 31005, 31411, 31767, 32070, 32320, 32515, 32655, 32739, ...
	32767, 32739, 32655, 32515, 32320, 32070, 31767, 31411, 31005, 30549, ...
	30046, 29497, 28905, 28271, 27598, 26889, 26146, 25372, 24570, 23742, ...
	22892, 22023, 21136, 20237, 19327, 18409, 17487, 16563, 15640, 14721, ...
	13809, 12906, 12015, 11138, 10277, 9435, 8613, 7814, 7038, 6288, ... 
	5565, 4870, 4204, 3568, 2962, 2389, 1847, 1337, 859, 413, ...
	0];
end

if strcmpi(MR.Parameter.GetValue('RF`ex:shape'),'sg_200_100_0');
    scaninfo.rfshape=[0, -413, -852, -1313, -1789, -2272, -2754, -3228, -3684, -4111,...
    -4502, -4845, -5131, -5349, -5490, -5546, -5507, -5366, -5116, -4751,...
	-4267, -3661, -2931, -2076, -1098, 0, 1214, 2536, 3961, 5477, ...
	7074, 8740, 10461, 12223, 14010, 15805, 17592, 19353, 21071, 22728, ...
	24308, 25794, 27170, 28422, 29536, 30500, 31304, 31939, 32397, 32674, ...
	32767, 32674, 32397, 31939, 31304, 30500, 29536, 28422, 27170, 25794, ...
	24308, 22728, 21071, 19353, 17592, 15805, 14010, 12223, 10461, 8740, ...
	7074, 5477, 3961, 2536, 1214, 0, -1098, -2076, -2931, -3661, ...
	-4267, -4751, -5116, -5366, -5507, -5546, -5490, -5349, -5131, -4845, ...
	-4502, -4111, -3684, -3228, -2754, -2272, -1789, -1313, -852, -413, ...
	0];


% END
end