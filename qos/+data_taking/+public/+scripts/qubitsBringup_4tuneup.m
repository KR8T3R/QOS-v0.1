% bring up qubits - tuneup
% Yulin Wu, 2017/3/11
q = 'q7';

tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');
tuneup.optReadoutFreq('qubit',q,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');

% tuneup.correctf01bySpc('qubit',q,'gui',true,'save','askMe'); % measure f01 by spectrum
tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save','askMe');
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');

tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,...
       'gui','true','save',false);
%% fully auto callibration
qubits = {'q9','q7','q5','q6','q8'};%'q9','q7',,'q8'
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000);
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
end
%%
qubits = {'q7','q9','q8'};
tuneup.iq2prob_01_multiplexed('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
%%
tuneup.APE('qubit','q8',...
      'phase',-pi:pi/40:pi,'numI',4,...
      'gui',true,'save',true);
%%
setQSettings('r_avg',5000);
tuneup.DRAGAlphaAPE('qubit','q8','alpha',[0:0.05:2],...
    'phase',0,'numI',30,...
    'gui',true,'save',true);
%%
photonNumberCal('qubit','q1',...
'time',[-500:100:2.5e3],'detuning',[0:1e6:25e6],...
'r_amp',2500,'r_ln',[],...
'ring_amp',5000,'ring_w',200,...
'gui',true,'save',true);
%%
zDelay('zQubit','q5','xyQubit','q5','zAmp',3e4,'zLn',[],'zDelay',[-80:1:80],...
       'gui',true,'save',true);
%%
setQSettings('r_avg',5000);
% delayTime = [[0:1:20],[21:2:50],[51:5:100],[101:10:500],[501:50:3000]];
delayTime = [-300:10:2e3];
zPulseRipple('qubit','q7',...
        'delayTime',delayTime,...
       'zAmp',7e3,'gui',true,'save',true);
%%
    s = struct();
    s.type = 'function';
    s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
    s.bandWidht = 0.25;
%     s.r = [0.0113]; % q8
%     s.td = [600]; % q8
%     s.r = [0.0140]; % q6
%     s.td = [365];  % q6
    
    s.r = [0.0130]; % q5
    s.td = [600];  % q5

%     s.r = 0.011; % q7
%     s.td = 765;  % q7
    
%     s.r = 0.011; % q7
%     s.td = 765;  % q7

    xfrFunc = qes.util.xfrFuncBuilder(s);
    xfrFunc_inv = xfrFunc.inv();
    xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
    xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

%     fi = fftshift(qes.util.fftFreq(6000,1));
%     fsamples = xfrFunc_inv.eval(fi);
%     figure();
%     plot(fi, fsamples(1:2:end),'-r');
%     fsamples = xfrFunc_f.eval(fi);
%     hold on; plot(fi, fsamples(1:2:end),'-b');

q = 'q2';

delayTime = [0:100:2e3];
setQSettings('r_avg',5000);
zPulseRipplePhase('qubit',q,'delayTime',delayTime,...
       'xfrFunc',[],'zAmp',-20e3,'s',s,...
       'notes','','gui',true,'save',true);
%%
s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;

% s.r = [0.0130]; % q8
% s.td = [464]; % q8

s.r = [0.0130]; % q6
s.td = [260];  % q6

xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

q = 'q6';
sqc.util.setZXfrFunc(q,xfrFunc_f);
%%
sqc.measure.gateOptimizer.czOptPulseCal_2({'q9','q8'},false,4,15,1500, 40);
%%
q = 'q9';
tuneup.iq2prob_01('qubit',q,'numSamples',2e4,'gui',true,'save',true);
sqc.measure.gateOptimizer.xyGateOptWithDrag(q,100,20,1000,30);
setQSettings('r_avg',2000);
tuneup.iq2prob_01('qubit',q,'numSamples',2e4,'gui',true,'save',true);

