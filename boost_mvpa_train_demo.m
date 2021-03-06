%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Stopfmri - Trained inhibition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adam Aron 12-01-2005
%%% Adapted for OSX Psychtoolbox by Jessica Cohen 12/2005
%%% Modified for use with new BMC trigger-same device as button box by JC 1/07
%%% Sound updated and modified for Jess' dissertation by JC 10/08
%%% Edited by Tom Schonberg 02-01-2012
%%% Edited by Akram Bakkour 07-19-2012

function boost_mvpa_train_demo(subjid,test_comp,scan,LADDER1IN,LADDER2IN)

Screen('Preference', 'VisualDebugLevel', 0);
%PsychDebugWindowConfiguration();

% output version
script_name='Boost fmri: with 2 optimized SSD trackers for fMRI: High and Low, version';
script_version='1.0';
revision_date='07-19-13';

notes={'Design developed by Schonberg, Bakkour and Poldrack, inspired by Boynton'};


fprintf('%s %s (revised %s)\n',script_name,script_version, revision_date);

demonames=textread('demo_items.txt','%s');

runnum=1;
Ladder1{runnum}(1,1)=LADDER1IN;
Ladder2{runnum}(1,1)=LADDER2IN;

WaitSecs(1);

% set up screens
fprintf('setting up screen\n');
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=0;
Screen('FillRect', w, grayLevel);
Screen('Flip', w);

black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
Green=[0 255 0];

xcenter=wWidth/2;
ycenter=wHeight/2;

theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);


HideCursor;

%StepSize = 50 ms;
Step=50;

image_duration=1; %because stim duration is 1.5 secs in opt_stop
list_count=1;
baseline_fixation=1;
afterrunfixation=1;
max_resp_time=1.2;

% load the food images
dirto=pwd;

%%% FEEDBACK VARIABLES
if scan==1,
    trigger = 't';
    blue = 'b';
    yellow = 'y';
    green = 'g';
    red = 'r';
    LEFT=[98 5 10];   %blue (5) green (10)
    RIGHT=[121 28 21]; %yellow (28) red (21)
else
    BUTTON=[98];%[197];  %<
    %RIGHT=[110];%[198]; %>
end;


%%%% Setting up the sound stuff
%%%% Psychportaudio

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

ListenChar(2); %supress keyboard output
%%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL PRESENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextSize', w, 24); %Set textsize

if scan==0
    CenterText(w,'Press the button `b` when you hear the sound.',white,0,-270);
else
    CenterText(w,'Press button # 1 when you hear the sound.',white,0,-270);
end
CenterText(w,'Press the button as FAST as you can.',white,0,-170);
Screen('Flip',w);

noresp=1;
while noresp,
    [keyIsDown,secs,keyCode] = KbCheck(-1); %(experimenter_device);
    if keyIsDown && noresp,
        noresp=0;
    end;
end;
WaitSecs(0.001);


% display images
anchor=GetSecs ; % (after baseline) ;
KbQueueCreate;

