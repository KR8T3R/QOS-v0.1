%% 18-03-05
% [step 1] create the waveforms
wv1 = qes.waveform.flattop(100,1, 5);
wv2 = qes.waveform.spacer(200);
wv3 = qes.waveform.gaussian(50,1);
wv4 = qes.waveform.cos(30,1.5);

% [step 2] make a sequence
seq = qes.waveform.sequence(wv1);
seq = [seq,wv2,wv3,wv4];

% [step 3] make a DA sequence and mount calibration settings,
% Note: calibration settings are hardware channel specific, that's why they
% can not be set at step 1 or step 2: while a sequence may be used anywhere,
% even shared between channels, a DASequence is bounded to a specific
% hardware channel.
chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);
% set transfer function, in production, it is done like this:
% DASequence.xfrFunc = TheDAChannel.xfrFunc;
% DASequence.padLength = TheDAChannel.padLength;
% the following is just for this demo
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        s.r = [0.021,-0.012,0.009,0.005]; 
        s.td = [900,400,150,60]; 
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFuncLPF = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFuncLPF.add(xfrFunc_inv);
        % or
        % xfrFunc = com.qos.waveform.XfrFuncShots([0.02,0.005],[1200,300]);
        % xfrFunc_f = xfrFunc.inv();

        DASequence.xfrFunc = xfrFunc_f;
        
% [step 4] calculate time samples
samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
figure();plot(samples);

%% 
% numeric waveform test
modelSamples = [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0];
wv1 = qes.waveform.numericT(100,2,modelSamples);
% make a sequence
seq = qes.waveform.sequence(wv1);

% make a DA sequence and mount calibration settings,
% calibration settings are hardware specific
chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);

samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
figure();plot(samples);

% old version:
% %%
% padLength = 100;
% com.qos.waveform.Waveform.setPadLength(padLength);
% %%
% % validate waveform phase
% g1 = qes.waveform.gaussian(400,1);
% g2 = qes.waveform.gaussian(600,1);
% g3 = qes.waveform.gaussian(200,1);
% 
% gc1 = [g1,g2];
% gc = [0.5*gc1,g3,g1];
% 
% % gc = 0.5*gc;
% 
% gc.carrierFrequency = 0.1;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t,v(1,:));
% gc1.delete;
% gc.delete;
% %%
% g1 = qes.waveform.rect(100,1);
% gc = [qes.waveform.sequence(),g1];
% gFilter = com.qos.waveform.XfrFuncGaussianFilter(0.05);
% % gc.xfrFunc = gFilter.inv();
% gc.xfrFunc = gFilter;
% 
% % gc.carrierFrequency = 0.1;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:));
% gc.delete;
% %%
% cacheSize = com.qos.waveform.Waveform.getCacheSize()
% %%
% g1 = qes.waveform.rr_ring(1000, 1, 10, 1, 100);
% gc = [qes.waveform.sequence(),g1];
% gc.carrierFrequency = 0.05;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:)); %% carrierFrequency to be tested in 
% 
% %% derivative waveform
% df = 0.05;
% g1 = qes.waveform.gaussian(100,1);
% gc = [qes.waveform.sequence(),g1];
% v = gc.samples();
% 
% g1d = g1.deriv();
% gcd = [qes.waveform.sequence(),g1d];
% gcd.carrierFrequency = 0;
% vd = gcd.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:),...
%     t-padLength,vd(1,:)); %% carrierFrequency to be tested in 
% 
% %%
% g = qes.waveform.acz(100);
% t = -10:0.2:110;
% figure();plot(t,g(t));


