classdef gateParser
    % parse quantum circuit as gate name matrix:
    % qubits = {'q1','q2','q3'};
    % gateMat = {'Y2p','Y2m','I';
    %             'CZ','CZ','I';
    %             'I','Y2p','I';
    %             'I','I','Y2m';
    %             'I','CZ','CZ';
    %             'I','I','Y2p'};
    % p = gateParser.parse(qubits,gateMat);
    % p.Run; % creates a 3-Q GHZ state

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods (Static  = true)
        function g = parse(qubits,gateMat)
            if ~iscell(qubits)
                qubits = {qubits};
            end
            numQs = numel(qubits);
            matSz = size(gateMat);
            assert(numQs == matSz(2),'lenght of the second dimmension of gateMat not equal to the number of qubits');
            for ii = 1:numQs
                if ischar(qubits{ii})
                    qubits{ii} = sqc.util.qName2Obj(qubits{ii});
				end
            end
            supportedGates = sqc.op.physical.gateParser.supportedGates();
            g = sqc.op.physical.op.Z_arbPhase(qubits{1},0);
            for ii = 1:matSz(1)
                g_ = sqc.op.physical.op.Z_arbPhase(qubits{1},0);
                jj = 1;
                while jj <= numQs
                    if isempty(gateMat{ii,jj}) || strcmp(gateMat{ii,jj},'I')
                        jj = jj+1;
                        continue;
                    end
                    if strcmp(gateMat{ii,jj},'CZ')
                        if jj == numQs || ~strcmp(gateMat{ii,jj+1},'CZ')
                            error('invalid gateMat: at least one CZ without a neibouring CZ');
                        end
                        try
                            g__ = sqc.op.physical.gate.CZ(qubits{jj},qubits{jj+1});
                        catch
                            g__ = sqc.op.physical.gate.CZ(qubits{jj+1},qubits{jj});
                        end
                        jj = jj + 1;
                    else
                        if ~ismember(gateMat{ii,jj},supportedGates)
                            error(['unsupported gate: ', gateMat{ii,jj}]);
                        end
                        g__ = feval(str2func(['@(q)sqc.op.physical.gate.',gateMat{ii,jj},'(q)']),qubits{jj});
                    end
                    g_ = g_.*g__;
                    jj = jj + 1;
                end
                g = g*g_;
            end
        end
        function gates = supportedGates()
            gates = {'I','H',...
                'X','X2p','X2m',...
                'Y','Y2p','Y2m',...
                'Z','Z2p','Z2m','Z4p','Z4m','S','Sd',...
                'CZ'
                };
        end
        function g = parseLogical(gateMat)
            gateMat = flipud(gateMat);
            I = [1,0;0,1];
            X = [0,1;1,0];
            Y = [0,-1;1,0];
            Z = [1,0;0,-1];
            X2p = [1, -1i;...
                -1i   1]*sqrt(2)/2;
            X2m = [1, 1i;...
                1i, 1]*sqrt(2)/2;
            Y2p =[1  -1;
                  1   1]*sqrt(2)/2;
            Y2m =[1  1;
                  -1   1]*sqrt(2)/2;

            % X2p = expm(-1j*(pi/2)*X/2);
            % X2m = expm(-1j*(-pi/2)*X/2);
            % 
            % Y2p = expm(-1j*(pi/2)*Y/2);
            % Y2m = expm(-1j*(-pi/2)*Y/2);

            Z2p = [1,0;0,exp(1j*pi/2)];
            % Z8p = [1,0;0,exp(1j*pi/8)];
            % Z4p = [1,0;0,exp(1j*pi/4)];

            H = [1,1;1,-1]/sqrt(2);

            CNOT = [1,0,0,0;0,1,0,0;0,0,0,1;0,0,1,0];
            CZ = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,-1];
            
            matSz = size(gateMat);
            numQs = matSz(2);
            supportedGates = sqc.op.physical.gateParser.supportedGates();
            g = [];
            for ii = 1:matSz(1)
                jj = 1;
                g_ = [];
                while jj <= numQs
                    if isempty(gateMat{ii,jj}) || strcmp(gateMat{ii,jj},'I')
                        g__ = I;
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                        jj = jj + 1;
                        continue;
                    end
                    if ~ismember(gateMat{ii,jj},supportedGates)
                         error(['unsupported gate: ', gateMat{ii,jj}]);
                    end
                    if strcmp(gateMat{ii,jj},'CZ')
                        if jj == numQs || ~strcmp(gateMat{ii,jj+1},'CZ')
                            error('invalid gateMat: at least one CZ without a neibouring CZ');
                        end
                        g__ = CZ;
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                        jj = jj + 1;
                    else
                        switch gateMat{ii,jj}
                            case 'X'
                                g__ = X;
                            case 'X2p'
                                g__ = X2p;
                            case 'X2m'
                                g__ = X2m;
                            case 'Y'
                                g__ = Y;
                            case 'Y2p'
                                g__ = Y2p;
                            case 'Y2m'
                                g__ = Y2m;
                            case 'Z'
                                g__ = Z;
                            case 'Z2p'
                                g__ = Z2p;
                            case 'Z2m'
                                g__ = Z2m;
                            case 'H'
                                g__ = H;
                            case 'CZ'
                                g__ = CZ;
                            otherwise
                                error(['unsupported gate: ', gateMat{ii,jj}]);
                        end
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                    end
                    jj = jj + 1;
                end
                if ii == 1
                    g = g_;
                else
                    g = g*g_;
                end
            end
        end
        function p = parseLogicalProb(gateMat)
            % GHZ sate example
%             gateMat = {'Y2p','Y2m','I',  'I',  'I';
%             'CZ','CZ',  'I',  'I',  'I';
%             'I','Y2p','Y2m',  'I',  'I';
%             'I','CZ',  'CZ',  'I', 'I';
%             'I','I',  'Y2p','Y2m', 'I';
%             'I','I',  'CZ',  'CZ', 'I';
%             'I','I',  'I',  'Y2p','Y2m';
%             'I','I',  'I',   'CZ','CZ';
%             'I','I',  'I',    'I','Y2p'};
%             p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
%             figure();bar(p);

            g = sqc.op.physical.gateParser.parseLogical(gateMat);
            v = zeros(2^size(gateMat,2),1);
            v(1) = 1;
            f = g*v;
            p = real(f).^2+imag(f).^2;
        end
    end
    
end