%{
---------------------------------------------------------------------------

%Run this script to demonstrate VF outcome prediction and CPR detection 
on example data segments. 

%Last Modified: 12/2/2020
---------------------------------------------------------------------------
Any use of the method or software must cite the following two papers: 

1) 
J. Coult, T. D. Rea, J. Blackwood, P. J. Kudenchuk, C. Liu, H. Kwok,
"A method to predict ventricular fibrillation shock outcome during chest
 compressions", Computers in Biology and Medicine, vol. 129,
February 2021, https://doi.org/10.1016/j.compbiomed.2020.104136.

2) 
J. Coult, J. Blackwood, T. D. Rea, P. J. Kudenchuk and H. Kwok, 
"A Method to Detect Presence of Chest Compressions During Resuscitation 
Using Transthoracic Impedance," 
 IEEE Journal of Biomedical and Health Informatics, vol. 24, no. 3, 
pp. 768-774, March 2020, https://doi.org/10.1109/JBHI.2019.2918790.
---------------------------------------------------------------------------

Copyright (C) 2019 by Jason Coult

---------------------------------------------------------------------------
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

---------------------------------------------------------------------------
%}

clear all; close all; clc;

%Folder with original example data clips and patient binary variables
dataFolder = 'data\clips\';
metadataFolder = 'data\metadata\'; 

%List files in target folder (folder must ONLY contain clip files)
clipList = dir(dataFolder); %list clips in folder
clipList = clipList(3:end); %remove the '.' and '..'
load([metadataFolder 'patientInfo.mat'], 'patientInfoTable')

%Loop through the demo data clips
for i = 1:length(clipList)
    
    %INITIAL PARAMS
    tempEcgSampleRate = -1;
    tempEcgData = -1;
    tempID = -1;
    tempModelNum = -1; 
    tempShockNum = -1;
    tempHasCpr = -1;
    tempRor = -1;
    tempPciData = -1;
    tempPciSampleRate = -1;
    tempPROR = 9;
    tempAGE = -1;
    tempSEX = -1;
    tempROR = -1; 
    tempCPC12 = -1; 
    
    %LOAD THE CLIP DATA
    currentFileName = clipList(i); %the current clip file
    load([dataFolder currentFileName.name]); %load the struct within clip
    structToLoad = currentFileName.name; %name to load
    structToLoad = structToLoad(1:(end-4)); %remove .mat
    tempID = str2double(eval([structToLoad '.cassID']));%get data from clip
    tempEcgData = (eval([structToLoad '.ecgData']));
    tempEcgSampleRate = (eval([structToLoad '.ecgSampleRate']));
    tempHasCpr = (eval([structToLoad '.hasCPR']));
    tempModel = (eval([structToLoad '.model']));
    tempShockNum = (eval([structToLoad '.shockNum']));
    tempPciSampleRate = (eval([structToLoad '.pciSampleRate']));
    tempPciData = (eval([structToLoad '.pciData']));
    
    %DICHOTOMOUS PATIENT ECG AND DEMOGRAPHIC VARIABLES
    patientInfoIndex = (patientInfoTable.clipName == string(structToLoad));
    tempAGE = patientInfoTable.clipAge(patientInfoIndex);
    tempSEX = patientInfoTable.clipSex(patientInfoIndex);
    tempPROR = patientInfoTable.clipPror(patientInfoIndex);
    tempROR = patientInfoTable.clipOutcomeRor(patientInfoIndex); 
    tempCPC12 = patientInfoTable.clipOutcomeCpc12(patientInfoIndex); 
    
    %text to display the actual observed patient outcomes
    if tempROR == 0
        rorTxt = 'No Return of Rhythm';
    elseif tempROR == 1
        rorTxt = 'Positive Return of Rhythm';
    end
    if tempCPC12 ==0
        cpcTxt = 'No Functional Survival';
    elseif tempCPC12 ==1
        cpcTxt = 'Survival w/ Functional Status';
    end
    
    
    %PREDICT OUTCOME
    %detect CPR
    [cprDetected, cprScore, cprRate] = detectCpr(tempPciData, tempPciSampleRate, tempModel, 5);
    
    %probability of eventual functional survival after shock
    [p_functionalSurvive, p_functionalSurvive_noAgeOrSex, p_functionalSurvive_svmOnly] = predictShockOutcome(...
        tempEcgData, tempEcgSampleRate, tempPciData, tempPciSampleRate, cprDetected,...
        tempPROR, tempAGE, tempSEX, 'FunctionalSurvival');
    
    %probability of return of rhythm after shock
    [p_returnOfRhythm, p_returnOfRhythm_noAgeOrSex, p_returnOfRhythm_svmOnly] = predictShockOutcome(...
        tempEcgData, tempEcgSampleRate, tempPciData, tempPciSampleRate, cprDetected,...
        tempPROR, tempAGE, tempSEX, 'ReturnOfRhythm');
    
    %PLOT
    plotEcgForDemo(tempEcgData,tempEcgSampleRate, tempPciData, tempPciSampleRate, i*30)
    title(['Input Segment: Model '  tempModel ', Shock ' num2str(tempShockNum)...    
        ', AGE=' num2str(tempAGE) ', SEX=' num2str(tempSEX) ', PROR=' num2str(tempPROR) ...
        newline 'True Outcomes after Shock: ' rorTxt ', ' cpcTxt ...
        newline 'CPR Detected: ' num2str(cprDetected) ', CPR Detection Score: ' num2str(round(cprScore,4))...
        ', CPR Rate Estimate: ' num2str(round(cprRate)) ' compressions/min' ...  
        newline 'Probability of Rhythm: Full Model= ' num2str(p_returnOfRhythm) ...
        ', ECG+PROR= ' num2str(p_returnOfRhythm_noAgeOrSex)...
        ', ECG Only= ' num2str(p_returnOfRhythm_svmOnly)...
                newline 'Probability of Survival: Full Model= ' num2str(p_functionalSurvive)...
        ', ECG+PROR= ' num2str(p_functionalSurvive_noAgeOrSex)...
        ', ECG Only= ' num2str(p_functionalSurvive_svmOnly) ...
        ])
   
    
    
end