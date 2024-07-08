%% Resized images

fisierBattery = '\TrainData\baterry';
fisierBiological = '\TrainData\biological';
fisierBrownGlass = '\TrainData\brown-glass';
fisierCardboard = '\TrainData\cardboard';
fisierGreenGlass = '\TrainData\green-glass';
fisierMetal = '\TrainData\metal';
fisierPaper = '\TrainData\paper';
fisierPlastic = '\TrainData\plastic';
fisierWhiteGlass = '\TrainData\white-glass';

% Parcurgere fisiere cu imagini
battery = '\garbage_classification\battery';
biological = '\garbage_classification\biological';
brownGlass = '\garbage_classification\brown-glass';
cardboard = '\garbage_classification\cardboard';
greenGlass = '\garbage_classification\green-glass';
metal = '\garbage_classification\metal';
paper = '\garbage_classification\paper';
plastic = '\garbage_classification\plastic';
whiteGlass = '\garbage_classification\white-glass';

dim = [227,227];
batteryImages = dir(fullfile(whiteGlass, '*.jpg'));

for idx = 1:length(batteryImages)
    % Construiește calea completă către fișierul de imagine
    numeFisier = fullfile(whiteGlass, batteryImages(idx).name);
    % Citește imaginea
    imagine = imread(numeFisier);
    % Redimensionează imaginea
    imagineRedimensionata = imresize(imagine, dim);
    imagineRedimensionataFinala = gray2rgb(imagineRedimensionata);
    % Construiește numele fișierului pentru salvare
    numeFisierSalvare = fullfile(fisierWhiteGlass, sprintf('%d.jpg', idx));
    % Salvează imaginea redimensionată
    imwrite(imagineRedimensionataFinala, numeFisierSalvare);
end

%disp(filepath);
%disp(filename);


%%
clc
imageGUI; % Apoi rulează interfața GUI
function imageGUI()
% Crearea ferestrei GUI
fig = uifigure('Name', 'Waste Identification');
btnS = uibutton(fig, 'push', 'Text', 'Selecteaza imagine', 'Position', [50 50 150 22], 'ButtonPushedFcn', @(btn,event) selectAndProcessImage());
btnR = uibutton(fig, 'push', 'Text', 'Recicleaza', 'Position',  [220 50 150 22], 'ButtonPushedFcn', @(btn,event) recycle());
btnFinalizare= uibutton(fig, 'push', 'Text', 'Resetare mediu', 'Position',[390 50 150 22], 'ButtonPushedFcn', @(btn,event) finalizare());

btnS.BackgroundColor = ([0.67 0.49 0.76]);
btnR.BackgroundColor = ([1 0.57 0.72]);
btnProcess.BackgroundColor = ([0.68 1 0.7]);

load('reteauaAntrenata.mat','netTransfer'); % Presupunând că rețeaua este salvată în netTransfer.mat
% javaaddpath('path_to_clips_jar/clipsjni.jar'); % Schimbă cu calea reală

% Inițializează mediul CLIPS
%clips = com.clips.functions.Environment(); % Crează o nouă instanță a mediului CLIPS

% Modificarea dimensiunii fontului butonului
btnS.FontSize = 12;
btnProcess.FontSize = 12;

% Axa ui pentru afisarea imaginii
ax = uiaxes(fig, 'Position', [50 200 500 200]);

% Camp de text pentru afisarea clasei identificate
txt = uitextarea(fig, 'Position', [100 100 130 30]);
%camp text afisare informatii dupa rulare
txt1 = uitextarea(fig, 'Position', [270 100 270 100]);

% Variabila globala pentru a retine imaginea selectata
imgSelected = [];
dim = [227 227];
%Selectare imagine
   function selectAndProcessImage()
        % Selectarea imaginii de pe calculator
        [filename, filepath] = uigetfile({'*.jpg;*.jpeg;*.png'}, 'Selectează o imagine');
        % Verificarea dacă utilizatorul a selectat o imagine
        if isequal(filename, 0) || isequal(filepath, 0)
            disp('Nu ați selectat nicio imagine.');
        else
            % Citirea imaginii selectate
            img = imread(fullfile(filepath, filename));
            % Afisarea imaginii în axa UI
            imshow(img, 'Parent', ax);

            % Redimensionarea imaginii
            imagineRedimensionata = imresize(img, dim);
            imagineRedimensionataFinala = gray2rgb(imagineRedimensionata);
            imgProcessed = single(imagineRedimensionataFinala);

            % Clasificarea folosind rețeaua neuronală antrenată
            [label, score] = classify(netTransfer, imgProcessed);
            txt.Value = sprintf(char(label));

            % Afișarea clasei și scorului predicției
            disp(['Clasă: ', char(label)]);
            disp(['Scor: ', num2str(max(score), 2)]);

            % Scrierea clasei identificate în fișierul text
            fileID = fopen('deseuri.txt', 'a');
            if fileID == -1
                error('Nu s-a putut deschide fișierul pentru scriere.');
            end
            fprintf(fileID, '%s\n', char(label));
            fclose(fileID);
        end
    end


    function recycle()
        clips = py.importlib.import_module('clips');

        % Creați o instanță de mediu (Environment)
        env = clips.Environment();
        clp_file_path = 'D:\facultate\an4\SBC-PR\Proiect-SBC\proiectSBC.clp';
        env.load(clp_file_path);

        % Resetarea mediului
        env.reset();

        % Rulează regulile
        env.eval('(run)');

        % Extrageți faptele și afișați-le
        facts = env.eval('(get-fact-list *)');

        disp('######### Baza de fapte #########');
        disp(facts);

        disp('######### Afisare tip baza de fapte #########');
        disp(class(facts));

        disp('######### Afisarea bazei de fapte #########');
        for i = 1:length(facts)
            disp(facts{i});
        end

        fileID = fopen('rezultate.txt', 'r');
        fileContent = fread(fileID, '*char')';
        fclose(fileID);
        txt1.Value = fileContent;
    end

 function finalizare()
        % Resetează interfața
        cla(ax);
        txt.Value = '';
        txt1.Value = '';
        
        % Șterge conținutul fișierelor
        deleteFileContent('deseuri.txt');
        deleteFileContent('rezultate.txt');
    end

    function deleteFileContent(fileName)
        % Deschide fișierul în modul de scriere ('w') pentru a șterge conținutul
        fileID = fopen(fileName, 'w');
        % Verifică dacă fișierul a fost deschis cu succes
        if fileID == -1
            error('Nu s-a putut deschide fișierul pentru scriere.');
        end
        % Închide fișierul
        fclose(fileID);
    end
end



