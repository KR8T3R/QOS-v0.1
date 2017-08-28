classdef gateOptimizer < qes.measurement.measurement
	% do IQ Mixer calibration
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	methods(Static = true)
		function xyGateOptWithDrag(qubit,numGates,numReps,rAvg,maxIter)
            if nargin < 5
                maxIter = 20;
            end

			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if ~qubit.qr_xy_dragPulse
				error('DRAG disabled, can not do DRAG optimization, checking qubit settings.');
            end
			qubit.r_avg = rAvg;
            
			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numReps);
			
			detune = qes.expParam(qubit,'f01');
			detune.offset = qubit.f01;
			
			XY2_amp = qes.expParam(qubit,'g_XY2_amp');
			XY2_amp.offset = qubit.g_XY2_amp;
			
			XY_amp = qes.expParam(qubit,'g_XY_amp');
			XY_amp.offset = qubit.g_XY_amp;
			
			alpha = qes.expParam(qubit,'qr_xy_dragAlpha');
			alpha.offset = 0.5;
            
            QS = qes.qSettings.GetInstance();

			opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			if isempty(qubit.g_XY_typ) || strcmp(qubit.g_XY_typ,'pi')
				f = qes.expFcn([detune,XY2_amp,XY_amp,alpha],R);
                x0 = [0,0,0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05,-qubit.g_XY_amp*0.05,-0.25],...
					[2e6,qubit.g_XY2_amp*0.05,qubit.g_XY_amp*0.05,0.25],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
                QS.saveSSettings({qubit.name,'g_XY_amp'},qubit.g_XY_amp+optParams(3));
                QS.saveSSettings({qubit.name,'qr_xy_dragAlpha'},qubit.qr_xy_dragAlpha+optParams(4));
			elseif strcmp(qubit.g_XY_typ,'hPi')
				f = qes.expFcn([detune,XY2_amp,alpha],R);
                x0 = [0,0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05,-0.25],...
					[2e6,qubit.g_XY2_amp*0.05,0.25],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
                QS.saveSSettings({qubit.name,'qr_xy_dragAlpha'},qubit.qr_xy_dragAlpha+optParams(3));
			else
				error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
					qubit.g_XY_typ);
            end
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['XYGateOpt_',TimeStamp,'.mat'];
			figFileName = ['XYGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'xyGateOptWithDrag';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
		end
		function xyGateOptNoDrag(qubit,numGates,numReps,rAvg,maxIter)
            if nargin < 4
                maxIter = 20;
            end
 
			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if qubit.qr_xy_dragPulse
				error('DRAG enable, can not do no DRAG optimization, checking qubit settings.');
			end
			qubit.r_avg = rAvg;
			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numReps);
			
			detune = qes.expParam(qubit,'f01');
			detune.offset = qubit.f01;
			
			XY2_amp = qes.expParam(qubit,'g_XY2_amp');
			XY2_amp.offset = qubit.g_XY2_amp;
			
			XY_amp = qes.expParam(qubit,'g_XY_amp');
			XY_amp.offset = qubit.g_XY_amp;
            
            QS = qes.qSettings.GetInstance();

			opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			if isempty(qubit.g_XY_typ) || strcmp(qubit.g_XY_typ,'pi')
				f = qes.expFcn([detune,XY2_amp,XY_amp],R);
                x0 = [0,0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05,-qubit.g_XY_amp*0.05],...
					[2e6,qubit.g_XY2_amp*0.05,qubit.g_XY_amp*0.05],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
                QS.saveSSettings({qubit.name,'g_XY_amp'},qubit.g_XY_amp+optParams(3));
			elseif strcmp(qubit.g_XY_typ,'hPi')
				f = qes.expFcn([detune,XY2_amp,alpha],R);
                x0 = [0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05],...
					[2e6,qubit.g_XY2_amp*0.05],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
			else
				error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
					qubit.g_XY_typ);
            end
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['XYGateOpt_',TimeStamp,'.mat'];
			figFileName = ['XYGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'xyGateOptNoDrag';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
        end
		
		function zGateOpt(qubit,numGates,numReps,rAvg,maxIter)
            if nargin < 4
                maxIter = 20;
            end
 
			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if ~strcmp(qubit.g_Z_typ,'z')
				error('zGateOpt perform Z gate optimization by tunning pulse callibration paraeters, it is applicable only when Z gate is implemented by z pulse, check Z gate settings.');
			end
			qubit.r_avg = rAvg;
			Z = sqc.op.physical.gate.Z(qubit);
			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numReps,Z);
            
            QS = qes.qSettings.GetInstance();
			
			Z_amp = qes.expParam(Z,'amp');
			Z_amp.offset = qubit.g_Z_z_amp;
			
