function TrimR2026a(strF0)
% TrimR2024b('C:\Users\Jihong_Wang.LECO\Desktop\Temp\R2024b');

Rm_Folders_At_Root(strF0,["appdata","derived","extern","help",...
    "interprocess","lib","platform","polyspace","src","ui"]);
Rm_Folders_At_Root(strF0,["java","sys"]);
Rm_Empty_Pics_Empty(strF0,[".svg",".ico",".png",".gif",".jpg",".pdf"]);
Rm_Empty_Dirs_Empty(strF0,["ja_JP","ko_KR","zh_CN"]);
% return;


Rm_Dirs(strF0,"toolbox",["mlhadoop","dmr","eml"]);
Rm_Dirs(strF0,"toolbox\matlab",["datatools","maps","ui_themes","uitools"]);

Rm_Dirs(strF0,"sys",["ahformatter","fonts","opengl","python","tex"]);

Rm_Dirs(strF0,"resources",["viewmodel","uitools","uicomponents",...
    "transportlib","transportclients","testmeaslib",...
    "Simulink","SimulinkBlock","SimulinkFixedPoint","SimulinkTypes",...
    "mlreportgen","rptgen","RptgenSL",...
    "image_io","imageio","images",...
    "diagram_geometry"]);

% Rm_Dirs(strF0,"resources\MATLAB",["ja_JP","ko_KR","zh_CN"]);

Rm_Dirs(strF0,"mcr\toolbox\shared",["image_io","graphics","guide",...
    "mlreportgen","multimedia","rptgen","simulink","spreadsheet",...
    "stateflow","transportclients","transportlib","viewmodel"]);
Rm_Dirs(strF0,"mcr\toolbox\matlab",["audiovideo","imageio","images_datatypes",...
    "images","imagesci_utils","uicomponents","uitools","toolstrip",...
    "stateflow","transportclients","transportlib","viewmodel"]);

Rm_Dirs(strF0,'mcr\toolbox\shared',[...
    "appdes","blelib","coverage_data","gpucoder","images_datatypes",...
    "mlarrow","polyspace","sshaccess","asynciolib","codeinstrum","cxxfe",...
    "hadoopserializer","instrument","networklib","readsecret",...
    "testmeaslib","adlib","bigdata","controllib","diagnostic",....
    "imageio","io","performance","seriallib","virtualfileio"]);

Rm_Dirs(strF0,'mcr\toolbox\matlab',[...
    "appdesigner","bigdata","graphfun","hardware","indentcode",...
    "matlab_im","network","resources_folder","timeseries","authnz",...
    "bluetooth","graphics","helptools","iot","matlab_images",...
    "networklib","serial","appcontainer","automation","datamanager",...
    "guide","icons","maps","optimfun","serialport" ... 
    ]);

% Rm_Files_BinWin64(strF0);

Rm_Folders_At_Root(strF0,["math","foundation_extdata_matrix_data"]);


    function Rm_Folders_At_Root(strFa,Names_Of_Folders)

        for i = 1:length(Names_Of_Folders)
            try
                rmdir(fullfile(strFa,Names_Of_Folders(i)),'s');
            catch
                123;
            end
        end

    end
    function Rm_Empty_Pics_Empty(strFa,picType)

        x = dir(strFa);
        nx = length(x);

        for i=1:nx
            if x(i).name(end)=='.'
                % pass
            elseif x(i).isdir
                strFF = fullfile(strFa,x(i).name);
                if length(dir(strFF))==2
                    rmdir(strFF);
                else
                    Rm_Empty_Pics_Empty(strFF,picType);
                    if length(dir(strFF))==2, rmdir(strFF); end
                end

            else
                strFF = fullfile(strFa,x(i).name);
                for k = 1:length(picType)
                    strt = picType(k);
                    if strFF((end-strlength(strt)+1):end)==strt
                        delete(strFF);
                        break;
                        % disp(x(i).name);
                    end
                end

            end
        end

    end
    function Rm_Dirs(strFa,strPath,Names_Of_Folders)

        for i = 1:length(Names_Of_Folders)
            try
                rmdir(fullfile(strFa,strPath,Names_Of_Folders(i)),'s');
            catch
                123;
            end
        end

    end
    function Rm_Files_BinWin64(strFa)

        fff = ["AH","AOCL","py","Xfo","mlreportgen","libmwmathcnn_","PDF",...
            "libcef.dll",...
            "libmkl-cluster.dll","libmwchart.dll",...
            ];        
        % fff = ["AH","AOCL","py","Xfo","mlreportgen","libmwmathcnn_","PDF",...
        %     "libcef.dll",...
        %     "Qt5GamepadMW.dll","Qt5GuiMW.dll","Qt5OpenGLMW.dll",...
        %     "Qt5PrintSupportMW.dll","Qt5SqlMW.dll","Qt5SvgMW.dll",...
        %     "Qt5TestMW.dll","Qt5WebKit.dll","Qt5WebKit.lib",...
        %     "Qt5WinExtrasMW.dll","Qt5XmlMW.dll","Qt5XmlPatternsMW.dll",...
        %     "libmkl-cluster.dll","libmwchart.dll",...
        %     ];

        if ~isempty(fff)
            x = dir(fullfile(strFa,'bin','win64'));
            nx = length(x);

            for i = 1:nx
                if x(i).name(end)=='.' || x(i).isdir, continue; end

                for k = 1:length(fff)
                    if length(x(i).name)>=strlength(fff(k)) && ...
                            x(i).name(1:strlength(fff(k)))==fff(k)
                        delete(fullfile(strFa,'bin/win64',x(i).name));
                        break;
                    end
                end

            end
        end


        % fff = ["swift","sql","dsp","viewmodel","diagram"];
        fff = ["ja_JP","zh_CN","ko_KR"];

        if ~isempty(fff)
            x = dir(fullfile(strFa,'bin','win64'));
            nx = length(x);

            for i = 1:nx
                if x(i).name(end)=='.', continue; end

                if x(i).isdir
                    for k = 1:length(fff)
                        if ~isempty(regexp(x(i).name,fff(k),'once'))
                            rmdir(fullfile(strFa,'bin/win64',x(i).name),'s');
                            break;
                        end
                    end
                else
                    for k = 1:length(fff)
                        if ~isempty(regexp(x(i).name,fff(k),'once'))
                            delete(fullfile(strFa,'bin/win64',x(i).name));
                            break;
                        end
                    end
                end

            end
        end

    end
    function Rm_Empty_Dirs_Empty(strFa,fff)

        x = dir(strFa);
        nx = length(x);

        for i = 1:nx
            if x(i).name(end)=='.' || x(i).isdir==0, continue; end

            strFF = fullfile(strFa,x(i).name);
            fd = ~isempty(cell2mat(regexp(strFF,fff,'start','once')));

            if length(dir(strFF))==2 || fd
                rmdir(strFF,'s');
            else
                Rm_Empty_Dirs_Empty(strFF,fff);
                if length(dir(strFF))==2, rmdir(strFF); end
            end

        end

    end

end