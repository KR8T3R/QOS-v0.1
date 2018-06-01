% Run Quantum Process
% Yulin Wu, 2017/8/24
%%
import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj
%%
q = qName2Obj('q3');
g1 = gate.Y2m(q);
g2 = gate.I(q);
g2.ln = 4;
g3 = gate.X2p(q);
proc = g1*g2*g3;
R = resonatorReadout(q);
R.delay = proc.length;
proc.Run();
data = R()
%%
q = qName2Obj('q5');
g1 = gate.X(q);
proc = g1;
R = resonatorReadout(q);
R.delay = proc.length;
proc.Run();
nPts = 200;
n = 1:nPts;
x = nan(1,nPts);
y = nan(1,nPts);
figure();
for ii = 1:nPts
    proc.Run();
    data_ = R();
    y(ii) = data_(2);
    x(ii) = now;
    plot((x(2:end)-x(1))*24*60,y(2:end));
    drawnow;
end
%% validate Z_arbPhase
q = qName2Obj('q1');
g1 = gate.Y2m(q);
g2 = gate.I(q);
g2.ln = 2;
phaseSet = 2;
g3 = op.Z_arbPhase(q,phaseSet);
proc = g1*g2*g3;
R = phase(q);
R.setProcess(proc);
phaseMeasured = R();
disp('<<<< validate arbitary z rotation >>>>');
disp(['phase set: ', num2str(phaseSet), ', phase measured: ', num2str(phaseMeasured)]);
%% CZ PHASE
q1 = qName2Obj('q3');
q2 = qName2Obj('q2');
g1 = gate.Y2m(q2);
g2 = gate.CZ(q1,q2);
g3 = gate.I(q2);
g3.ln = 1;
proc = g1*g2*g3;
R = phase(q2);
R.setProcess(proc);
phaseMeasured = R();
disp(['phase measured: ', num2str(phaseMeasured)]);
%% mw cross talk
q1 = qName2Obj('q3');
q2 = qName2Obj('q9');
g1 = gate.X(q1);
R = resonatorReadout(q2);
n = 0:10;
data = zeros(1,11);
figure();
for ii = 1:11
    p = g1^n(ii);
    R.delay = p.length;
    p.Run();
    data_ = R();
    data(ii) = data_(1);
    plot(data);
    drawnow;
end

%% CZ Z Pulse Trailing PHASE
q1 = qName2Obj('q3');
q2 = qName2Obj('q2');
g1 = gate.Y2m(q2);
g2 = gate.CZ(q1,q2);
g3 = gate.I(q2);
R = phase(q2);
ln = 1:20:600;
numLn = numel(ln);
phaseMeasured = nan(1,numLn);
figure();
for ii = 1:numLn
    g3.ln = ln(ii);
    proc = g1*g2*g3;
    R.setProcess(proc);
    phaseMeasured(ii) = R();
    plot(ln/2, phaseMeasured);
    xlabel('measurement delay(ns)');
    ylabel('phase(rad)');
    drawnow;
end
%%
q1 = qName2Obj('q1');
q2 = qName2Obj('q2');
g11 = gate.I(q1); g12 = gate.Y2p(q2);
g21 = gate.I(q1); g22 = gate.Z2p(q2);
                 % g22 = gate.I(q2);
g31 = gate.I(q1); g32 = gate.Y2p(q2);
proc = (g11.*g12)*(g21.*g22)*(g31.*g32);
proc.Run();
%% acz(CNOT) target qubit phase, control qubit: |1>
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');
g1 = gate.X(q1);
g2 = gate.Y2m(q2);
g3 = gate.CZ(q1,q2);
proc = (g1.*g2)*g3;
R = phase(q2);
R.setProcess(proc);
data = R()
%% acz(CNOT) target qubit phase, control qubit: |0>
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');
g2 = gate.Y2m(q2);
g3 = gate.CZ(q1,q2);
proc = g2*g3;
R = phase(q2);
R.setProcess(proc);
data = R()
%% acz qubit phase
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');
g2 = gate.Y2m(q1);
g3 = gate.CZ(q1,q2);
proc = g2*g3;
R = phase(q1);
R.setProcess(proc);
data = R()
%%
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');
X1 = gate.X(q1);
X2 = gate.X(q2);
ACZ = gate.CZ(q1,q2);
mR1 = gate.I(q1);
mR2 = gate.Y2m(q2);
proc = (X1.*X2)*ACZ*(mR1.*mR2);
R = resonatorReadout({q1,q2});
R.delay = proc.length;
proc.Run();
data = R()
%%
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');
X1 = gate.X(q1);
X2 = gate.X(q2);
ACZ = gate.CZ(q1,q2);

ACZ_ = gate.I(q1);
ACZ_.ln = ACZ.length;

ACZ_ = ACZ;

mR1 = gate.I(q1);
mR2 = gate.Y2m(q2);
proc = (X1.*X2)*ACZ_;
R = stateTomography({q1,q2});
R.setProcess(proc);
data = R()
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

% proc = (Y2m1.*(X2p2*Y2m2))*CZ*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ*(Y2p1.*(Y2p2*X2p2));
% proc = (Y2m1.*(X2p2*Y2m2))*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*(Y2p1.*(Y2p2*X2p2));

proc = (Y2m1.*(X2p2*Y2m2))*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*(Y2p1.*(Y2p2*X2p2));