% 			da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
%                         'name',obj.qubit.channels.z_pulse.instru);
%             z_daChnl = da.GetChnl(obj.qubit.channels.z_pulse.chnl);
%             
%             xfrFuncSettings = QS.loadHwSettings({'obj.qubit.channels.z_pulse.instru',...
%                 'xfrFunc'});
%             xfrFunc = xfrFuncSettings{obj.qubit.channels.z_pulse.chnl};
            xfrFuncSetting = struct('lowPassFilters','xfrFuncs');
            xfrFuncSetting.lowPassFilters = {struct('type','function',...
                'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
                'bandWidth','0.130')};
            xfrFuncSetting.xfrFuncs = {struct('type','function',...
                'funcName','qes.waveform.xfrFunc.gaussianExp',...
                'bandWidth',0.25,...
                'rAmp',[0.0155],...
                'td',[800])};
             
            
			detune = qes.expParam(qubit,'f01');
			detune.offset = qubit.f01;
			
			XY2_amp = qes.expParam(qubit,'g_XY2_amp');
			XY2_amp.offset = qubit.g_XY2_amp;
			
		
			opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			if isempty(qubit.g_XY_typ) || strcmp(qubit.g_XY_typ,'pi')
				f = qes.expFcn([detune,XY2_amp,XY_amp],R);
                x0 = [0,0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05,-qubit.g_XY_amp*0.05],...
					[2e6,qubit.g_XY2_amp*0.05,qubit.g_XY_amp*0.05],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
                QS.saveSSettings({qubit.name,'g_XY_amp'},qubit.g_XY_amp+optParams(3));
			elseif strcmp(qubit.g_XY_typ,'hPi')
				f = qes.expFcn([detune,XY2_amp,alpha],R);
                x0 = [0,0];
                fval0 = f(x0);
				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
					x0,...
					[-2e6,-qubit.g_XY2_amp*0.05],...
					[2e6,qubit.g_XY2_amp*0.05],...
					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01+optParams(1));
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp+optParams(2));
			else
				error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
					qubit.g_XY_typ);
            end
			
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['ZGateOpt_',TimeStamp,'.mat'];
			figFileName = ['ZGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'ZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
        end
        
        function czOptPhaseAmp(qubits,numGates,numReps, rAvg, maxIter)
            if nargin < 5
                maxIter = 20;
            end
			
			import sqc.op.physical.*
			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					c
                end
                qubits{ii}.r_avg = rAvg;
            end

			aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
			QS = qes.qSettings.GetInstance();
			scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
			aczSettings = sqc.qobj.aczSettings();
			fn = fieldnames(scz);
			for ii = 1:numel(fn)
				aczSettings.(fn{ii}) = scz.(fn{ii});
			end
			qubits{1}.aczSettings = aczSettings;
			
			R = sqc.measure.randBenchMarking4Opt(qubits,numGates,numReps);
			
			phase1 = qes.expParam(aczSettings,'dynamicPhase(1)');
			phase1.offset = aczSettings.dynamicPhase(1);
			
			phase2 = qes.expParam(aczSettings,'dynamicPhase(2)');
			phase2.offset = aczSettings.dynamicPhase(2);
			
			amplitude = qes.expParam(aczSettings,'amp');
			amplitude.offset = aczSettings.amp;

			opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			f = qes.expFcn([phase1,phase2,amplitude],R);
			x0 = [0,0,0];
			fval0 = f(x0);
			[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
                    x0,...
					[-pi,-pi,-aczSettings.amp*0.1],...
					[pi,pi,aczSettings.amp*0.1],...
					opts);
            
			if fval > fval0
               error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
            % note: aczSettings is a handle class
			QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								aczSettings.dynamicPhase);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'amp'},aczSettings.amp);
			
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt_',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
        end
        
    end
end