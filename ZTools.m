classdef ZTools
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        centroid3Markers = [0.078692666666667 0 -0.045018];
        centroid4Markers = -[0.033624698258992   0.000652664546980  -0.000157121850220];
        standardLogFile = 'vibratingPlatformReference.csv';
        subjectFileName = 'subjectFile.csv';
    end
    
    methods
    end
    
    methods(Static)
        
        function createSubject()

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

            % --- Executes on button press in savebutton.
            function savebutton_Callback(source, eventData)
            % hObject    handle to savebutton (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % hObject
            % eventdata
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

            end

            % --- Executes on button press in loadbutton.
            function loadbutton_Callback(source, eventData)
            % hObject    handle to loadbutton (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            fileID = fopen( ZTools.subjectFileName, 'r' );
            if fileID ~= -1
                A = textscan( fileID, '%s %d %s %d %s %s %d %d', Inf, 'Delimiter', ',' );
                fclose( fileID );
                names = A{:,1};
                [idx,valid] = listdlg('PromptString','Select a subject as template:',...
                                'SelectionMode','single',...
                                'ListString',names,...
                                'ListSize', [300 300] );
                if valid
                    subjecttable.Data = {A{1}{idx}, A{2}(idx), A{3}{idx}, A{4}(idx), A{5}{idx}, A{6}{idx}, A{7}(idx)>0};
                end
            else
                msgbox('Subject file is empty', 'Error','error');
            end
            end
        end
        
        function tbl = createLogTable( fileName, save )
            
            if isempty( fileName )
                fileName = ZTools.standardLogFile;
            end
            
            tbl = table();

            %tbl.id = ['sample test ' datestr(now)];
            tbl.name = 'Evandro Ficanha';
            tbl.age = 27;
            tbl.gender = 'M';
            tbl.height = 1.85;
            tbl.shoeSize = '11 M';
            tbl.email = 'eficanh@mtu.edu';
            tbl.lifeStyle = 'active';
            
            tbl.testType = 'Time Varying Impedance';
            tbl.comments = 'sample file';
%             tbl.csvFile = [ pwd '/sample/stance/Take 2015-06-02 12.10.29 AM.csv' ];
%             tbl.lvmFile = [ pwd '/sample/stance/raw_1.lvm' ];
            tbl.csvFile = ['/home/garamizo/Downloads/test1April/Take 2015-04-01 01.45.11 PM.csv' ];
            tbl.lvmFile = [ '/home/garamizo/Downloads/test1April/raw.lvm' ];
            tbl.plateAlias = 'Rigid Body 1';
            tbl.rShinAlias = 'Rigid Body 2';
            tbl.rFootAlias = 'Rigid Body 1';
            tbl.plateCentroidX = ZTools.centroid3Markers(1);
            tbl.plateCentroidY = ZTools.centroid3Markers(2);
            tbl.plateCentroidZ = ZTools.centroid3Markers(3);
%             tbl.plateCentroidX = ZTools.centroid4Markers(1);
%             tbl.plateCentroidY = ZTools.centroid4Markers(2);
%             tbl.plateCentroidZ = ZTools.centroid4Markers(3);
            test = tbl;
            
            if strcmp( save, 's' )
                writetable(tbl, fileName);
            end
        end
        
        function test = newTest( varargin )
            
            if nargin == 1
                logFile = varargin{1};
            else
                logFile = ZTools.standardLogFile;
            end
            
            [filename, pathname] = uigetfile('*.csv;*.lvm', 'Browse the camera system (CSV) and LabVIEW (LVM) file.', 'MultiSelect', 'on');

            if strcmp( class(filename), 'cell' ) && length(filename) == 2
                if strcmp( lower(filename{1}(end-3:end)), '.csv' ) && strcmp( lower(filename{2}(end-3:end)), '.lvm' )
                    csvFile = [pathname filename{1}];
                    lvmFile = [pathname filename{2}];
                elseif strcmp( lower(filename{2}(end-3:end)), '.csv' ) && strcmp( lower(filename{1}(end-3:end)), '.lvm' )
                    csvFile = [pathname filename{2}];
                    lvmFile = [pathname filename{1}];
                else
                    error('Wrong file types')
                end
            else
                error('Didnt pick two files')
            end
            
%%
            %test = table();
            test.id = ['sample test ' datestr(now)];
            test.name = 'Evandro Ficanha';
            test.age = 27;
            test.gender = 'M';
            test.height = 1.85;
            test.shoeSize = '11 M';
            test.email = 'eficanh@mtu.edu';
            test.lifeStyle = 'active';
            test.testType = 'Time Varying Impedance';
            test.comments = 'sample file';
            test.csvFile = csvFile;
            test.lvmFile = lvmFile;
            test.plateAlias = 'Rigid Body 1';
            test.rShinAlias = 'Rigid Body 2';
            test.rFootAlias = 'Rigid Body 3';
            test.plateCentroidX = ZTools.centroid4Markers(1);
            test.plateCentroidY = ZTools.centroid4Markers(2);
            test.plateCentroidZ = ZTools.centroid4Markers(3);
            
            tbl = readtable( logFile );
            writetable( [ tbl; struct2table(test) ], logFile );
            %%

%             h = ZTools.readCSVHeader( csvFile );
% 
%             answer = inputdlg({'Subject','Comments','Plate index','Shin index','Foot index'}, 'New experiment', [1 50]);
%             answer = regexprep( answer, ',', '' ); % comma is not allowed
%             
%             subject = answer{1};
%             comments = answer{2};
%             plateIndex = str2num( answer{3} );
%             rSheenIndex = str2num( answer{4} );
%             rFootIndex = str2num( answer{5} );
%             offsetPlate = -ZTools.centroid4Markers;
% 
%             fid = fopen( logFile, 'a+' );
% 
%             fprintf( fid, '%s, %s, %s, %s, %s, %d, %d, %d, %f, %f, %f\n', [subject ' | ' h.TakeName ' | ' comments], ...
%                 subject, comments, csvFile, lvmFile, plateIndex, rSheenIndex, rFootIndex, ...
%                 offsetPlate(1), offsetPlate(2), offsetPlate(3) );
% 
%             fclose(fid);
% 
%             test = struct( 'csvFile', csvFile, 'lvmFile', lvmFile, 'plateIndex', plateIndex, ...
%                 'rSheenIndex', rSheenIndex, 'rFootIndex', rFootIndex, 'comments', comments, ...
%                 'offsetPlate', offsetPlate, 'csvHeader', h );
        end
        
        function test = loadTest( varargin )
            
            if nargin == 1
                logFile = varargin{1};
            else
                logFile = ZTools.standardLogFile;
            end
            tbl = readtable( logFile, 'HeaderLines', 0);

            [index,v] = listdlg('PromptString','Select a file:',...
                            'SelectionMode','single',...
                            'ListString',tbl.id, ...
                            'ListSize', [600 300]);

            if v == 1              
                test.csvFile = tbl.csvFile{index};
                test.lvmFile = tbl.lvmFile{index};
                test.plateAlias = tbl.plateAlias{index};
                test.rShinAlias = tbl.rShinAlias{index};
                test.rFootAlias = tbl.rFootAlias{index};
                test.plateCentroidX = tbl.plateCentroidX(index);
                test.plateCentroidY = tbl.plateCentroidY(index);
                test.plateCentroidZ = tbl.plateCentroidZ(index);
            else
                error('File not selected')
            end
        end
        
        function [tbl, header] = readCSV( csvFile )

            tbl = readtable(csvFile, 'HeaderLines', 6);
            header = ZTools.readCSVHeader( csvFile );
            vec = datevec( header.CaptureStartTime, 'yyyy-mm-dd HH.MM.SS.FFF PM' );
            header.t0 = vec * [0 0 0 60^2 60 1]';
            header.fs = header.ExportFrameRate;
            
            % Fix Optitrack dating bug
            if vec(4) == 00 && ~isempty( strfind( header.CaptureStartTime, 'AM' ) )
                header.t0 = header.t0 + 12*60^2;
            end         
        end
        
        function header = readCSVHeader( csvFile )
            
            fid = fopen(csvFile);

            lineSpl = deblank( strsplit( fgets(fid), ',', 'CollapseDelimiters', false ) );
            
            header.FormatVersion = lineSpl{2};
            header.TakeName = lineSpl{4};
            header.CaptureFrameRate = str2double( lineSpl{6} );
            header.ExportFrameRate = str2double( lineSpl{8} );
            header.CaptureStartTime = lineSpl{10};
            header.TotalFrames = str2double( lineSpl{12} );
            header.RotationType = lineSpl{14};
            
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
            
            header = lvm_import( fileName );
            tbl = array2table( header.Segment1.data );
            header.t0 = datevec(header.Time) * [0 0 0 60*60 60 1]';
            header.fs = mean( 1./diff(tbl{:,1}) );
            if std( 1./diff(tbl{:,1}) ) > header.fs/10
                error('High variance in sampling time.')
            end
        end

        function [tblaa, tblbb, t, f, t0] = synchronizeTables( tbla, t0a, fa, tblb, t0b, fb )
        %synchronizeTables Resample and sync table B into table A
        %   Table A has lower sampling frequency

            % absolute time
            ta = t0a + ( 0:size(tbla,1)-1 ) / fa;
            tb = t0b + ( 0:size(tblb,1)-1 ) / fb;
            
            if ta(1) > tb(end) || ta(end) < tb(1)
                error('Files are time incompatible')
            end

            factor = round( fb / fa );

            tblbFilt = filter( ones(1,factor)/factor, 1, table2array(tblb) );
            tbFilt = filter( ones(1,factor)/factor, 1, tb-t0b ) + t0b; % carefull with 0 ic effect

            tblbb = interp1( tbFilt, tblbFilt, ta, 'pchip', NaN );

            rows = ~isnan( tblbb(:,1) );
            if ~any(rows)
                error('Tables dont have time intersect. Check CSV and LVM name files.')
            end
            
            tblaa = tbla{ rows, : };
            f = fa;
            tblbb = tblbb( rows, : );
            t = ta( rows );
            t0 = t(1);
            t = t - t0;
            t = reshape( t, [numel(t) 1] );
        end
        
        function [P, Q] = extractBody( tbl, header, alias )
            
            if isa( tbl, 'table' )
                tbl = table2array( tbl );
            end
            
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

        function [Pplate, Qplate, Psheen, Qsheen, Pfoot, Qfoot] = parseCamTable( tbl, header, bodyAliases )
            
            if isa( tbl, 'table' )
                tbl = table2array( tbl );
            end
            
%             idxPlate = strcmp

            % define offset
            os.pos = [4 5 6];
            os.qua = [3 0 1 2];

            [Pplate, Qplate] = deal( tbl(:,os.pos+param.plateIndex), tbl(:,os.qua+param.plateIndex) );
            [Psheen, Qsheen] = deal( tbl(:,os.pos+param.rSheenIndex), tbl(:,os.qua+param.rSheenIndex) );
            [Pfoot, Qfoot] = deal( tbl(:,os.pos+param.rFootIndex), tbl(:,os.qua+param.rFootIndex) );

            % Move force plate RF
            Pplate = Pplate + quatrotate( quatinv(Qplate), param.offsetPlate );
        end

        function [ra, rb] = calculateJointPosition( Pa, Qa, Pb, Qb )

            % Method2: Minimizing transformed linear system
            N = size( [Pa Qa Pb Qb], 1 );
            A = [ reshape( quat2dcm(Qa), [3 3*N] )', -reshape( quat2dcm(Qb), [3 3*N] )' ];
            Y = -( reshape( Pa', [3*N 1] ) - reshape( Pb', [3*N 1] ) );
            rs = A \ Y;
            
            mdl = fitlm(A, Y);
            disp(['R^2 = ' num2str(mdl.Rsquared.Adjusted)])
            if mdl.Rsquared.Adjusted < 0.8
                error('Ankle point badly estimated');
            end

            ra = rs(1:3); % common point from frame 1
            rb = rs(4:6); % common point from frame 2
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
            L = size(y,1);                     % Length of signal
            % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
            yDetrend = detrend(y);     % Sinusoids plus noise

            NFFT = 2^nextpow2(L); % Next power of 2 from length of y
            Y = fft(yDetrend,NFFT)/L;
            ff = Fs/2*linspace(0,1,NFFT/2+1);
            figure
            % Plot single-sided amplitude spectrum.
            plot(ff,2*abs(Y(1:NFFT/2+1))) 
            title('Single-Sided Amplitude Spectrum of y(t)')
            xlabel('Frequency (Hz)')
            ylabel('|Y(f)|')
            
            M = 2*abs(Y(1:NFFT/2+1));
            P = angle(Y(1:NFFT/2+1));
        end
    end
    
end

