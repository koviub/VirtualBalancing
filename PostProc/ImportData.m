function res = ImportData(filename, startRow, endRow)
addpath('Measurements/CONV');
if(filename(end-2:end)=='csv')
    %% Initialize variables.
    delimiter = ';';
    if nargin<=2
        startRow = 3;
        endRow = 1300;
    end
    % Read columns of data as text:
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%q%q%q%q%q%q%[^\n\r]';
    % Open the text file.
    fileID = fopen(filename,'r');
    % Read columns of data according to the format.
    dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for block=2:length(startRow)
        frewind(fileID);
        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for col=1:length(dataArray)
            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        end
    end
    % Close the text file.
    fclose(fileID);
    % Replace non-numeric text with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    
    for col=[1,2,3,4,5,6]
        % Converts text in the input cell array to numbers. Replaced non-numeric
        % text with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1)
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData(row), regexstr, 'names');
                numbers = result.numbers;
                
                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if numbers.contains(',')
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'))
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric text to numbers.
                if ~invalidThousandsSeparator
                    numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch
                raw{row, col} = rawData{row};
            end
        end
    end
    
    % Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    
    %% Create output variable
    
    data_raw=struct('t',cell2mat(raw(5:end, 1)),...
        'fi',cell2mat(raw(5:end, 3)),...
        'x',cell2mat(raw(5:end, 2)),...
        'xpp',cell2mat(raw(5:end, 4)),...
        'dist',cell2mat(raw(5:end, 6)));
    
    index=find(data_raw.t);
    
    if(isempty(index))
        res = struct('srs',data_raw,...
            'L',cell2mat(raw(1, 1)),...
            'q',cell2mat(raw(1, 2)),...
            'tau',cell2mat(raw(1, 3)),...
            'Ts',cell2mat(raw(3, 1)),...
            'dT',cell2mat(raw(3, 2)));
    else
        
        data=struct('t',data_raw.t(index),...
            'fi',data_raw.fi(index),...
            'x',data_raw.x(index),...
            'xpp',data_raw.xpp(index),...
            'dist',data_raw.dist(index));
        
        
        res = struct('srs',data,...
            'L',cell2mat(raw(1, 1)),...
            'q',cell2mat(raw(1, 2)),...
            'tau',cell2mat(raw(1, 3)),...
            'Ts',cell2mat(raw(3, 1)),...
            'dT',cell2mat(raw(3, 2)));
        
        % save to mat file
        sfile=[filename(1:end-4) '.mat'];
        sfile=strrep(sfile,',','.');
        save(sfile,'res');
    end
    movefile(filename,'Measurements/CONV');
    
else
    load(filename);
end

end

