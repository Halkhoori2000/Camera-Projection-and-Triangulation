% Project 2 Implementation
% Load the mocap joints measurement
load('Subject4-Session3-Take4_mocapJoints.mat'); 

% Load the camera calibration data
load('vue4CalibInfo.mat');
load('vue2CalibInfo.mat');

% CHECK IF THE POINT IS CORRECT
% Load the video file 
%initialization of VideoReader for the vue video.
%YOU ONLY NEED TO DO THIS ONCE AT THE BEGINNING
filenamevue2mp4 = 'Subject4-Session3-24form-Full-Take4-Vue2.mp4';
vue2video = VideoReader(filenamevue2mp4);
filenamevue4mp4 = 'Subject4-Session3-24form-Full-Take4-Vue4.mp4';
vue4video = VideoReader(filenamevue4mp4);

%now we can read in the video for any mocap frame mocapFnum.
%the (50/100) factor is here to account for the difference in frame
%rates between video (50 fps) and mocap (100 fps).

[points1, points2, rays1, rays2, triangulations, epilines1, epilines2, L2] = ProcessData(mocapJoints, vue2, vue4);

% Perform Quantity Analysis
QuantitativeAnalysis(mocapJoints, L2);

% Qualitative Analysis
% Get a sample frame to display the points 
mocapFnum = 1235; %mocap frame number 1000
QualitativeAnalysis(mocapFnum, vue2video, vue4video, points1, points2, epilines1, epilines2, vue2, vue4, triangulations);