R = resonatorReadout({q1,q2});
R.delay = proc.length;

for ii = 1:20
    proc.Run();
    data = R()
end
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

proc = (Y2m1.*(X2p2*Y2m2))*CZ*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ*(Y2p1.*(Y2p2*X2p2));
% proc = (Y2m1.*(X2p2*Y2m2))*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*(Y2p1.*(Y2p2*X2p2));

R = resonatorReadout({q1,q2});
R.delay = proc.length;

for ii = 1:20
    proc.Run();
    data = R()
end
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

% proc = (Y2m1.*(X2p2*Y2m2))*CZ*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ*(Y2p1.*(Y2p2*X2p2));
% proc = (Y2m1.*(X2p2*Y2m2))*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*(Y2p1.*(Y2p2*X2p2));

proc = ((X2m1*Y2p1*X2p1).*Y2p2)*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*(Y2p1.*(X2m2*Y2m2))*((X1*Y2m1).*X2m2)*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*((X2m1*Y2m1*X2p1).*(Y2p2*X2p2));

R = resonatorReadout({q1,q2});
R.delay = proc.length;

data = zeros(1,50);
for ii = 1:50
    proc.Run();
    data_ = R();
    data(ii) = data_(1);
end

%% sequence 47
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

% proc = ((X2m1*Y2p1*X2p1).*Y2p2); % 1

proc = ((X2m1*Y2p1*X2p1).*Y2p2)*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);
    
% proc = proc*(Y2p1.*(X2m2*Y2m2))*((X1*Y2m1).*X2m2);

% 
proc = proc*(Y2p1.*(X2m2*Y2m2))*((X1*Y2m1).*X2m2)*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*((X2m1*Y2m1*X2p1).*(Y2p2*X2p2));

R = resonatorReadout({q1,q2});
R.delay = proc.length;

data = zeros(10,4);
for ii = 1:10
    proc.Run();
    data(ii,:) = R();
    data(ii,:)
end
clc
mean(data,1)

%% sequence 14
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

% proc = (Y2m1.*(X2p2*Y2m2))*CZ*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ*(Y2p1.*(Y2p2*X2p2));
% proc = (Y2m1.*(X2p2*Y2m2))*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*(Y2p1.*(Y2p2*X2p2));

% proc = (Y2m1.*(X2p2*Y2m2));

proc = (Y2m1.*(X2p2*Y2m2))*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);
    
% proc = proc*(Y2p1.*I2)*(Y2m1.*(Y2*X2));
 
proc = proc*(Y2p1.*I2)*(Y2m1.*(Y2*X2))*CZ;
q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + CZ.dynamicPhase(1);
q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + CZ.dynamicPhase(2);

    I1 = gate.I(q1);
    X1 = gate.X(q1);
    Y1 = gate.Y(q1);
    X2p1 = gate.X2p(q1);
    X2m1 = gate.X2m(q1);
    Y2p1 = gate.Y2p(q1);
    Y2m1 = gate.Y2m(q1);

    I2 = gate.I(q2);
    X2 = gate.X(q2);
    Y2 = gate.Y(q2);
    X2p2 = gate.X2p(q2);
    X2m2 = gate.X2m(q2);
    Y2p2 = gate.Y2p(q2);
    Y2m2 = gate.Y2m(q2);

proc = proc*(Y2p1.*(Y2p2*X2p2));


R = resonatorReadout({q1,q2});
R.delay = proc.length;

data = zeros(10,4);
for ii = 1:10
    proc.Run();
    data(ii,:) = R();
    data(ii,:)
end
clc
mean(data,1)
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q7');
q2 = qName2Obj('q8');

I1 = gate.I(q1);
X1 = gate.X(q1);
Y1 = gate.Y(q1);
X2p1 = gate.X2p(q1);
X2m1 = gate.X2m(q1);
Y2p1 = gate.Y2p(q1);
Y2m1 = gate.Y2m(q1);

I2 = gate.I(q2);
X2 = gate.X(q2);
Y2 = gate.Y(q2);
X2p2 = gate.X2p(q2);
X2m2 = gate.X2m(q2);
Y2p2 = gate.Y2p(q2);
Y2m2 = gate.Y2m(q2);

CZ = gate.CZ(q1,q2);

proc =  CZ*Y2p1*CZ;

R = resonatorReadout({q1,q2});
R.delay = proc.length;

proc.Run();
data = R()

%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q5');
q2 = qName2Obj('q6');

X1 = gate.X(q1);
% X1 = gate.I(q1);
CZ = gate.CZ(q1,q2);

proc =  X1*CZ;
% proc =  X1;

R = resonatorReadout_ss(q1);
R.state = 1;
R.delay = proc.length;

proc.Run();
data = R()
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

CZ = gate.CZ(q1,q2);
I = gate.I(q1);
I.ln = CZ.length;
X = gate.X(q1);

p = CZ*X*CZ*X*CZ*X*CZ*X;
p.Run();
%%
import sqc.util.qName2Obj;
q1 = qName2Obj('q7');
q2 = qName2Obj('q6');

CZ12 = gate.CZ(q1,q2);
X1 = gate.X(q1);
X2 = gate.X(q2);
Y1 = gate.Y(q1);
Y2 = gate.Y(q2);

p = CZ*X*CZ*X*CZ*X*CZ*X;
p.Run();

