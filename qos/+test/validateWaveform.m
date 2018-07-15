%% 18-03-05
wv = qes.waveform.flattop(100,1, 5);
seq = qes.waveform.sequence(wv);

chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);

s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;
s.r = [0.021,-0.012,0.009,0.005]; 
s.td = [900,400,150,60]; 
xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

% xfrFunc = com.qos.waveform.XfrFuncShots(0.05,200);
% xfrFunc_f = xfrFunc.inv();

DASequence.xfrFunc = xfrFunc_f;

samples = DASequence.samples();
samples = samples(1,:);
figure();plot(samples);
%% DRAG
carrierFrequency = 0;

wv_ = qes.waveform.gaussian(100,1);
wv = wv_;
wv.carrierFrequency = carrierFrequency;
seq = qes.waveform.sequence(wv);

chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);

samples = DASequence.samples();
figure();plot(samples.');

wv_ = qes.waveform.gaussian(100,1);
wv = wv_.dragify(5);
wv.carrierFrequency = carrierFrequency;
seq = qes.waveform.sequence(wv);

chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);
samples = DASequence.samples();

hold on;plot(samples.');




