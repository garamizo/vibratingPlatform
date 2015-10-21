classdef ZTools
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        % centroid of plate markers in respect to force plate
        centroid3Markers = [0.078692666666667 0 -0.045018];
        %centroid3bMarkers = [0.184100000000000 0 -0.111];
        centroid3bMarkers = ( [250-12.5 0 -150+12.5] + [-41.3 -1.4 89.1] ) *1e-3;
        centroid4Markers = -[0.033624698258992   0.000652664546980  -0.000157121850220];
        standardLogFile = 'vibratingPlatformReference.csv';
        subjectFileName = 'subjectFile.csv';
        testFileName = 'testFile.csv';
    end
    
    methods
    end
    
    methods(Static)
        
        function varargout = createTest(dataFolder)

        %dataFolder = '/home/garamizo/Downloads/';

        % Begin initialization code - DO NOT EDIT
        f = figure('Visible','off','Position',[360,200,450,400],'Resize','off',...
            'Name','Create Test','MenuBar','none');

        loadbutton    = uicontrol('Style','pushbutton',...
                     'String','Load','Position',[10,10,90,25],...
                     'Callback', {@loadbutton_Callback});

        lvmloadbutton    = uicontrol('Style','pushbutton',...
                     'String','Load LVM','Position',[10,50,90,25],...
                     'Callback', {@lvmloadbutton_Callback});

        lvmtext = uicontrol('Style','edit','String', '', 'Position', [110 50 300 25], 'Enable', 'Off');

        csvloadbutton    = uicontrol('Style','pushbutton',...
                     'String','Load CSV','Position',[10,85,90,25],...
                        'Callback', {@csvloadbutton_Callback});

        csvtext = uicontrol('Style','edit','String', '', 'Position', [110 85 300 25], 'Enable', 'Off');


        getsubjectbutton    = uicontrol('Style','pushbutton',...
                     'String','Subject','Position',[10,130,90,25],...
                        'Callback', {@getsubjectbutton_Callback});

        subjecttext = uicontrol('Style','edit','String', '', 'Position', [110 130 300 25], 'Enable', 'Off');

        data = {[], [], [], [], [], ''};
        columnname = {'Type', 'Plate', 'R Shin', 'R Foot', 'FP type', 'Comments'};
        columnformat = {{'TVZ','Gait'},{'RB1','RB2'}, {'RB1','RB2'}, {'RB1','RB2'},{'3 Markers','4 Markers','Gray'},'char'};
        columnwidth = {60 120 120 120 120 400};
        runtable = uitable('Data', data,... 
                    'ColumnName', columnname,...
                    'ColumnFormat', columnformat,...
                    'RowName',[],...
                    'ColumnEditable', true(1,6),...
                    'ColumnWidth', columnwidth,...
                    'Position',[10 90 400 100],...
                    'Enable', 'Off');
        runtable.Position = [10 175 runtable.Extent(3:4)];

        f.Position(3:4) = runtable.Extent(3:4) + [20 190];
        f.Visible = 'on';
        subject = [];

        varargout{1} = [];
        uiwait();

            % --- Executes on button press in savebutton.
            function csvloadbutton_Callback(source, eventData)

                [filename, pathname] = uigetfile([dataFolder '*.csv'], 'Browse the Optitrack (CSV) file.');

                if filename ~=0
                    if strfind( pathname, dataFolder ) == 1
                        csvtext.String = [strrep( pathname, dataFolder, filesep ) filename];

                        hCSV = ZTools.readCSVHeader( [dataFolder csvtext.String] );
                        runtable.ColumnFormat(2:4) = {{hCSV.RigidBody.name}};
                        runtable.Enable = 'On';
                    else
                        error('Select from data folder');
                    end
                end
            end

            % --- Executes on button press in loadbutton.
            function lvmloadbutton_Callback(source, eventData)
            % hObject    handle to loadbutton (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
                [filename, pathname] = uigetfile([dataFolder '*.lvm'], 'Browse the LabVIEW (LVM) file.');

                if filename ~= 0
                    if strfind( pathname, dataFolder ) == 1
                        lvmtext.String = [strrep( pathname, dataFolder, filesep ) filename];
                    else
                        error('Select from data folder');
                    end
                end
            end

            % --- Executes on button press in loadbutton.
            function getsubjectbutton_Callback(source, eventData)
            % hObject    handle to loadbutton (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
                subject = ZTools.createSubject();
                if ~isempty(subject)
                    subjecttext.String = subject.Name;
                end
            end

            % --- Executes on button press in loadbutton.
            function loadbutton_Callback(source, eventData)
            % hObject    handle to loadbutton (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
                try
                    hCSV = ZTools.readCSVHeader( [dataFolder csvtext.String] );
                    hLVM = ZTools.readLVMHeader( [dataFolder lvmtext.String] );

                    if abs(seconds( hCSV.t0 - hLVM.t0 )) > 90
                        error('Files are time incompatible');
                    end

                    if isempty(runtable.Data{1}) || isempty(runtable.Data{2}) || isempty(runtable.Data{3}) || ...
                            isempty(runtable.Data{4}) || isempty(runtable.Data{5}) || isempty(runtable.Data{6})
                        error('Missing table entry')
                    end
                    varargout{1}.type = runtable.Data{1};
                    varargout{1}.plateAlias = runtable.Data{2};
                    varargout{1}.rShinAlias = runtable.Data{3};
                    varargout{1}.rFootAlias = runtable.Data{4};
                    idx = find(strcmp( runtable.Data{5}, {'3 Markers','4 Markers','Gray'} ));
                    offsets = [ZTools.centroid3Markers; ZTools.centroid4Markers; ZTools.centroid4Markers];
                    varargout{1}.plateCentroidX = offsets(idx,1);
                    varargout{1}.plateCentroidY = offsets(idx,2);
                    varargout{1}.plateCentroidZ = offsets(idx,3);
                    varargout{1}.comments = runtable.Data{6};
                    varargout{1}.csvFile = csvtext.String;
                    varargout{1}.lvmFile = lvmtext.String;
                    varargout{1}.subjectKey = subject.Key;
                    
                    fileID = fopen( ZTools.testFileName, 'a+' );
                    fprintf( fileID, '%s, %s, %s, %s, %f, %f, %f, %s, %s, %s, %d\n', ...
                        runtable.Data{1:4}, offsets(idx,1), offsets(idx,2), offsets(idx,3),...
                        runtable.Data{6}, csvtext.String, lvmtext.String, subject.Key );
                    fclose( fileID );
                
                    close(source.Parent)

                catch EM
                    msgbox(EM.message, 'Error','error');
                end
            end
        end
        
        function test = loadTest()
            % {'Name', 'Age', 'Gender', 'Height', 'Shoe #', 'Email', 'Active'};

            test = [];
            fileID = fopen( ZTools.testFileName, 'r' );
            if fileID ~= -1
                A = textscan( fileID, '%s %s %s %s %f %f %f %s %s %s %d\n', Inf, 'Delimiter', ',' );
                fclose( fileID );
                for n = 1 : size(A{11},1)
                    subject = ZTools.loadSubject(A{11}(n));
                    name{n} = subject.Name;
                end
                word = strcat( name', ' -', A{:,1}, ' - ', A{:,8} );
                
                [idx,valid] = listdlg('PromptString','Select a subject as template:',...
                                'SelectionMode','single',...
                                'ListString',word,...
                                'ListSize', [500 300] );
                if valid
                    %runtable.Data{1:4}, offsets(idx,1), offsets(idx,2), offsets(idx,3),...
                        %runtable.Data{6}, csvtext.String, lvmtext.String, subject.Key 
                    test.type = A{1}{idx};
                    test.plateAlias = A{2}{idx};
                    test.rShinAlias = A{3}{idx};
                    test.rFootAlias = A{4}{idx};
                    test.plateCentroidX = A{5}(idx);
                    test.plateCentroidY = A{6}(idx);
                    test.plateCentroidZ = A{7}(idx);
                    test.comments = A{8}{idx};
                    test.csvFile = A{9}{idx};
                    test.lvmFile = A{10}{idx};
                    test.subjectKey = A{11}(idx);
                end
            else
                msgbox('Test file is empty', 'Error','error');
            end
        end  
    
        function varargout = createSubject()

        % Begin initialization code - DO NOT EDIT
        f = figure('Visible','off','Position',[360,500,450,285],'Resize','off',...
            'Name','Create Subject','MenuBar','none');

        savebutton    = uicontrol('Style','pushbutton',...
                     'String','Save','Position',[10,10,70,25],...
                        'Callback', {@savebutton_Callback});

        loadbutton    = uicontrol('Style','pushbutton',...
                     'String','Load','Position',[90,10,70,25],...
                     'Callback', {@loadbutton_Callback});

        data = {'', [], '', [], '', '', false};
        %data = {'Guilherme Aramizo Ribeiro', 23, 'Male', 175, '39 BRA', 'garamizo@mtu.edu', true};
        columnname = {'Name', 'Age', 'Gender', 'Height', 'Shoe #', 'Email', 'Active'};
        columnformat = {'char','numeric',{'Male','Female'},'numeric','char','char','logical'};
        columnwidth = {150 60 60 60 60 100 60};
        subjecttable = uitable('Data', data,... 
                    'ColumnName', columnname,...
                    'ColumnFormat', columnformat,...
                    'RowName',[],...
                    'ColumnEditable', true(1,7),...
                    'ColumnWidth', columnwidth,...
                    'Position',[10 45 400 100]);
        subjecttable.Position = [10 45 subjecttable.Extent(3:4)];

        f.Position(3:4) = subjecttable.Extent(3:4) + [20 55];
        f.Visible = 'on';
        
        varargout{1} = [];
        uiwait();

            function savebutton_Callback(source, eventData)
                fileID = fopen( ZTools.subjectFileName, 'r' );
                if fileID ~= -1
                    A = textscan( fileID, '%s %d %s %d %s %s %d %d', Inf, 'Delimiter', ',' );
                    fclose( fileID );
                    key = max( A{end} ) + 1;
                else
                    key = 0;
                end

                fileID = fopen( ZTools.subjectFileName, 'a+' );
                fprintf( fileID, '%s, %d, %s, %d, %s, %s, %d, %d\n', subjecttable.Data{1,:}, key );
                fclose( fileID );
                subject = ZTools.loadSubject(key);
                varargout{1} = subject;
                close(source.Parent);
            end

            function loadbutton_Callback(source, eventData)
                subject = ZTools.loadSubject();
                if ~isempty( subject )
                    subjecttable.Data = {subject.Name,...
                        subject.Age, subject.Gender, subject.Height,...
                        subject.ShoeSize, subject.Email, subject.Active};
                end
                varargout{1} = subject;
                pause(0.5);
                close(source.Parent);
            end
        end
        
        function subject = loadSubject(varargin)
            % {'Name', 'Age', 'Gender', 'Height', 'Shoe #', 'Email', 'Active'};

            subject = [];
            fileID = fopen( ZTools.subjectFileName, 'r' );
            if fileID ~= -1
                A = textscan( fileID, '%s %d %s %d %s %s %d %d', Inf, 'Delimiter', ',' );
                fclose( fileID );
                names = A{:,1};
                if nargin == 0
                    [idx,valid] = listdlg('PromptString','Select a subject as template:',...
                                    'SelectionMode','single',...
                                    'ListString',names,...
                                    'ListSize', [300 300] );
                else
                    idx = find( A{8} == varargin{1} );
                    valid = length( idx ) == 1;
                end
                if valid
                    subject.Name = A{1}{idx};
                    subject.Age = A{2}(idx);
                    subject.Gender = A{3}{idx};
                    subject.Height = A{4}(idx);
                    subject.ShoeSize = A{5}{idx};
                    subject.Email = A{6}{idx};
                    subject.Active = A{7}(idx)>0;
                    subject.Key = A{8}(idx);
                end
            else
                msgbox('Subject file is empty', 'Error','error');
            end
        end          
        
        function [tbl, header] = readCSV( csvFile )

            csvFile = regexprep( csvFile, {'\','/'}, {filesep,filesep} );
            tbl = table2array( readtable(csvFile, 'HeaderLines', 6) );
            header = ZTools.readCSVHeader( csvFile );
            vec = datevec( header.CaptureStartTime, 'yyyy-mm-dd HH.MM.SS.FFF PM' );
            %header.t0 = vec * [0 0 0 60^2 60 1]';
            header.fs = header.ExportFrameRate;      
        end
        
        function header = readCSVHeader( csvFile )
            
            csvFile = regexprep( csvFile, {'\','/'}, {filesep,filesep} );
            fid = fopen(csvFile);

            lineSpl = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            
            header.FormatVersion = lineSpl{2};
            header.TakeName = lineSpl{4};
            header.CaptureFrameRate = str2double( lineSpl{6} );
            header.ExportFrameRate = str2double( lineSpl{8} );
            header.CaptureStartTime = lineSpl{10};
            header.TotalFrames = str2double( lineSpl{12} );
            header.RotationType = lineSpl{14};
            
            % Fix Optitrack dating bug
            vec = datevec( header.CaptureStartTime, 'yyyy-mm-dd HH.MM.SS.FFF PM' );
            if vec(4) == 00 && ~isempty( strfind( header.CaptureStartTime, 'AM' ) )
                header.CaptureStartTime = regexprep( header.CaptureStartTime, 'AM', 'PM' );
            end    
            
            %header.t0 = datenum( header.CaptureStartTime, 'yyyy-mm-dd HH.MM.SS.FFF PM' );
            header.t0 = datetime( header.CaptureStartTime, 'InputFormat', 'yyyy-M-dd h.m.s.SSS a' );
            
            fgets(fid);
            entities = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            names = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            subnames = regexprep(deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) ), '"', '');
            fieldsPrefix = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            fieldsSufix = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            
            keyNames = strcat( names, '.', subnames );
            fields = strcat( fieldsPrefix, fieldsSufix );
            
            for entityType = {'Rigid Body', 'Rigid Body Marker', 'Marker', 'Bone', 'Bone Marker'}
                type = regexprep( entityType{1}, ' ', '' );
                
                cols = find( strcmp( entities, entityType ) );
                tmpKeyNames = keyNames( cols );
                [tmpKeyNamesSet, idx] = unique( tmpKeyNames );
                tmpNamesSet = names( cols(idx) );
                tmpSubnamesSet = subnames( cols(idx) );
                for n = 1 : length( tmpKeyNamesSet )
                    cols = strcmp( tmpKeyNamesSet{n}, keyNames );
                    NameValue = [   regexprep( fields( cols ), ' ', '' );
                                    num2cell( find( cols ) )                ];
                    NameValue = reshape( NameValue, [1 numel(NameValue)] );
                    index = struct( NameValue{:} );
                    header.(type)(n) = struct( 'name', tmpNamesSet{n}, ...
                        'subname', tmpSubnamesSet{n}, 'index', index );
                end
            end
            
            if isfield( header, 'Bone' ) && isfield( header, 'BoneMarker' )
                for n = 1 : length( header.Bone )
                    col = ~cellfun( @isempty, strfind( {header.BoneMarker.name}, header.Bone(n).name ) );
                    header.Bone(n).Marker = header.BoneMarker(col);
                end
            end
            if isfield( header, 'RigidBody' ) && isfield( header, 'RigidBodyMarker' )
                for n = 1 : length( header.RigidBody )
                    col = ~cellfun( @isempty, strfind( {header.RigidBodyMarker.subname}, header.RigidBody(n).subname ) );
                    header.RigidBody(n).Marker = header.RigidBodyMarker(col);
                end
            end
            
            fclose(fid);
            

        end
        
        function yFill = fillGaps( y, threshold )
        % FILLGAPS interpolates up to 'threshold' consecutive NaNs
        % Do not extrapolate
            
            n = 1 : size(y,1);
            yFill = y;
            for k = 1 : size(y,2)
                rowsNaN = isnan( y(:,k) );
                a = strfind( rowsNaN', ones(1,threshold+1) );
                if any(~isempty(a)) && sum(~rowsNaN) >= 2
                    idxNot = unique( bsxfun( @plus, repmat( a, [threshold+1 1] ), (0:threshold)' ) );
                    idx = setdiff( find(rowsNaN), idxNot );               
                    yFill(idx,k) = interp1( n(~rowsNaN), y(~rowsNaN,k), n(idx) );
                end
            end
        end

        function [tbl, header] = readLVM( fileName )
            
            fileName = regexprep( fileName, {'\','/'}, {filesep,filesep} );
            
            header = lvm_import( fileName, 0 );
            
            % Fix segment problem
            numSegment = 1;
            while isfield( header, ['Segment' num2str(numSegment+1)] )
                numSegment = numSegment + 1;
            end
            sizeSegment = size(header.Segment1.data);
            tbl = zeros( sizeSegment .* [numSegment 1] );
            for k = 1 : numSegment
                tbl((1:sizeSegment(1)) + sizeSegment(1)*(k-1),:) = header.( ['Segment' num2str(k)] ).data;
            end
            
            header.t0 = datetime( [header.Date ' ' header.Time], 'InputFormat', 'yyyy/M/d H:m:s.SSSSSSSSSSSSSSSSSS' );
            header.fs = mean( 1./diff(tbl(:,1)) );
%             if std( 1./diff(tbl(:,1)) ) > header.fs/10
%                 error('High variance in sampling time.')
%             end
        end
        
        function header = readLVMHeader( fileName )
            
            fileName = regexprep( fileName, {'\','/'}, {filesep,filesep} );
            verbose = 0;
            % message level
            if verbose >= 1, fprintf(1,'\nlvm_import v2.2\n'); end

            % ask for filename if not provided already
            if nargin < 1
                fileName=input(' Enter the name of the .lvm file: ','s');
                fprintf(1,'\n');
            end


            %% Open the data file
            % open and verify the file
            fid=fopen(fileName);
            if fid ~= -1, % then file exists
                fclose(fid);
            else
                filename=strcat(fileName,'.lvm');
                fid=fopen(fileName);
                if fid ~= -1, % then file exists
                    fclose(fid);
                else
                    error(['File not found in current directory! (' pwd ')']);
                end
            end

            % open the validated file
            fid=fopen(fileName);

            if verbose >= 1, fprintf(1,' Importing %s:\n\n',filename); end
            if verbose >= 2, fprintf(1,' File Header:\n'); end

            % is it really a LVM file?
            linein=fgetl(fid);
            if verbose >= 2, fprintf(1,'%s\n',linein); end
            if ~strcmp(sscanf(linein,'%s'),'LabVIEWMeasurement')
                try
                    data.Segment1.data = dlmread(filename,'\t');
                    if verbose >= 1, fprintf(1,'This file appears to be an LVM file with no header.\n'); end
                    if verbose >= 1, fprintf(1,'Data was copied, but no other information is available.\n'); end
                    return
                catch fileEx
                    error('This does not appear to be a text-format LVM file (no header).');
                end
            end


            %% Process file header
            % The file header contains several fields with useful information

            % default values
            data.Decimal_Separator = '.';
            text_delimiter='\t';
            data.X_Columns='One';

            % File header contains date, time, etc.
            % Also the file delimiter and decimal separator (LVM v2.0)
            while 1 

                % get a line from the file
                linein=fgetl(fid);
                % handle spurious carriage returns
                if isempty(linein), linein=fgetl(fid); end
                if verbose >= 2, fprintf(1,'%s\n',linein); end
                % what is the tag for this line?
                t_in = textscan(linein,'%s');
                if isempty(t_in{1})
                    tag='notag';
                else
                    tag = t_in{1}{1};
                end
                % exit when we reach the end of the header
                if strcmpi(tag,'***End_of_Header***')
                    if verbose >= 2, fprintf(1,'\n'); end
                    break
                end

                % get the value corresponding to the tag
                if ~strcmp(tag,'notag')
                    v_in = textscan(linein,'%*s %s','delimiter','\t','whitespace','','MultipleDelimsAsOne', 1);
                    if ~isempty(v_in{1})
                        val = v_in{1}{1};

                        switch tag
                            case 'Date'
                                data.Date = val;
                            case 'Time'
                                data.Time = val;
                            case 'Operator'
                                data.user = val;
                            case 'Description'
                                data.Description = val;
                            case 'Project'
                                data.Project = val;            
                            case 'Separator'
                                if strcmp(val,'Tab')
                                    text_delimiter='\t';
                                elseif strcmp(val,'Comma')
                                    text_delimiter=',';
                                end
                            case 'X_Columns'
                                data.X_Columns = val;
                            case 'Decimal_Separator'
                                data.Decimal_Separator = val;
                        end

                    end
                end    

            end

            % create matlab-formatted date vector
            if isfield(data,'time') && isfield(data,'date')
                dt = textscan(data.Date,'%d','delimiter','/');
                tm = textscan(data.Time,'%d','delimiter',':');
                if length(tm{1})==3
                    data.clock=[dt{1}(1) dt{1}(2) dt{1}(3) tm{1}(1) tm{1}(2) tm{1}(3)];
                elseif length(tm{1})==2
                    data.clock=[dt{1}(1) dt{1}(2) dt{1}(3) tm{1}(1) tm{1}(2) 0];
                else
                    data.clock=[dt{1}(1) dt{1}(2) dt{1}(3) 0 0 0];
                end
            end 
            header = data;
            fclose(fid);
            
            %'yyyy-mm-dd HH.MM.SS.FFF PM'
            %header.t0 = datenum( [header.Date ' ' header.Time] );
            header.t0 = datetime( [header.Date ' ' header.Time], 'InputFormat', 'yyyy/M/d H:m:s.SSSSSSSSSSSSSSSSSS' );
        end

        function [tblaa, tblbb, t, f, t0] = synchronizeTables( tbla, t0a, fa, tblb, t0b, fb )
        %synchronizeTables Resample and sync table B into table A
        %   Table A has lower sampling frequency

            % t0a is the reference
            ta = ( 0:size(tbla,1)-1 ) / fa;
            tb = seconds( t0b - t0a) + ( 0:size(tblb,1)-1 ) / fb;
            
            if ta(1) > tb(end) || ta(end) < tb(1) % min( ta(end), tb(end) ) - max( ta(1), tb(1) )
                error('Incompatible files', 'No time intersection between files')
            end

            factor = round( fb / fa );

            tblbFilt = filter( ones(1,factor)/factor, 1, tblb );
            tbFilt = filter( ones(1,factor)/factor, 1, tb-tb(1) ) + tb(1); % carefull with 0 ic effect

            tblbb = interp1( tbFilt, tblbFilt, ta, 'pchip', NaN );

            rows = ~isnan( tblbb(:,1) );
            if ~any(rows)
                error('Tables dont have time intersect. Check CSV and LVM name files.')
            end
            
            tblaa = tbla( rows, : );
            f = fa;
            tblbb = tblbb( rows, : );
            t = ta( rows );
            t0 = seconds(t(1)) + t0a;
            t = t - t(1);
            t = reshape( t, [numel(t) 1] );
        end
        
        function [P, Q] = extractBody( tbl, header, alias )
            
            idx = find( strcmp( {header.RigidBody.name}, alias ) );
            if isempty(idx) || length(idx) > 1
                error('Alias is not exclusive or inexistent')
            end
            
            P = tbl(:, [header.RigidBody(idx).index.PositionX
                        header.RigidBody(idx).index.PositionY
                        header.RigidBody(idx).index.PositionZ] );
                    
            Q = tbl(:, [header.RigidBody(idx).index.RotationW
                        header.RigidBody(idx).index.RotationX
                        header.RigidBody(idx).index.RotationY
                        header.RigidBody(idx).index.RotationZ] );
        end

        function [ra, rb] = calculateJointPosition( Pa, Qa, Pb, Qb )
            
            if size(Pa,1) < 6
                error( ['Not enough points for ankle calculation: ' num2str(size(Pa,1))] )
            end
            N = size( [Pa Qa Pb Qb], 1 );
            A = [ reshape( quat2dcm(Qa), [3 3*N] )', -reshape( quat2dcm(Qb), [3 3*N] )' ];
            Y = -( reshape( Pa', [3*N 1] ) - reshape( Pb', [3*N 1] ) );
            
            mdl = fitlm(A, Y, 'Intercept', false);
            disp(['R^2 = ' num2str(mdl.Rsquared.Adjusted)])
            if mdl.Rsquared.Adjusted < 0.8
                error('Ankle point badly estimated');
            end

            ra = mdl.Coefficients.Estimate(1:3); % common point from frame 1
            rb = mdl.Coefficients.Estimate(4:6); % common point from frame 2
        end

        function [z1, z2, z3, z4, x12, x34, y14, y23] = parsePlateTable( tbl )

            z4 =  tbl(:,2) * 1e3 / 3.691;
            z3 =  tbl(:,3) * 1e3 / 3.726;
            z2 =  tbl(:,4) * 1e3 / 3.708;
            z1 =  tbl(:,5) * 1e3 / 3.695;
            y23 = tbl(:,6) * 1e3 / 7.802;
            y14 = tbl(:,7) * 1e3 / 7.715;
            x34 = tbl(:,8) * 1e3 / 7.761;
            x12 = tbl(:,9) * 1e3 / 7.789;
        end

        function [ff,M,P] = plotFFT( t, y )

            Fs = 1/mean(diff(t));                    % Sampling frequency
            B = length(y);                     % Length of signal
            % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid

            %NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(y)/B;
            Y(floor(B/2)+2:end) = [];
            ff = linspace(0, Fs/2, floor(B/2)+1);
            
            M = 2*abs(Y);
            P = unwrap(angle(conj(Y)));
            %P = unwrap(atan2( real(Y), -imag(Y) ));
            
            if nargout == 0
                % Plot single-sided amplitude spectrum.
                subplot(211); plot( ff, M ) 
                title('Single-Sided Amplitude Spectrum of y(t)')
                xlabel('Frequency (Hz)')
                ylabel('|Y(f)|')
                hold on

                subplot(212); plot( ff, P ) 
                title('Single-Sided Phase Spectrum of y(t)')
                xlabel('Frequency (Hz)')
                ylabel('angle Y(f)')
                hold on
            end
        end
        
        function Qfix = fixQuat( Q )
            [r1, r2, r3] = quat2angle( Q, 'YZX' );
            Qfix = angle2quat( asin(sin(r1)), asin(sin(r2)), asin(sin(r3)), 'YZX' );
        end
        
        function pair4 = loadTestFolder( folderPath )
            
            % read csv files
            disp('(1/4) Reading CSV files...')
            D = dir( [ folderPath '/*.csv' ] );
            for k = 1 : length( D )
                [tbl, header] = ZTools.readCSV( [ folderPath filesep D(k).name ] );
                csvFile(k) = struct( 'fileName', D(k).name, 'header', header, 'tbl', {tbl} );
            end
            
            % read lvm files
            disp('(2/4) Reading LVM files...')
            D = dir( [ folderPath '/*.lvm' ] );
            for k = 1 : length( D )
                [tbl, header] = ZTools.readLVM( [ folderPath filesep D(k).name ] );
                lvmFile(k) = struct( 'fileName', D(k).name, 'header', header, 'tbl', {tbl} );
            end
            
            % sync each csv with each lvm
            disp('(3/4) Syncing files...')
            pair = repmat( struct( 'dataMotion', {[]}, 'dataForce', {[]}, 'fs', 0, ...
                't0', 0, 'duration', 0, 'csvFilename', '', 'lvmFilename', '', ...
                'csvHeader', {[]}, 'lvmHeader', {[]} ), [length(csvFile) length(lvmFile)] );
            for kCSV = 1 : length( csvFile )
                for kLVM = 1 : length( lvmFile )
                    try
                        [tblaa, tblbb, t, f, t0] = ZTools.synchronizeTables( ...
                            csvFile(kCSV).tbl, csvFile(kCSV).header.t0, csvFile(kCSV).header.fs, ...
                            lvmFile(kLVM).tbl, lvmFile(kLVM).header.t0, lvmFile(kLVM).header.fs );
                        
                        pair(kCSV,kLVM) = struct( 'dataMotion', {tblaa}, 'dataForce', {tblbb}, 'fs', f, 't0', t0, 'duration', t(end)-t(1), ...
                            'csvFilename', csvFile(kCSV).fileName, 'lvmFilename', lvmFile(kLVM).fileName, 'csvHeader', csvFile(kCSV).header, 'lvmHeader', lvmFile(kLVM).header );
                    catch err
                        % do nothing
                    end
                end
            end
            
            disp('(4/4) Sorting files...')
            % select lvms with highest recording duration for each csv
            d = reshape( [pair.duration], [length(csvFile) length(lvmFile)] );
            [~,idxLVM] = max(d,[],2);
            for n = 1 : size( pair, 1 )
                pair2(n) = pair(n,idxLVM(n));
            end
            
            % sort by capture time
            [~,idx] = sort( [pair2.t0] );
            pair3 = pair2(idx);
            
            % exclude csv without lvm
            idx = [pair3.duration] > 0;
            pair4 = pair3(idx);
            
            disp('Done')
        end
    
        function playCam( run )
            figure
            for n = 1 : length( run.csvHeader.RigidBody )
                [body{n}.P, body{n}.Q] = ZTools.extractBody( run.dataMotion, run.csvHeader, run.csvHeader.RigidBody(n).name );
                h(n) = plot3( 0, 0, 0 );
                hold on
            end
            axis( [-3 3 -0.5 5.5 -3 3] )
            legend( run.csvHeader.RigidBody.name )
            
            fps = 20;
            triad = [1 0 0; 0 0 0; 0 1 0; 0 0 0; 0 0 1]*1e-1;
            for k = 1 : round(run.fs/fps) : size(run.dataMotion,1)
                for n = 1 : length( body )
                    triad_k = repmat(body{n}.P(k,:),[5 1]) + quatrotate( quatinv(body{n}.Q(k,:)), triad );
                    set( h(n), 'XData', triad_k(:,1), 'YData', triad_k(:,2), 'ZData', triad_k(:,3) )
                end
                pause( 1/fps )
            end
        end
        
        function Y = discretize( U, N, V )
            % Discretize vector U on the range +-V into N bits
            
            U = uencode( U, N, V, 'signed');

            U = cast( U, 'double' );
            N = cast( N, 'double' );
            V = cast( V, 'double' );

            Y = interp1( [ -2^(N-1) 2^(N-1)-1 ], [-V V], U );
        end
        
        function [f, M, P] = fftAvg( t, y, N, w )
            M = zeros(N, 1);
            P = zeros(N, 1);
            for k = 1 : floor( length(t)/N )
                idx = (1:N) + N*(k-1);
                [ff, MM, PP] = ZTools.plotFFT( t(idx), y(idx).*w );
                M = M + MM;
                P = P + unwrap(PP);
            end
            f = ff;
            M = M / k;
            P = P / k;
        end
    end
    
end

