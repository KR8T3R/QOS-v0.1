% tomography and randomized bnenchmarking
%%
q = 'q5';
setQSettings('r_avg',10000);
state = '|1>';
data = Tomo_1QState('qubit',q,'state',state,'gui',true,'save',true);
% rho = sqc.qfcns.stateTomoData2Rho(data);
% h = figure();bar3(real(rho));h = figure();bar3(imag(rho));
%%
q = 'q3';
setQSettings('r_avg',10000);
process = 'X/2';
data = Tomo_1QProcess_animation('qubit',q,'process',process,'numPts',10,'notes','','save',true);
%%
gate = 'X/2';
data = Tomo_1QProcess('qubit','q1','process',gate,'gui',true);
%%
setQSettings('r_avg',2000);
tuneup.iq2prob_01('qubit','q11','numSamples',1e4,'gui',true,'save',true);
tuneup.iq2prob_01('qubit','q10','numSamples',1e4,'gui',true,'save',true);
twoQStateTomoData = Tomo_2QState('qubit1','q11','qubit2','q10',...
  'state','|00>',...
 'notes','','gui',true,'save',true);
%%
gate = 'X/2';
data = Tomo_1QProcess('qubit','q1','process',gate,'gui',true);
%%
qubits = {'q7','q8','q9'};
setQSettings('r_avg',50000,qubits);
twoQStateTomoData = Tomo_mQState('qubits',qubits,...
  'state','1',...
 'notes','','gui',true,'save',true);
%%
q = 'q9';
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(200),7))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',40,...
       'gui',true,'save',true);
%%