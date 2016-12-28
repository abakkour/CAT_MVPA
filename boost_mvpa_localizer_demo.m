%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Boost MVPA localizer %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Created by Akram Bakkour from other scripts 04-09-2014


function boost_mvpa_localizer_demo(subjid,test_comp,scan)

if sum(scan==[0 1])==0
    error('Run nunmber must be 0 or 1');
end

Screen('Preference', 'VisualDebugLevel', 0);
% output version
script_name='Boost MVPA';
script_version='1';
revision_date='04-09-13';

notes='Design developed by Bakkour, Schonberg, Lewis-Peacock and Poldrack';

%rng(sum(100*clock),'v5uniform')
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

% read in subject initials
fprintf('%s %s (revised %s) \n %s \n',script_name,script_version, revision_date, notes);

outpath='Output/';


% set up screens
fprintf('setting up screen\n');
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=0;
Screen('FillRect', w, grayLevel);
Screen('Flip', w);

%black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
Green=[0 255 0];
yellow=Green;


xcenter=wWidth/2;
ycenter=wHeight/2;

stackW=576;
stackH=432;


rect=[xcenter-stackW/2 ycenter-stackH/2-100 xcenter+stackW/2 ycenter+stackH/2-100];
size1=45;
size2=32;

theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);


HideCursor;

maxtime=3.6; %because stim duration is 3 X TR
%list_count=1;
%baseline_fixation=1;
%afterrunfixation=1;
%max_resp_time=1;

% load the food images
%dirto=pwd;

%%% FEEDBACK VARIABLES
KbName('UnifyKeyNames');
if scan==1,
    trigger = 't';
    left = 'b';
    midleft = 'y';
    midright = 'g';
    right = 'r';
    %LEFT=[98 5 10];   %blue (5) green (10)
    %RIGHT=[121 28 21]; %yellow (28) red (21)
else
    left = 'u';
    midleft = 'i';
    midright = 'o';
    right = 'p';    %RIGHT=[110];%[198]; %>
end;

%initiating variables

food_items=cell(1,2);
actual_onset_time=cell(1,2);

shuff_q{1}=Shuffle([ones(1,2) repmat(2,1,2) repmat(3,1,2)]);
runnum=1;

respTime{runnum}=ones(6,1)*999;
question{1}='How much would you like to eat this?';
question{2}='How many items are outside of the packaging?';
question{3}='When did you last see this at a store?';
answer{1}{1}='Most      1';
answer{1}{2}='2';
answer{1}{3}='3';
answer{1}{4}='4     Least';
answer{2}{1}=' ';
answer{2}{2}='One';
answer{2}{3}='Several';
answer{2}{4}=' ';
answer{3}{1}='never';
answer{3}{2}='week';
answer{3}{3}='month';
answer{3}{4}='year';

list=dir('stim/demo/*.bmp');
shufflist=Shuffle(list);

for i=1:6
    food_items{runnum}{i}=imread(sprintf('stim/demo/%s',shufflist(i).name));
    shuff_names{runnum}{i}=shufflist(i).name;
end


ListenChar(2);
%%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL PRESENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('TextSize', w, size2); %Set textsize
CenterText(w,'For each item that appears in the middle of the screen',white,0,-270);
CenterText(w,'please answer the question below the image.',white,0,-220);
CenterText(w,'For questions that have two alternative answers,',white,0,-170);
CenterText(w,'please use buttons 1 or 2.', white,0,-120);
CenterText(w,'For questions that have 4 alternative answers,',white,0,-70);
CenterText(w,'please use buttons 1 through 4.',white,0,-20);
CenterText(w,'Answers will appear at the bottom of the screen.',white,0,30);
CenterText(w,'Press any button to continue.',white,0,130);
Screen('Flip',w);

% noresp=1;
% while noresp,
%     [keyIsDown] = KbCheck(-1);%(experimenter_device);
%     if keyIsDown && noresp,
%         noresp=0;
%     end;
% end;
% WaitSecs(0.001);

KbPressWait(-1);

DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected
KbQueueCreate;
KbQueueStart;
% display images



%--------------------------
%--------------BIG loop of runs

onsets=linspace(0,67.2,8)+4.8;

%% 'Write output file header'
%---------------------------------------------------------------

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];


