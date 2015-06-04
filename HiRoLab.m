classdef HiRoLab
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        centroid3Markers = [0.078692666666667 0 -0.045018];
        centroid4Markers = -[0.033624698258992   0.000652664546980  -0.000157121850220];
    end
    
    methods
    end
    
    methods(Static)
        function [tbl, timestamp0, f] = readCSV( csvPath )

            fid = fopen(csvPath);
            tline = fgets(fid);
            tmp = strsplit( tline, ',' );
            date2 = tmp{10};
            dateMask = [0 0 0 60*60 60 1];
            % mod to fix noon singularity
            timestamp0 = mod( datevec(date2, 'yyyy-mm-dd HH.MM.SS.FFF PM') * dateMask', 12*60*60 );
            f = str2double( tmp{6} );
            fclose(fid);

            tbl = readtable(csvPath, 'HeaderLines', 6);
        end

        function tbl = removeNaN( tbl, varargin )
            nn = (1 : size( tbl, 1 ))';
            for n = 1 : size(tbl,2)
                if any(isnan(tbl{:,n})) == true

                    rows = isnan(tbl{:,n}); % rows to interpolate
                    
                    if  sum(~rows) >= 2 % don't try to interpolate 1-dot collumn
                        tbl{rows,n} = spline(nn(~rows), tbl{~rows,n}, nn(rows));
                    end

                    if nargin > 2
                        figure;
                        plot(nn, tbl{:,n})
                        hold on
                        plot(nn(rows), tbl{rows,n}, 'o')
                        hold off
                        title(num2str(n))
                    end
                end
            end
        end

        function [tbl, timestamp0, f] = readLVM( fileName )

            timestamp0 = mod( extractTime( fileName ), 12*60*60 ); % mod to fix noon singularity
            [pathstr,name,~] = fileparts(fileName);
            fileNameDat = [pathstr '\' name '.dat'];
            copyfile(fileName, fileNameDat, 'f');

            tbl = readtable(fileNameDat, 'ReadRowNames', false, 'Delimiter', '\t', 'HeaderLines', 23);
            f = mean( 1./diff(tbl{:,1}) );

            function t0 = extractTime( fileName )
                fid = fopen(fileName);
                for n = 1 : 12
                    tline = fgets(fid);
                end
                tmp = strsplit( tline, '\t' );
                date1 = tmp{2};
                dateMask = [0 0 0 60*60 60 1];
                t0 = datevec(date1) * dateMask';
                fclose(fid);
            end

        end

        function [tblaa, tblbb, t, f, t0] = synchronizeTables( tbla, t0a, fa, tblb, t0b, fb )
        %synchronizeTables Resample and sync table B into table A
        %   Table A has lower sampling frequency

            % absolute time
            ta = t0a + ( 0:size(tbla,1)-1 ) / fa;
            tb = t0b + ( 0:size(tblb,1)-1 ) / fb;

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
        end

        function [Pplate, Qplate, Psheen, Qsheen, Pfoot, Qfoot] = parseCamTable( tbl, param )
            
            if isa( tbl, 'table' )
                tbl = table2mat( tbl );
            end

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
            
            mdl = fitlm(A, Y)

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