%--------------------------
%--------------BIG loop of runs
for runnum=1:1
    
    
    onsets=linspace(4.8,38.4,8);
    
    %% 'Write output file header'
    %---------------------------------------------------------------
    
    c=clock;
    hr=num2str(c(4));
    min=num2str(c(5));
    timestamp=[date,'_',hr,'h',min,'m'];
    rand('state',sum(100*clock));
    
    
    fid1=fopen(['Output/' subjid '_demo_boosting_runnum' num2str(runnum) ' ' timestamp '.txt'], 'a');
    fprintf(fid1,'subjid runnum test_comp itemname onsettime trialtype RT respInTime Ausdiotime response fixationtime ladder1 ladder2 bidindex itemnameIndex\n'); %write the header line
    
    
    
    prebaseline=GetSecs;
    %-----------------------------------------------------------------
    % baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
    while GetSecs < prebaseline+baseline_fixation
        %    Screen(w,'Flip', anchor);
        CenterText(w,'+', white,0,0);
        Screen('TextSize',w, 60);
        Screen(w,'Flip');
        
    end
    %-----------------------------------------------------------------
    
    [shuff_names{runnum},shuff_ind{runnum}]=Shuffle(demonames);
    
    bidIndex{runnum}=1:8;
    shuff_bidIndex{runnum}=bidIndex{runnum}(shuff_ind{runnum});
    itemnameIndex{runnum}=1:8;
    shuff_itemnameIndex{runnum}=itemnameIndex{runnum}(shuff_ind{runnum});
    %load demo_oneSeveral.mat
    load demo_stop.mat;
        
    
    keyPressed{runnum}=ones(length(demo_stop),1)*999;
    Audio_time{runnum}(1:length(demo_stop),1)=999;
    respTime{runnum}(1:length(demo_stop),1)=999;
    keyPressed{runnum}(1:length(demo_stop),1)=999;
    
    

    
    for i=1:8 
       
        demofood_items{i}=imread(sprintf('stim/demo/%s',demonames{shuff_ind{runnum}(i,1)}));
        
    end

    
    runStartTime=GetSecs-anchor;
    for Pos=1:length(demonames) %length(stop{runnum}),   % To cover all the items in one run.
        
        Screen('PutImage',w,demofood_items{Pos});
        
        image_start_time=Screen('Flip',w,anchor+onsets(Pos)+runStartTime); % display images according to Onset times
        actual_onset_time{runnum}(Pos,1)=image_start_time-anchor ;
        
        %-----------------------------------------------------------------
        % get response for all trial types
        noresp=1;
        notone=1;
        KbQueueStart;
        
        
        while (GetSecs-image_start_time < image_duration)
            
            if  demo_stop(Pos)==11 && (GetSecs - image_start_time >=Ladder1{runnum}(length(Ladder1{runnum}),1)/1200) & notone %demo_stop contains the information if a certain image is a demo_stop trial ) or not
                
                
                % Beep!
                PsychPortAudio('FillBuffer', pahandle, wave);
                PsychPortAudio('Start', pahandle, 1, 0, 0);
                notone=0;
                Audio_time{runnum}(Pos,1)=GetSecs-image_start_time;
                [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(-1);
                if pressed && noresp
                    findfirstPress=find(firstPress);
                    respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstPress);
                    if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp=char(tmp);
                    end
                    keyPressed{runnum}(Pos,1) = tmp(1);
                    %
                    if scan==1
                        if keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red
                            noresp=0;
                            
                            if respTime{runnum}(Pos,1) < Ladder1{runnum}(length(Ladder1{runnum}),1)/1200
                                respInTime{runnum}(Pos,1)=11; %was a GO trial with HV item but responded before SS
                            else
                                respInTime{runnum}(Pos,1)=110; %was a Go trial with HV item but responded after SS within 1000 msec
                            end
                            
                        else
                            if keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                                %     respTime{runnum}(Pos,1) = GetSecs-firstPress(find(firstPress));
                                noresp=0;
                                
                                if respTime{runnum}(Pos,1) < Ladder1{runnum}(length(Ladder1{runnum}),1)/1200
                                    respInTime{runnum}(Pos,1)=11; %was a GO trial with HV item but responded before SS
                                else
                                    respInTime{runnum}(Pos,1)=110; %was a Go trial with HV item and responded after SS within 1000 msec - good trial
                                end
                            end
                        end
                    end
                end
                
                
            elseif  demo_stop(Pos)==22 & (GetSecs - image_start_time >=Ladder2{runnum}(length(Ladder2{runnum}),1)/1200) & notone%stop contains the information if a certain image is a stop trial <99) or not
                
                %% Beep!
                PsychPortAudio('FillBuffer', pahandle, wave);
                PsychPortAudio('Start', pahandle, 1, 0, 0);
                notone=0;
                Audio_time{runnum}(Pos,1)=GetSecs-image_start_time;
                
                [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(-1);
                if pressed & noresp
                    findfirstPress=find(firstPress);
                    respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                    
                    tmp = KbName(firstPress);
                    if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp=char(tmp);
                    end
                    
                    keyPressed{runnum}(Pos,1) = tmp(1);
                    %
                    if scan==1
                        if keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red
                            noresp=0;
                            if respTime{runnum}(Pos,1) < Ladder2{runnum}(length(Ladder2{runnum}),1)/1200
                                respInTime{runnum}(Pos,1)=22; %was a GO trial with LV item but responded before SS
                                
                            else
                                respInTime{runnum}(Pos,1)=220; %was a Go trial with LV item but responded after SS within 1000 msec
                                
                            end
                        end
                    else
                        if keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                            noresp=0;
                            if respTime{runnum}(Pos,1) < Ladder2{runnum}(length(Ladder2{runnum}),1)/1200
                                respInTime{runnum}(Pos,1)=22;  %was a GO trial with LV item but responded before SS
                            else
                                respInTime{runnum}(Pos,1)=220; %was a Go trial with LV item and responded after SS within 1000 msec - good trial
                            end
                        end
                    end
                   
                end
                
            elseif   mod(demo_stop(Pos),11)~=0 & noresp % these will now be the no-go trials
                [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(-1);
                if pressed & noresp
                    findfirstPress=find(firstPress);
                    respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstPress);
                    if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp=char(tmp);
                    end
                    keyPressed{runnum}(Pos,1) = tmp(1);
                    %
                    if scan==1
                        if keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red
                            noresp=0;
                            if demo_stop(Pos)==12
                                respInTime{runnum}(Pos,1)=12; % a stop trial but responded within 1000 msec HV item - not good but don't do anything
                            else
                                respInTime{runnum}(Pos,1)=24; % a stop trial but responded within 1000 msec LV item - not good but don't do anything
                            end
                        end
                    else
                        if keyPressed{runnum}(Pos,1)==BUTTON %| keyPressed{runnum}(Pos,1)==RIGHT
                            noresp=0;
                            if demo_stop(Pos)==12
                                respInTime{runnum}(Pos,1)=12; %% a stop trial but responded within 1000 msec HV item - not good but don't do anything
                            else
                                respInTime{runnum}(Pos,1)=24; %% a stop trial but responded within 1000 msec LV item - not good but don't do anything
                            end
                        end
                    end
                    
                end
            end
            
        end %%% End big while waiting for response within 1000 msec
        
        
        PsychPortAudio('Stop', pahandle); % Close the Audio part
        
        %%%% Show fixation
        CenterText(w,'+', white,0,0);
        Screen('TextSize',w, 60);
        Screen(w,'Flip', image_start_time+1);
        fix_time{runnum}(Pos,1)=GetSecs ;
        
        %         if noresp==1
        while (GetSecs-fix_time{runnum}(Pos,1)< 0.5)  % these are additional 500msec to monitor responses
            [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(-1);
            if pressed & noresp
                findfirstPress=find(firstPress);
                respTime{runnum}(Pos,1) = firstPress(findfirstPress(1))-image_start_time;
                
                tmp = KbName(firstPress);
                if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                    tmp=char(tmp);
                end
                keyPressed{runnum}(Pos,1) = tmp(1);
                if scan==1
                    if keyPressed{runnum}(Pos,1)==blue || keyPressed{runnum}(Pos,1)==yellow || keyPressed{runnum}(Pos,1)==green || keyPressed{runnum}(Pos,1)==red
                        noresp=0;
                        switch demo_stop(Pos)
                            case 11
                                respInTime{runnum}(Pos,1)=1100; % a Go trial and  responded after 1000msec  HV item - make it easier decrease SSD
                            case 22
                                respInTime{runnum}(Pos,1)=2200; % a Go trial and responded after 1000msec   LV item - make it easier decrease SSD
                            case 12
                                respInTime{runnum}(Pos,1)=12; % a stop trial and responded after 1000 msec  HV item - don't touch
                            case 24
                                respInTime{runnum}(Pos,1)=24; % % a stop trial and  responded after 1000 msec HV item - don't touch
                        end
                    end
                    
                else
                    if keyPressed{runnum}(Pos,1)==BUTTON % | keyPressed{runnum}(Pos,1)==RIGHT
                    noresp=0;
                    switch demo_stop(Pos)
                        case 11
                            respInTime{runnum}(Pos,1)=1100;% a Go trial and responded after 1000msec  HV item  - make it easier decrease SSD
                        case 22
                            respInTime{runnum}(Pos,1)=2200;% a Go trial and responded after 1000msec  LV item - - make it easier decrease SSD
                        case 12
                            respInTime{runnum}(Pos,1)=12;% a stop trial and didnt respond on time HV item - don't touch
                        case 24
                            respInTime{runnum}(Pos,1)=24;% a stop trial and didnt respond on time LV item - don't touch
                            
                    end
                    end
                end
            end
            %  KbQueueFlush;
        end % End while of additional 500 msec
        
        %         end;
        
        %%%%% This is where its all decided !
        if noresp
            switch demo_stop(Pos)
                case 11
                    respInTime{runnum}(Pos,1)=1; %unsuccessful Go trial HV - didn't press a button at all - trial too hard - need to decrease ladder
                case 22
                    respInTime{runnum}(Pos,1)=2; % unsuccessful Go trial LV - didn't press a button at all - trial too hard - need to decrease ladder
                case 12
                    respInTime{runnum}(Pos,1)=120; % ok stop trial didn't respond after 1500 msec in stop trial HV
                case 24
                    respInTime{runnum}(Pos,1)=240; % ok stop trial didn't respond after 1500 msec in go trial LV
            end
        end
        
        
        switch respInTime{runnum}(Pos,1)
            case 1 % didn't respond even after 1500 msec on go trial - make it easier decrease SSD by step
                if (Ladder1{runnum}(length(Ladder1{runnum}),1)==0)
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
                else
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)-Step;
                end;
                
            case 2 % didn't respond even after 1500 msec on go trial - make it easier decrease SSD by step
                if (Ladder2{runnum}(length(Ladder2{runnum}),1)==0)
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
                else
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)-Step;
                end;
                
                
            case 1100
                if respTime{runnum}(Pos,1)>1%  responded after 1500 msec on go trial - make it easier decrease SSD by step
                    if (Ladder1{runnum}(length(Ladder1{runnum}),1)==0)
                        Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
                    else
                        Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)-Step;
                    end;
                end
                
            case 2200 %  responded after 1500 msec on go trial - make it easier decrease SSD by step
                if respTime{runnum}(Pos,1)>1
                    if (Ladder2{runnum}(length(Ladder2{runnum}),1)==0)
                        Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
                    else
                        Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)-Step;
                    end;
                end
                
                
            case 11
                if (Ladder1{runnum}(length(Ladder1{runnum}),1)==1200); %was a GO trial with HV item but responded before SS make it harder - increase SSD by Step/3
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
                else
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)+Step/3;
                end;
                
            case 22
                if (Ladder2{runnum}(length(Ladder2{runnum}),1)==1200); %was a GO trial with HV item but responded before SS make it harder - - increase SSD by Step/3
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
                else
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)+Step/3;
                end;
                
            case 110 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
                if (Ladder1{runnum}(length(Ladder1{runnum}),1)==1200);
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1);
                else
                    Ladder1{runnum}(length(Ladder1{runnum})+1,1)=Ladder1{runnum}(length(Ladder1{runnum}),1)+Step/3;
                end;
                
            case 220 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
                if (Ladder2{runnum}(length(Ladder2{runnum}),1)==1200);
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1);
                else
                    Ladder2{runnum}(length(Ladder2{runnum})+1,1)=Ladder2{runnum}(length(Ladder2{runnum}),1)+Step/3;
                end;
                
                
        end
        KbQueueFlush;
        
        
        %subjid runnum figureshowon onsettime trialtype RT respInTime Audiotime response fixationtime ladder1 ladder2
        fprintf(fid1,'%s %d %s %s %d %d %d %d %d %d %.2f %d %d %d %d\n', subjid, runnum, test_comp, shuff_names{runnum}{Pos}, actual_onset_time{runnum}(Pos,1), demo_stop(Pos), respTime{runnum}(Pos,1)*1000, respInTime{runnum}(Pos,1), Audio_time{runnum}(Pos,1)*1000, keyPressed{runnum}(Pos,1),   fix_time{runnum}(Pos,1)-anchor, Ladder1{runnum}(length(Ladder1{runnum})), Ladder2{runnum}(length(Ladder2{runnum})), shuff_bidIndex{runnum}(Pos), shuff_itemnameIndex{runnum}(Pos));
                                                                            
        
    end; % %% End the big Pos loop showing all the images in one run.
    
    
    
    Ladder1end{runnum}=Ladder1{runnum}(length(Ladder1{runnum}));
    Ladder2end{runnum}=Ladder2{runnum}(length(Ladder2{runnum}));
    correct{runnum}(1)=0;
    
    
    correct{runnum}(1)= length(find(respInTime{runnum}==110 | respInTime{runnum}==220 | respInTime{runnum}==1100 | respInTime{runnum}==2200 ) )
    
    
    
