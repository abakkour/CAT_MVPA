function check_eyetracker

Screen('Preference', 'VisualDebugLevel', 0);
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=0;
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.

%% 'INITIALIZE Eyetracker'
%---------------------------------------------------------------

ListenChar(2);
%---------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializing eye tracking system %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dummymode=0;  

% STEP 2
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(w);
% Disable key output to Matlab window:


el.backgroundcolour = black;
el.backgroundcolour = black;
el.foregroundcolour = white;
el.msgfontcolour    = white;
el.imgtitlecolour   = white;
el.calibrationtargetcolour = el.foregroundcolour;
EyelinkUpdateDefaults(el);

% STEP 3
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end;

[~, vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');

% open file to record data to
edfFile='recdata.edf';
Eyelink('Openfile', edfFile);

% STEP 4
% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% do a final check of calibration using driftcorrection
EyelinkDoDriftCorrection(el);

% STEP 5
% start recording eye position
%Eyelink('StartRecording');
% record a few samples before we actually start displaying
%WaitSecs(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%
% Finish Initialization %
%%%%%%%%%%%%%%%%%%%%%%%%% 
ListenChar(0);
clear all;