% bring up qubits
% Yulin Wu, 2017/3/11
%%
cd('D:\QOSv1.1\qos');
rmpath(genpath('D:\QOS\qos'));
addpath('D:\QOSv1.1\qos\dlls');
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
% padLength = 2e3;
% com.qos.waveform.Waveform.setPadLength(padLength);
clc;
app.RE
%%
% qes.util.copySession([],'s170626');
% sqc.util.resetQSettings();
%%
qNames = allQNames();
% readoutFreqs = getQSettings('r_fr');
%% just in case the hardware dose not startup with zero dc output, we set the output of qubit dc channels to zero
% setQSettings('zdc_amp',0);
qNames = allQNames();
for ii = 1:numel(qNames)
    % set to the dc value in registry:
	setZDC(qNames{ii});
    % or set to an specifice value
    % setZDC(qNames{ii},0);
end
%% s21 vs power with network analyzer
for qubitIndex = 1:9
data_taking.public.s21_scan_networkAnalyzer(... % 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-0.5e6,'stopFreq',readoutFreqs(qubitIndex)+2e6,...
      'numFreqPts',501,'avgcounts',30,...
      'NAPower',[-30:1:20],'bandwidth',30e3,...
      'notes','attenuation:30dB','gui',true,'save',true);
end
%% s21 vs qubit dc bias with network analyzer
for qubitIndex = 1:1
s21_zdc_networkAnalyzer('qubit',qNames{qubitIndex},...% 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-0.1e6,'stopFreq',readoutFreqs(qubitIndex)+1e6,...
      'numFreqPts',51,'avgcounts',20,'NApower',-10,...
      'biasAmp',[-3.2e4:200:3.2e4],'bandwidth',30e3,...
      'gui',true,'save',true);
end
%% s21 with DAC, a coarse scan to find all the qubit readoutFreqs
s21_rAmp('qubit','q7','freq',[6.78065e9-3e6:0.02e6:6.78065e9+3e6],'amp',6000,...
      'notes','','gui',true,'save',true);
%% finds all qubit readoutFreqs automatically by fine s21 scan, session/public/autoConfig.readoutResonators.* has to be properly set for it to work
[readoutFreqs, pkWithd] = auto.qubitreadoutFreqs();
% after this you need to order readoutFreqs in accordance with qNames
% the upadate the readoutFreqs value to r_fr in registry for each qubit:
%%
for ii = 1:numel(qNames)
    % r_fr, the qubit dip frequency, it's exact value changes with qubit state and readout power,
    % the value of r_fr is just a reference frequency for automatic
    % routines, a close value is sufficient.
    setQSettings('r_fr',readoutFreqs(ii),qNames{ii});
    % also set r_freq is the frequency of the readout pulse, it is slightly
    % different than the qubit dip frequency after optimization, but at the beginning of the
    % meausrement, set it to the qubit dip frequency is OK.
    setQSettings('r_freq',readoutFreqs(ii),qNames{ii});
end
%%  s21 vs power with DAC to finds the dispersive shift
q = 'q11';
setQSettings('r_avg',500);
amp = logspace(log10(700),log10(15000),20);
% amp = getQSettings('r_amp',q);
rfreq = getQSettings('r_freq',q);
freq = rfreq-1.5e6:0.15e6:rfreq+1e6;
s21_rAmp('qubit',q,'freq',freq,'amps',amp,...
      'notes','','gui',true,'save',true);
%%
q = 'q11';
rfreq = getQSettings('r_freq',q);
freq = rfreq-0.7e6:0.1e6:rfreq+0.3e6;
s21_zdc('qubit', q,...
      'freq',freq,'amp',[-3e4:3e3:3e4],...
      'gui',true,'save',true);
%%
s21_zpa('qubit', 'q4',...
      'freq',[readoutFreqs(4)-2.2e6:0.15e6:readoutFreqs(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);  
%% to find all the peaks
    % export data with DataViewer
    yinDB = 20*log10(abs(y)/max(abs(y)));
    [pks,locs,w,p] = findpeaks(-yDB,x,'SortStr','none','NPeaks',12,...
        'MinPeakDistance',15e6,...
        'MinPeakHeight',4,...
        'WidthReference','halfheight');
    figure();plot(x/1e9,yDB);hold on;plot(locs/1e9,-pks,'*');
%%
s21_01('qubit',q,'freq',[],'notes','','gui',true,'save',true);
%% hint: you can use this to measure IQ stability over a long duration of time
IQvsReadoutDelay('qubit','q1','delay',[36*ones(1,500)],...
    'notes','','gui',true,'save',true);

