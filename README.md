# Predict VF Shock Outcomes

Predict VF shock outcomes (and detect presence of CPR) using 5-second ECG and concurrent chest impedance signals.
Any reference to the code should reference the two supporting manuscripts:

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


# Source code availability:

While the demo scripts to load and apply the function are visible, the core functions for detecting CPR and predicting shock outcome are obfuscated as .p files. 


# Versions:

12/2020 (current): This version was used to produce the final results for the manuscript. 

2/2020: Original version containing slight error in notch filter frequency. 


# Setup

Download all files into the same folder and run "main_Demo.m" using MATLAB. Program was written using MATLAB 2019a and requires the Wavelet and Signal Processing toolboxes. The output figures contain the predicted probabilities of shock outcome and presence of CPR, along with plots of the input signals, and should match the figure images in the 'figures' folder. 



# Data

Data folder contains 8 deidentified 5-second ECG and Impedance segments and their associated variables in their raw form. Data is from Lifepak 12, Lifepak 15, Heartstart MRx, and Forerunner 3 automated biphasic defibrillators. 



# Preprocessing

All required preprocessing is performed in the code with the exception of a 0.5 Hz High-pass 2nd order Butterworth filter which is required during data collection only for data collected from Forerunner 3 defibrillators. 






