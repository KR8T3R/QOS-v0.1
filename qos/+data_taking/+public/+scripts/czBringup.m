% CZ bring up:
%%
czLength=200;
czAmp=[3.06e4:20:3.12e4];  % for q5-q6: [-4750:10:-4.5e3]
setQSettings('r_avg',5000);
acz1=acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','1',...
       'notes','','gui',true,'save',true);
acz0=acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','0',...
       'notes','','gui',true,'save',true);
cz0data=unwrap(acz0.data{1,1});
cz1data=unwrap(acz1.data{1,1});
ff0=polyfit(czAmp,cz0data,2);
ff1=polyfit(czAmp,cz1data,2);
if cz1data(1)>cz0data(1)
ff=ff1-ff0;

else
ff=-ff1+ff0;
end
figure;plot(czAmp,polyval(ff0,czAmp),'--b',czAmp,polyval(ff1,czAmp),'--r',...
    czAmp,cz0data,'.b',czAmp,cz1data,'.r',...
    czAmp,polyval(ff,czAmp),'-g',...
    czAmp,ones(1,length(czAmp))*pi,':k',czAmp,-ones(1,length(czAmp))*pi,':k');
ff(3)=ff(3)-pi;
rd=roots(ff);
czamp=rd(find(rd>czAmp(1)&rd<czAmp(end)));
sprintf('%.4e',czamp)
%%
setQSettings('r_avg',5000);
tuneup.czAmplitude('controlQ','q7','targetQ','q6',...
    'notes','','gui',true,'save',true);

%% check |11> -> |02> state leakage, method: prepare |11>, apply CZ, measure P|0?>
setQSettings('r_avg',5000);
acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','P',...
       'czLength',[60:10:350],'czAmp',[2.55e4:100:2.95e4],'cState','0',...
       'notes','','gui',true,'save',true);
%% Tomography
setQSettings('r_avg',5000);
CZTomoData = Tomo_2QProcess('qubit1','q5','qubit2','q6',...
       'process','CZ',...
       'notes','','gui',true,'save',true);
toolbox.data_tool.showprocesstomo(CZTomoData,CZTomoData)
%%
setQSettings('r_avg',1000);
temp.czRBFidelityVsPhase('controlQ','q9','targetQ','q8',...
      'phase_c',[-pi:2*pi/10:pi],'phase_t',[-pi:2*pi/10:pi],...
      'numGates',4,'numReps',20,...
      'notes','','gui',true,'save',true);
%%
sqc.measure.gateOptimizer.czOptPhase({'q7','q8'},4,20,1500, 50);
%%
qc.measure.gateOptimizer.czOptPhaseAmp({'q7','q8'},4,20,1500, 100);
%%
setQSettings('r_avg',1000);
temp.czRBFidelityVsPlsCalParam('controlQ','q7','targetQ','q8',...
       'rAmplitude',[-0.02:0.005:0.03],'td',[464],'calcControlQ',false,...
       'numGates',4,'numReps',20,...
       'notes','','gui',true,'save',true);
%% two qubit gate benchmarking
setQSettings('r_avg',1000);
numGates = [1:2:11];
[Pref,Pi] = randBenchMarking('qubit1','q9','qubit2','q8',...
       'process','CZ','numGates',numGates,'numReps',40,...
       'gui',true,'save',true);
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, mean(Pref,1), mean(Pgate, 1),2, 'CZ');
%%
controlQ = 'q7';
targetQ = 'q8';
setQSettings('r_avg',5000);
czDetuneQPhaseTomo('controlQ',controlQ,'targetQ',targetQ,'detuneQ','q6',...
      'phase',[-pi:2*pi/30:pi],'numCZs',1,... % [-pi:2*pi/10:pi]
      'notes','','gui',true,'save',true);
%%
phase = tuneup.czDetuneQPhaseTomo('controlQ',controlQ,'targetQ',targetQ,'detuneQ','q6',...
        'maxFEval',40,...
       'notes','','gui',true,'save',true);