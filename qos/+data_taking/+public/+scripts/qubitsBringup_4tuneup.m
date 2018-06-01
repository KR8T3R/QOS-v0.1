% bring up qubits - tuneup
% Yulin Wu, 2017/3/11
q = 'q1';

tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');
% tuneup.optReadoutFreq('qubit',q,'gui',true,'save','askMe');
% tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui','true','save','askMe');
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',31,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');

%% fully auto callibration
qubits = {'q9','q7','q5','q6','q8'};%'q9','q7',,'q8'
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000);
    tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
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
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11'};
tuneup.iq2prob_01_parallel('qubits',qubits,'numSamples',1e4,'gui',false,'save',false);
%%
tuneup.APE('qubit','q7',...
      'phase',-pi:pi/40:pi,'numI',4,...
      'gui',true,'save',true);
%%
setQSettings('r_avg',1500);
tuneup.DRAGAlphaAPE('qubit','q11','alpha',[-1:0.05:1.5],...
    'phase',0,'numI',10,...
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
     
%     q = 'q1';
%     s.r = [0.025,-0.019,0.012]; 
%     s.td = [900,500,250]; 
    
%     q = 'q1';
%     s.r = [0.017];
%     s.td = [1000];
    
% %     q = 'q2';
% %     s.r = [0.013]; 
% %     s.td = [833]; 
%     
%     q = 'q2';
%     s.r = [0.0135, -0.003, 0.0035]; 
%     s.td = [833, 400, 200]; 

    
% %     q = 'q3';
% %     s.r = [0.035,-0.017,-0.013,0.023]; 
% %     s.td = [900,400,200,100]; 
    
%         q = 'q3';
%     s.r = [0.021]; 
%     s.td = [900]; 

%     q = 'q4';
%     s.r = [0.0135,-0.005,0.017]; 
%     s.td = [900,300,80]; 

%     q = 'q5';
%     s.r = [0.0125,0.01]; 
%     s.td = [900,70]; 
%     q = 'q6';
%     s.r = [0.0205,0.012]; 
%     s.td = [900,100]; 

%     q = 'q7';
%     s.r = [0.0093,0.008]; 
%     s.td = [900,80]; 

%       q = 'q8';
%       s.r = [0.011,0.007]; 
%       s.td = [900,100]; 

%     q = 'q9';
%     s.r = [0.011,-0.0025,0.003]; 
%     s.td = [700,400,70]; 

%       q = 'q10';
%       s.r = [0.013,0.007]; 
%       s.td = [900,100]; 
      
      q = 'q11';
      s.r = [0.021,-0.012,0.009,0.005]; 
      s.td = [900,400,150,60]; 

    xfrFunc = qes.util.xfrFuncBuilder(s);
    xfrFunc_inv = xfrFunc.inv();
    xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
    xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

%     fi = fftshift(qes.util.fftFreq(20000,1));
%     fsamples = xfrFunc_inv.samples_t(fi);
%      figure();
%     plot(fi, fsamples(1:2:end),'-r');
%     fsamples = xfrFunc.samples_t(fi);
%     hold on; plot(fi, fsamples(1:2:end),'-g');

delayTime = [0:50:2000];
setQSettings('r_avg',3000);
zPulseRingingPhase('qubit',q,'delayTime',delayTime,...
       'xfrFunc',[xfrFunc_f],'zAmp',-2.5e4,'s',s,...
       'notes','','gui',true,'save',true);
%%
[sOpt,LPFBW] = zPulseXfrFunc('qubit','q1','delayTime',[30,100,300,700,1500],...
       'maxFEval',50,'numTerms',1,'rAmp0',[0.01],'td0',[700],'zAmp',-3e4);
%%
sqc.util.setZXfrFunc(q,xfrFunc_f);
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

