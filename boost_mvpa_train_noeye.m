%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Boost fmri - Boost MVPA %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adam Aron 12-01-2005
%%% Adapted for OSX Psychtoolbox by Jessica Cohen 12/2005
%%% Modified for use with new BMC trigger-same device as button box by JC 1/07
%%% Sound updated and modified for Jess' dissertation by JC 10/08
%%% Edited by Tom Schonberg 02-01-2012
%%% Edited by Akram Bakkour 07-20-2013
%%% Edited by Akram Bakkour 04-10-2014


function boost_mvpa_train_noeye(subjid,test_comp,order,scan,LADDER1IN, LADDER2IN,runnum)

Screen('Preference', 'VisualDebugLevel', 0);
% output version
script_name='Boost MVPA: with 2 optimized SSD trackers for: High and Low';
script_version='1';
revision_date='04-10-14';

notes='Design developed by Schonberg, Bakkour and Poldrack, inspired by Boynton';


% c=clock;
% hr=num2str(c(4));
% min=num2str(c(5));
% timestamp=[date,'_',hr,'h',min,'m'];
%rng(sum(100*clock),'v5uniform');
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

% read in subject initials
fprintf('%s %s (revised %s)\n %s \n',script_name,script_version, revision_date, notes);

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

%xcenter=wWidth/2;
%ycenter=wHeight/2;

theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);


HideCursor;

%StepSize = 50 ms;
Step=50;


image_duration=1.2; %because stim duration is 1 x TR
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
    blue = 'b';
    yellow = 'y';
    green = 'g';
    red = 'r';
    BUTTON=999;
else
    BUTTON=98;%[197];  %<
    yellow=999;
    blue=999;
    green = 999;
    red = 999;
    
end;

% if runnum==1;
%     error=zeros(1,2); % error=zeros(1, NUMCHUNKS/2);
%     rt=zeros(1,2); % rt = zeros(1, NUMCHUNKS/2);
%     count_rt=zeros(1,2); % count_rt = zeros(1, NUMCHUNKS/2);
% end;

%%%% Setting up the sound stuff
%%%% Psychportaudio
%respInTime{runnum}=shuff_stop;

