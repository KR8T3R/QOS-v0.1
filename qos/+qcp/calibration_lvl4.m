function calibration_lvl4()

import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*

gui = true;
iq2ProbNumSamples = 1e4;
fineTune = true;

setQSettings('r_avg',2000);
logger = qes.util.log4qCloud.getLogger();

%% single qubit gates
% qubitGroups = {{'q1','q3','q5','q7','q9','q11'},...
%                {'q2','q4','q6','q8','q10'}};
qubitGroups = {{'q1','q3','q6','q10'},...
               {'q7','q11','q4'},...
               {'q5','q8'},{'q9','q2'}};
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,...
        'fineTune',fineTune,'gui',gui,'save',true,'logger',logger);
end


end