fid1=fopen(['Output/' subjid '_boost_demo_loc_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid test_comp runtrial itemname question onsettime RT response fixationtime \n'); %write the header line

Screen('TextSize',w, 60);
CenterText(w,'+', white,0,0);
runStartTime=Screen(w,'Flip');

for Pos=1:6  % To cover all the items in one run.
    
    colorleft=white;
    colormidleft=white;
    colormidright=white;
    colorright=white;
    
    Screen('PutImage',w,food_items{runnum}{Pos},rect);
    Screen('TextSize',w, size1);
    CenterText(w,question{shuff_q{runnum}(Pos)},white,0,120);
    
    Screen('TextSize',w, size2);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{1},white,-390,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{2},white,-130,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{3},white,130,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{4},white,390,220);
    
    image_start_time=Screen('Flip',w,onsets(Pos)+runStartTime); % display images according to Onset times
    
    KbQueueFlush;
    
    actual_onset_time{runnum}(Pos,1)=image_start_time-runStartTime ;
    
    %-----------------------------------------------------------------
    % get response for all trial types
    noresp=1;
    
    if shuff_q{runnum}(Pos)==2
        while noresp
            % check for response
            [keyIsDown, firstPress] = KbQueueCheck(-1);
            
            if keyIsDown && noresp
                keyPressed=KbName(firstPress);
                if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                    keyPressed=char(keyPressed);
                    keyPressed=keyPressed(1);
                end
                switch keyPressed
                    case left
                        respTime{runnum}(Pos,1)=firstPress(KbName(left))-image_start_time;
                        noresp=0;
                    case midleft
                        respTime{runnum}(Pos,1)=firstPress(KbName(midleft))-image_start_time;
                        noresp=0;
                end
            end
            % check for reaching time limit
            if noresp && GetSecs-runStartTime >= onsets(Pos)+maxtime
                noresp=0;
                keyPressed='x';
                respTime{runnum}(Pos,1)=maxtime;
            end
        end
        switch keyPressed
            case left
                colormidleft=yellow;
            case midleft
                colormidright=yellow;
        end
    else
        while noresp
            % check for response
            [keyIsDown, firstPress] = KbQueueCheck(-1);
            
            if keyIsDown && noresp
                keyPressed=KbName(firstPress);
                if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                    keyPressed=char(keyPressed);
                    keyPressed=keyPressed(1);
                end
                switch keyPressed
                    case left
                        respTime{runnum}(Pos,1)=firstPress(KbName(left))-image_start_time;
                        noresp=0;
                    case midleft
                        respTime{runnum}(Pos,1)=firstPress(KbName(midleft))-image_start_time;
                        noresp=0;
                    case midright
                        respTime{runnum}(Pos,1)=firstPress(KbName(midright))-image_start_time;
                        noresp=0;
                    case right
                        respTime{runnum}(Pos,1)=firstPress(KbName(right))-image_start_time;
                        noresp=0;
                end
            end
            % check for reaching time limit
            if noresp && GetSecs-runStartTime >= onsets(Pos)+maxtime
                noresp=0;
                keyPressed='x';
                respTime{runnum}(Pos,1)=maxtime;
            end
        end
        switch keyPressed
            case left
                colorleft=yellow;
            case midleft
                colormidleft=yellow;
            case midright
                colormidright=yellow;
            case right
                colorright=yellow;
        end
    end
        
        
    Screen('PutImage',w,food_items{runnum}{Pos},rect);
    Screen('TextSize',w, size2);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{1},colorleft,-390,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{2},colormidleft,-130,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{3},colormidright,130,220);
    CenterText(w,answer{shuff_q{runnum}(Pos)}{4},colorright,390,220);
    Screen('TextSize',w, size1);
    CenterText(w,question{shuff_q{runnum}(Pos)},white,0,120);
    Screen('Flip',w,onsets(Pos)+runStartTime+respTime{runnum}(Pos,1));
    
    Screen('TextSize',w, 60);
    CenterText(w,'+', white,0,0);
    fix_time=Screen(w,'Flip',runStartTime+onsets(Pos)+maxtime);

            
    %subjid runnum figureshowon onsettime trialtype RT respInTime Audiotime response fixationtime ladder1 ladder2
    fprintf(fid1,'%s %s %d %s %d %d %d %s %d\n', subjid, test_comp, Pos, shuff_names{runnum}{Pos}, shuff_q{runnum}(Pos), actual_onset_time{runnum}(Pos,1), respTime{runnum}(Pos,1), keyPressed,  fix_time-runStartTime);
    KbQueueFlush;
    
end; % %% End the big Pos loop showing all the images in one run.

fclose(fid1);


% save data to a file, with date/time stamp
%time=clock;
outfile=strcat(outpath, sprintf('%s_boost_demo_loc_%s.mat',subjid,timestamp));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_version=script_version;
run_info.revision_date=revision_date;
run_info.script_name=mfilename;
clear food_items ;

save(outfile);



Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
WaitSecs(1);

Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
CenterText(w,'The demo is complete.',Green, 0,-270);
CenterText(w,'We will continue shortly.',Green, 0,0);
%CenterText(w,'Please read Part 3 in the Instruction pages in front of you',white, 0,-150);


Screen('Flip',w);

WaitSecs(5);
Screen('Flip',w);
Screen('CloseAll');
KbQueueRelease;
ShowCursor;

fprintf(['\n \n \n You just ran localizer demo. Next you want to run \n \n boost_mvpa_localizer_eye(''' char(subjid) ''',''' test_comp ''',' num2str(scan) ',order,1) \n \n \n']);
ListenChar(0);
clear all;