end

mean_RT{runnum}=mean(respTime{runnum}(find(respInTime{runnum}==110 | respInTime{runnum}==220 | respInTime{runnum}==1100 | respInTime{runnum}==2200 ) ));


Screen('TextSize', w, 24); %Set textsize
CenterText(w,strcat(sprintf('You responded on %.2f', ((correct{runnum}(1))/2)*100), '% of Go trials'), white, 0,-270);
Screen('Flip',w);
WaitSecs(3);        

% save data to a file, with date/time stamp
outpath='Output/';
outfile=strcat(outpath, sprintf('%s_demoboosting_demo_%s_%02.0f-%02.0f.mat',subjid,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;
run_info.script_version=script_version;
run_info.revision_date=revision_date;
run_info.script_name=mfilename;
clear food_items demofood_items;

save(outfile);


tmpTime=GetSecs;

% Close the audio device:
PsychPortAudio('Close', pahandle);
%rethrow(lasterror);
Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
WaitSecs(1);

Screen('TextSize',w, 36);
CenterText(w,'The Demo is done.', Green,0,-170);
CenterText(w,sprintf('We will continue shortly..') ,Green,0,0);
Screen('Flip',w);
WaitSecs(3);

Screen('CloseAll');
ShowCursor;

fprintf(['\n \n \n You just ran training demo. Next you want to run \n \n boost_mvpa_train_eye(''' char(subjid) ''',''' test_comp ''',order,' num2str(scan) ',950,950,1) \n \n \n']);
ListenChar(0);
clear all;