if runnum==1
    
    file=dir([outpath, subjid '_stopGoList_order',num2str(order),'.txt']);
    fid=fopen([outpath, sprintf(file(length(file)).name)]);
    
    %%%% Reading in sorted file
    vars=textscan(fid, '%s%d%d%d%f') ;% these contain everything from the sortbdm
    fclose(fid);

    %initiating variables
    Ladder1=cell(1,12);
    Ladder2=cell(1,12);
    Ladder1{1}(1,1)=LADDER1IN;
    Ladder2{1}(1,1)=LADDER2IN;
    shuff_names1=cell(1,6);
    shuff_names2=cell(1,6);
    shuff_ind1=cell(1,6);
    shuff_ind2=cell(1,6);
    shuff_names=cell(1,6);
    stop=cell(1,6);
    shuff_stop=cell(1,6);
    bidIndex=cell(1,6);
    shuff_bidIndex=cell(1,6);
    itemnameIndex=cell(1,6);
    shuff_itemnameIndex=cell(1,6);
    bid=cell(1,6);
    shuff_bid=cell(1,6);
    keyPressed=cell(1,6);
    Audio_time=cell(1,6);
    respTime=cell(1,6);
    food_items=cell(1,6);
    actual_onset_time=cell(1,6);
    respInTime=cell(1,6);
    fix_time=cell(1,6);
    Ladder1end=cell(1,6);
    Ladder2end=cell(1,6);
    correct=cell(1,6);
    mean_RT=cell(1,6);
    meanRT_2runs=cell(1,6);
    
    stopind=vars{2}==11|vars{2}==21;
    goind=vars{2}==12|vars{2}==22;
    for runnum=1:6
        
        [shuff_names1{runnum},shuff_ind1{runnum}]=Shuffle([vars{1}(stopind)' vars{1}(goind)']');
        [shuff_names2{runnum},shuff_ind2{runnum}]=Shuffle([vars{1}(stopind)' vars{1}(goind)']');
        
        shuff_names{runnum}=[shuff_names1{runnum}' shuff_names2{runnum}']';
        stop{runnum}=[vars{2}(stopind)' vars{2}(goind)']';
        shuff_stop{runnum}=[stop{runnum}(shuff_ind1{runnum})' stop{runnum}(shuff_ind2{runnum})']';
        
        bidIndex{runnum}=[vars{3}(stopind)' vars{3}(goind)']';
        shuff_bidIndex{runnum}=[bidIndex{runnum}(shuff_ind1{runnum})' bidIndex{runnum}(shuff_ind2{runnum})']';
        
        itemnameIndex{runnum}=[vars{4}(stopind)' vars{4}(goind)']';
        shuff_itemnameIndex{runnum}=[itemnameIndex{runnum}(shuff_ind1{runnum})' itemnameIndex{runnum}(shuff_ind2{runnum})']';
        
        bid{runnum}=[vars{5}(stopind)' vars{5}(goind)']';
        shuff_bid{runnum}=[bid{runnum}(shuff_ind1{runnum})' bid{runnum}(shuff_ind2{runnum})']';
        
        keyPressed{runnum}=ones(length(shuff_stop{runnum}),1)*999;
        Audio_time{runnum}=ones(length(shuff_stop{runnum}),1)*999;
        respTime{runnum}=ones(length(shuff_stop{runnum}),1)*999;
        mean_RT{runnum}=ones(length(shuff_stop{runnum}),1)*999;
        meanRT_2runs{runnum}=ones(length(shuff_stop{runnum}),1)*999;

    end
    runnum=1;

else
    file=dir([outpath subjid '_boosting_run' num2str(runnum-1) '*.mat']);
    load([outpath, sprintf(file(length(file)).name)]);
    runnum=runnum+1;
    screens=Screen('Screens');
    screenNumber=max(screens);
    w=Screen('OpenWindow', screenNumber,0,[],32,2);
    [wWidth, wHeight]=Screen('WindowSize', w);
    grayLevel=0;
    Screen('FillRect', w, grayLevel);
    Screen('Flip', w);
end


for i=1:length(shuff_names{runnum})
    food_items{runnum}{i}=imread(sprintf('stim/%s',shuff_names{runnum}{i}));
end

load soundfile.mat %%%

wave=sin(1:0.25:1000);

freq=22254;
nrchannels = size(wave,1);

deviceid = -1;

reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
% Initialize driver, request low-latency preinit:
InitializePsychSound(1);
% Open audio device for low-latency output:
pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq, nrchannels);
PsychPortAudio('RunMode', pahandle, 1);
%Play the sound
PsychPortAudio('FillBuffer', pahandle, wave);
PsychPortAudio('Start', pahandle, 1, 0, 0);
WaitSecs(1);
PsychPortAudio('Stop', pahandle);

ListenChar(2);
%%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL PRESENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('TextSize',w,24); %Set textsize
if scan==0
    CenterText(w,'Press the button `b` when you hear the sound.',white,0,-270);
else
    CenterText(w,'Press button # 1 when you hear the sound.',white,0,-270);
end
CenterText(w,'Press the button as FAST as you can.',white,0,-170);
CenterText(w,'Press any button to continue.',white,0,-70);
Screen('Flip',w);

KbPressWait(-1);

if scan==1
    CenterText(w,'GET READY!', white, 0, 0);
    Screen('Flip',w);
    escapeKey = KbName('t');
    while 1
        [keyIsDown, secs, keyCode] = KbCheck(-1); %#ok<ASGLU>
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end
end

DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected

% display images

KbQueueCreate;
KbQueueStart;

%--------------------------
%--------------BIG loop of runs


onsets=linspace(0,302.4,64)+4.8;

%% 'Write output file header'
%---------------------------------------------------------------

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];


