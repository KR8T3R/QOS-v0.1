function T = blueForsLogReaderMCTemp(logRootDir,Chnl)
% Tmc = qes.util.blueForsLogReaderMCTemp('Z:\newton\bluefors\log',6)

% Copyright 2017 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    dateStr = datestr(now,'yy-mm-dd');
    filename = fullfile(logRootDir,dateStr,['CH',num2str(Chnl,'%0.0f'),' T ',dateStr,'.log']);
    if ~exist(filename,'file')
        T = NaN;
    end
    try
        fid = fopen(filename,'r');
        while 1
            line = fgetl(fid);
            if ~ischar(line)
                break;
            end
            lastLine = line;
        end
        fclose(fid);
    catch ME
        warning(getReport(ME,'basic','hyperlinks','off'));
        T = NaN;
        return;
    end
    if isempty(lastLine)
        T = NaN;
        return;
    end
    parts = strsplit(lastLine,',');
    try
        T = str2double(parts{end});
    catch ME
        warning(getReport(ME,'basic','hyperlinks','off'));
        T = NaN;
        return;
    end


%     error('todo...');
% 
%     delimiter_trp = ',';
%     formatSpec_trp = '%s%s%f%[^\n\r]';
%     datesToLoad = floor(startTime):floor(endTime);
%     temperatureData = {};
%     pressureData = {};
%     
%     for ii = 1:numel(datesToLoad)
%         logFolderName = fullfile(logRootDir,datestr(datesToLoad(ii),'yy-mm-dd'));
%         if isempty(dir(logFolderName))
%             continue;
%         end
%         datafiles = dir(logFolderName);
%         for jj = 1:numel(datafiles)
%             if isempty(datafiles(jj).name,datestr(datesToLoad(jj),['yy-mm-dd','.log'])) ||...
%                     ~isempty(regexp(datafiles(jj).name,'CH\d\sR', 'once')) ||...
%                     ~isempty(regexp(datafiles(jj).name,'CH\d\sP', 'once')) ||...
%                     ~isempty(strfind(datafiles(jj).name,'Status_')) ||...
%                     ~isempty(strfind(datafiles(jj).name,'Errors'))
%                 continue;
%             end
%             
%             datafilename = fullfile(logFolderName,datafiles(jj).name);
%             fileID = fopen(datafilename,'r');
%             dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
%             fclose(fileID);
%             VarName1 = dataArray{:, 1};
%             VarName2 = dataArray{:, 2};
%             VarName3 = dataArray{:, 3};
%             
%             time = [time;datenum(VarName1,'dd-mm-yy')+datenum(VarName2,'HH:MM:SS')];
%             temp = [temp;VarName3];
%             
%         end
%     end
end