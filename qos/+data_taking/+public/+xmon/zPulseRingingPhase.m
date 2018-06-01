function varargout = zPulseRingingPhase(varargin)
% <_o_> = zPulseRingingPhase('qubit',_c|o_,'time',[_i_],...
%       'xfrFunc',[_o_],'zAmp',_f_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

%     s.type = 'function';
%     s.funcName = 'gaussianExp';
%     s.bandWidht = 0.5e9;
%     s.r = [0.01];
%     s.td = [360e-9];
%     s.fs = 2e9;
% 
%     xfrFunc = qes.util.xfrFuncBuilder(s);
%     xfrFunc_inv = xfrFunc.inv();
%     xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
%     xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

    
%     fi = fftshift(qes.util.fftFreq(6000,1));
%     fsamples = xfrFunc_inv.eval(fi);
%     figure();
%     plot(fi, fsamples(1:2:end),'-r');
%     fsamples = xfrFunc_f.eval(fi);
%     hold on; plot(fi, fsamples(1:2:end),'-b');

    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    Z_LENGTH = 1000;

	if nargin > 1  % otherwise playback
		fcn_name = 'data_taking.public.xmon.zPulseRingingPhase'; % this and args will be saved with data
		args = util.processArgs(varargin,{'xfrFunc',[],'gui',false,'notes','','detuning',0,'save',true});
	end
    q = data_taking.public.util.getQubits(args,{'qubit'});

    Y2 = gate.Y2m(q);
    X = gate.X(q);
    I1 = gate.I(q);
    I2 = gate.I(q);
    
    Z1 = op.zRect(q);
    Z1.ln = Z_LENGTH;
    Z1.amp = args.zAmp;
    Z2 = gate.I(q);
    Z2.ln = Z_LENGTH;
    
%     R = measure.resonatorReadout_ss(q);
%     R.state = 2;
    R = measure.phase(q);
    
    maxDelayTime = max(args.delayTime);
    function procFactory1(delay)
        I1.ln = Z_LENGTH+delay;
        I2.ln = maxDelayTime - delay;
        proc = Z1.*(I1*Y2*I2); % minus delay is allowed
        R.setProcess(proc);
    end
    function procFactory2(delay)
        I1.ln = Z_LENGTH+delay;
        I2.ln = maxDelayTime - delay;
        proc = I1*Y2*I2; % minus delay is allowed
        R.setProcess(proc);
        proc.Run();
    end

    da = qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
            q.channels.z_pulse.instru);
    daChnl = da.GetChnl(q.channels.z_pulse.chnl);
    xfrFunc_backup = daChnl.xfrFunc;
    daChnl.xfrFunc = args.xfrFunc;

    if args.gui
        h = qes.ui.qosFigure(sprintf('Z pulse ripple | %s', q.name),false);
		ax = axes('parent',h);
    end

    numDelayTime = numel(args.delayTime);
    data_prob = NaN(2,numDelayTime);
    data_phase = NaN(2,numDelayTime);
    for ii = 1:numDelayTime
        procFactory1(args.delayTime(ii));
        data_phase(1,ii) = R();
        procFactory2(args.delayTime(ii));
        data_phase(2,ii) = R();
        
        if args.gui && ishghandle(ax)
            plot(ax,args.delayTime,unwrap(data_phase(1,:))-unwrap(data_phase(2,:)),'-b');
            xlabel(ax,'delay time(DA sampling interval)');
            ylabel(ax,'\theta(rad)');
            legend({'phase difference'});
            plot(ax,args.delayTime,unwrap(data_phase(2,:)),'--b',...
                args.delayTime,unwrap(data_phase(1,:)),'--r',...
                args.delayTime,unwrap(data_phase(1,:))-unwrap(data_phase(2,:)),'-k');
            xlabel(ax,'delay time(DA sampling interval)');
            ylabel(ax,'\theta(rad)');
            legend({'no z pulse','with zpulse','difference'});
            drawnow;
        end
    end
    
    daChnl.xfrFunc = xfrFunc_backup;

    if args.save
        QS = qes.qSettings.GetInstance();
        dataPath = QS.loadSSettings('data_path');
        timeStamp = datestr(now,'_yymmddTHHMMSS_');
        dataFileName = ['ZpulseCal',q.name,timeStamp,'.mat'];
        figFileName = ['ZpulseCal',q.name,timeStamp,'.fig'];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        args.xfrFunc = [];
        save(fullfile(dataPath,dataFileName),'data_phase','args','sessionSettings','hwSettings');
        try
            saveas(h, fullfile(dataPath,figFileName));
        catch
        end
    end
    
    
    varargout{1} = data_phase;
end