fid1=fopen(['Output/' subjid '_boosting_run' num2str(runnum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid test_comp runnum runtrial itemname onsettime trialtype RT respInTime Ausdiotime response fixationtime ladder1 ladder2 bidindex itemnameIndex bid\n'); %write the header line


Screen('TextSize',w, 60);
CenterText(w,'+', white,0,0);
runStartTime=Screen(w,'Flip');

if runnum>1
    Ladder1{runnum}(1,1)=Ladder1end{runnum-1};
    Ladder2{runnum}(1,1)=Ladder2end{runnum-1};
end



for Pos=1:64,   % To cover all the items in one run.
    
    Screen('PutImage',w,food_items{runnum}{Pos});
    image_start_time=Screen('Flip',w,onsets(Pos)+runStartTime); % display images according to Onset times
    KbQueueFlush;
    actual_onset_time{runnum}(Pos,1)=image_start_time-runStartTime ;
    
    %-----------------------------------------------------------------
    % get response for all trial types
    noresp=1;
    notone=1;
    
    while (GetSecs-image_start_time < image_duration),
        
        if  shuff_stop{runnum}(Pos)==11 && (GetSecs - image_start_time >=Ladder1{runnum}(length(Ladder1{runnum}),1)/1000) && notone %shuff_stop contains the information if a certain image is a shuff_stop trial ) or not
            
            % Beep!
            PsychPortAudio('FillBuffer', pahandle, wave);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            notone=0;
            Audio_time{runnum}(Pos,1)=GetSecs-image_start_time;
            [pressed, firstPress] = KbQueueCheck(-1);
            if pressed && noresp
                findfirstPress=find(firstPress);
                respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstPress);
                if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp=char(tmp);
                end
                keyPressed{runnum}(Pos,1) = tmp(1);
                %
                if scan==1 && (keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red)
                    noresp=0;
                    
                    if respTime{runnum}(Pos,1) < Ladder1{runnum}(length(Ladder1{runnum}),1)/1000
                        respInTime{runnum}(Pos,1)=11; %was a GO trial but responded before SS
                    else
                        respInTime{runnum}(Pos,1)=110; %was a Go trial but responded after SS within 1000 msec
                    end
                    
                elseif keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                    %     respTime{runnum}(Pos,1) = GetSecs-firstPress(find(firstPress));
                    noresp=0;
                    
                    if respTime{runnum}(Pos,1) < Ladder1{runnum}(length(Ladder1{runnum}),1)/1000
                        respInTime{runnum}(Pos,1)=11; %was a Spaced GO trial but responded before SS
                    else
                        respInTime{runnum}(Pos,1)=110; %was a Spaced Go trial item and responded after SS within 1000 msec - good trial
                    end
                end
            end
        elseif  shuff_stop{runnum}(Pos)==21 && (GetSecs - image_start_time >=Ladder2{runnum}(length(Ladder2{runnum}),1)/1000) && notone %shuff_stop contains the information if a certain image is a shuff_stop trial ) or not
            
            % Beep!
            PsychPortAudio('FillBuffer', pahandle, wave);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            notone=0;
            Audio_time{runnum}(Pos,1)=GetSecs-image_start_time;
            [pressed, firstPress] = KbQueueCheck(-1);
            if pressed && noresp
                findfirstPress=find(firstPress);
                respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstPress);
                if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp=char(tmp);
                end
                keyPressed{runnum}(Pos,1) = tmp(1);
                %
                if scan==1 && (keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red)
                    noresp=0;
                    
                    if respTime{runnum}(Pos,1) < Ladder2{runnum}(length(Ladder2{runnum}),1)/1000
                        respInTime{runnum}(Pos,1)=21; %was a GO trial but responded before SS
                    else
                        respInTime{runnum}(Pos,1)=210; %was a Go trial but responded after SS within 1000 msec
                    end
                    
                elseif keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                    %     respTime{runnum}(Pos,1) = GetSecs-firstPress(find(firstPress));
                    noresp=0;
                    
                    if respTime{runnum}(Pos,1) < Ladder2{runnum}(length(Ladder2{runnum}),1)/1000
                        respInTime{runnum}(Pos,1)=21; %was a Spaced GO trial but responded before SS
                    else
                        respInTime{runnum}(Pos,1)=210; %was a Spaced Go trial item and responded after SS within 1000 msec - good trial
                    end
                end
            end    
            
        elseif (shuff_stop{runnum}(Pos)==12) && noresp % these will now be the no-go trials
            [pressed, firstPress] = KbQueueCheck(-1);
            if pressed && noresp
                findfirstPress=find(firstPress);
                respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstPress);
                if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp=char(tmp);
                end
                keyPressed{runnum}(Pos,1) = tmp(1);
                %
                if scan==1 && (keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow  || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red)
                    noresp=0;
                    if shuff_stop{runnum}(Pos)==12 
                        respInTime{runnum}(Pos,1)=12; % a stop trial but responded within 1000 msec nogo item - not good but don't do anything
                    end
                    
                elseif keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                    noresp=0;
                    if shuff_stop{runnum}(Pos)==12
                        respInTime{runnum}(Pos,1)=12; % a stop trial but responded within 1000 msec Spaced item - not good but don't do anything
                    end
                end
            end
        elseif (shuff_stop{runnum}(Pos)==22) && noresp % these will now be the no-go trials
            [pressed, firstPress] = KbQueueCheck(-1);
            if pressed && noresp
                findfirstPress=find(firstPress);
                respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                tmp = KbName(firstPress);
                if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp=char(tmp);
                end
                keyPressed{runnum}(Pos,1) = tmp(1);
                %
                if scan==1 && (keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow  || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red)
                    noresp=0;
                    if shuff_stop{runnum}(Pos)==22
                        respInTime{runnum}(Pos,1)=22; % a stop trial but responded within 1000 msec nogo item - not good but don't do anything
                    end
                    
                elseif keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                    noresp=0;
                    if shuff_stop{runnum}(Pos)==22
                        respInTime{runnum}(Pos,1)=22; % a stop trial but responded within 1000 msec Spaced item - not good but don't do anything
                    end
                end
            end
        end
        
    end %%% End big while waiting for response within 1200 msec
    
    
    PsychPortAudio('Stop', pahandle); % Close the Audio part
    
    %%%% Show fixation
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    fix_time{runnum}(Pos,1)=Screen(w,'Flip', image_start_time+1);
    
    while (GetSecs-fix_time{runnum}(Pos,1)< 0.5) % these are additional 500msec to monitor responses
        [pressed, firstPress] = KbQueueCheck(-1);
        if pressed && noresp
            findfirstPress=find(firstPress);
            respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
            
            tmp = KbName(firstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                tmp=char(tmp);
            end
            keyPressed{runnum}(Pos,1) = tmp(1);
            if scan==1 && (keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow  || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red)
                noresp=0;
                switch shuff_stop{runnum}(Pos)
                    case 11
                        if respTime{runnum}(Pos,1)>=1.2
                            respInTime{runnum}(Pos,1)=1100; % a Go trial and  responded after 1200msec  spaced item - make it easier decrease SSD
                        elseif respTime{runnum}(Pos,1)<1.2
                            respInTime{runnum}(Pos,1)=110;
                        end
                    case 21
                        if respTime{runnum}(Pos,1)>=1.2
                            respInTime{runnum}(Pos,1)=2100; % a Go trial and  responded after 1200msec  spaced item - make it easier decrease SSD
                        elseif respTime{runnum}(Pos,1)<1.2
                            respInTime{runnum}(Pos,1)=210;
                        end
    
                    case 12
                        respInTime{runnum}(Pos,1)=12; % a stop trial and responded after 1200 msec  spaced item - don't touch

                    case 22
                        respInTime{runnum}(Pos,1)=22; % a stop trial and responded after 1200 msec  spaced item - don't touch

                end
                
                
            elseif keyPressed{runnum}(Pos,1)==BUTTON % | keyPressed{runnum}(Pos,1)==RIGHT
                noresp=0;
                switch shuff_stop{runnum}(Pos)
                    case 11
                        if respTime{runnum}(Pos,1)>=1.2
                            respInTime{runnum}(Pos,1)=1100; % a Go trial and  responded after 1200msec  spaced item - make it easier decrease SSD
                        elseif respTime{runnum}(Pos,1)<1.2
                            respInTime{runnum}(Pos,1)=110;
                        end
                    case 21
                        if respTime{runnum}(Pos,1)>=1.2
                            respInTime{runnum}(Pos,1)=2100; % a Go trial and  responded after 1200msec  spaced item - make it easier decrease SSD
                        elseif respTime{runnum}(Pos,1)<1.2
                            respInTime{runnum}(Pos,1)=210;
                        end
                        
                    case 12
                        respInTime{runnum}(Pos,1)=12; % a stop trial and responded after 1200 msec  spaced item - don't touch
                        
                    case 22
                        respInTime{runnum}(Pos,1)=22; % a stop trial and responded after 1200 msec  spaced item - don't touch
                        
                end
            end
        end
        %  KbQueueFlush;
    end % End while of additional 500 msec
    
    %%%%% This is where its all decided !
    if noresp
        switch shuff_stop{runnum}(Pos)
            case 11
                respInTime{runnum}(Pos,1)=1; %unsuccessful Go trial spaced - didn't press a button at all - trial too hard - need to decrease ladder
            case 21
                respInTime{runnum}(Pos,1)=2; %unsuccessful Go trial spaced - didn't press a button at all - trial too hard - need to decrease ladder
            case 12
                respInTime{runnum}(Pos,1)=120; % ok stop trial didn't respond after 1500 msec in stop trial spaced
            case 22
                respInTime{runnum}(Pos,1)=220; % ok stop trial didn't respond after 1500 msec in stop trial spaced

        end
    end
    
    
    switch respInTime{runnum}(Pos,1)
        case 1 % didn't respond even after 1500 msec on go trial - make it easier decrease SSD by step
            if (Ladder1{runnum}(length(Ladder1{runnum}),1)<0.001)
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
            else
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)-Step;
            end;
        case 2 % didn't respond even after 1500 msec on go trial - make it easier decrease SSD by step
            if (Ladder2{runnum}(length(Ladder2{runnum}),1)<0.001)
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
            else
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)-Step;
            end;            
            
        case 1100 %  responded after 1500 msec on go trial - make it easier decrease SSD by step
            if (Ladder1{runnum}(length(Ladder1{runnum}),1)<0.001)
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
            else
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)-Step;
            end;
       case 2100 %  responded after 1500 msec on go trial - make it easier decrease SSD by step
            if (Ladder2{runnum}(length(Ladder2{runnum}),1)<0.001)
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
            else
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)-Step;
            end;            
            
        case 11
            if (Ladder1{runnum}(length(Ladder1{runnum}),1)>1199.999); %was a GO trial with HV item but responded before SS make it harder - increase SSD by Step/3
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
            else
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)+Step/3;
            end;
        case 21
            if (Ladder2{runnum}(length(Ladder2{runnum}),1)>1199.999); %was a GO trial with HV item but responded before SS make it harder - increase SSD by Step/3
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
            else
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)+Step/3;
            end;            
            
        case 110 % pressed after Go signal but below 1200 - - increase SSD by Step/3 - these are the good trials!
            if (Ladder1{runnum}(length(Ladder1{runnum}),1)>1199.999);
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
            else
                Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)+Step/3;
            end;
        case 210 % pressed after Go signal but below 1200 - - increase SSD by Step/3 - these are the good trials!
            if (Ladder2{runnum}(length(Ladder2{runnum}),1)>1199.999);
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
            else
                Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)+Step/3;
            end;            
    end
    
    
    
    %subjid runnum figureshowon onsettime trialtype RT respInTime Audiotime response fixationtime ladder1 ladder2
    fprintf(fid1,'%s %s %d %d %s %d %d %d %d %d %d %.2f %d %d %d %d %f\n', subjid, test_comp, runnum, Pos, shuff_names{runnum}{Pos}, actual_onset_time{runnum}(Pos,1), shuff_stop{runnum}(Pos), respTime{runnum}(Pos,1), respInTime{runnum}(Pos,1), Audio_time{runnum}(Pos,1), keyPressed{runnum}(Pos,1),   fix_time{runnum}(Pos,1)-runStartTime, Ladder1{runnum}(length(Ladder1{runnum})), Ladder2{runnum}(length(Ladder2{runnum})), shuff_bidIndex{runnum}(Pos,1), shuff_itemnameIndex{runnum}(Pos,1),shuff_bid{runnum}(Pos,1));
    
    KbQueueFlush;
    
end; % %% End the big Pos loop showing all the images in one run.

fclose(fid1);

Ladder1end{runnum}=Ladder1{runnum}(length(Ladder1{runnum}));
Ladder2end{runnum}=Ladder2{runnum}(length(Ladder2{runnum}));
correct{runnum}(1)=0;

correct{runnum}(1)= length(find(respInTime{runnum}==110))+length(find(respInTime{runnum}==210));

WaitSecs(3.6);

Screen('TextSize', w, 24); %Set textsize
CenterText(w,strcat(sprintf('You responded on %.2f', correct{runnum}(1)/16*100), '% of Go trials'), white, 0,-270);
% CenterText(w,sprintf('Correct average RT on Go trials: %.1f (ms)', meanRT_2runs{runnum}*1000),white,   0,-220);
Screen('Flip',w);

%            noresp=1;
%             while noresp,
%                 [keyIsDown,secs,keyCode] = KbCheck;
%                 if keyIsDown & noresp,
%                     noresp=0;
%                 end;
%             end;
WaitSecs(2);




% save data to a file, with date/time stamp
%time=clock;
outfile=strcat(outpath, sprintf('%s_boosting_run%d_%s_%02.0f-%02.0f.mat',subjid,runnum,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_version=script_version;
run_info.revision_date=revision_date;
run_info.script_name=mfilename;
clear food_items ;

save(outfile);


%tmpTime=GetSecs;

% Close the audio device:
PsychPortAudio('Close', pahandle);
%rethrow(lasterror);


Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
CenterText(w,'Great Job. Thank you!',Green, 0,-270);
CenterText(w,'We will continue shortly.',Green, 0,0);
%CenterText(w,'Please read Part 3 in the Instruction pages in front of you',white, 0,-150);


Screen('Flip',w);

WaitSecs(5);
Screen('Flip',w);
Screen('CloseAll');
KbQueueRelease;
ShowCursor;

if runnum<6
    fprintf(['\n \n \n You just ran training run ' num2str(runnum) '. Next you want to run \n \n boost_mvpa_train_noeye(''' subjid ''',''' test_comp ''',' num2str(order) ',' num2str(scan) ',950,950,' num2str(runnum+1) ') \n \n \n']);
else
    fprintf(['\n \n \n You just ran training run ' num2str(runnum) '. Next you want to run \n \n BIS(''' subjid ''',' num2str(scan) ') \n \n \n']);
end
ListenChar(0);
clear all;








