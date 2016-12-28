%=========================================================================
% Probe task code
%=========================================================================

function boost_mvpa_probe_demo(subjid,test_comp,scan)

Screen('Preference', 'VisualDebugLevel', 0);


c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

%subjid=input('Enter subject id: ', 's');
%order=input('Enter order 1 or 2 ');
%sort_bdm(subjid);
%test_comp=input('Are you scanning? 2 imac, 1 MRI, 0 if testooom: ');


outpath='Output/';
% 
% file=dir([outpath, subjid '_stopGoList*']);
% fid=fopen([outpath, sprintf(file(length(file)).name)]);
% %%%% Reading in sorted file
% vars=textscan(fid, '%s%d%d%d%d%d') ;% these contain everything from the sortbdm
% 
% names=vars{1};
% stop=vars{2};
% %oneSeveral=vars{3};
% bidIndex=vars{4};

fid=fopen('demo_items.txt');
demonames=textscan(fid,'%s');
fclose(fid);


%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

pixelSize=32;
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);

% Here Be Colors
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
yellow=[0 255 0];


% set up screen positions for stimuli
[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

% text stuffs
theFont='Arial';
Screen('TextFont',w,theFont);
instrSZ=30;
betsz=60;
Screen('TextSize',w, instrSZ);

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');
%MRI=0;
switch scan
    case 0
        leftstack='u';
        rightstack= 'i';
        badresp='x';
    case 1
        trigger='t';
        leftstack='b';
        rightstack= 'y';
        badresp='999';
end
% [shuff_names,shuff_ind]=Shuffle(names);
% shuff_stop=stop(shuff_ind);
% shuff_oneSeveral=oneSeveral(shuff_ind);
%-----------------------------------------------------------------
% set phase times

maxtime=1.5;      % 1.5 second limit on each selection

%-----------------------------------------------------------------
% stack locations

stackW=576*.6;
stackH=432*.6;

leftRect=[xcenter-stackW-150 ycenter-stackH/2 xcenter-150 ycenter+stackH/2];
rightRect=[xcenter+150 ycenter-stackH/2 xcenter+stackW+150 ycenter+stackH/2];


penWidth=10;


%%% add in the type - stop/go high/low to the sorted list.
%if order ==1
%sortedM([6 8 10 12 14    16 18 20 22 24] ,4)=11; %stop High ?
%sortedM([1:5 7 9 11 13 15    17 19 21 23 25 26:30],4)=12; % go High
%sortedM([36 38 40 42 44 46 48 50 52 54] ,4)=22; % stop Low
%sortedM([31:35 37 39 41 43 45 47 49 51 53 55 56:60],4)=24 % go Low

%else
    
% sortedM([7 9 11 13 15     17 19 21 23 25] ,4)=11; %stop High
%sortedM([1:5 6 8 10 12 14     16 18 20 22 24 26:30],4)=12; % go High
%sortedM([37 39 41 43 45 47 49 51 53 55] ,4)=22; % stop Low
%sortedM([31:35 36 38 40 42 44 46 48 50 52 54 56:60],4)=24 % go Low

%end

%Comparisons - HighStop vs. HighGo 6-7 8-9 10-11 12-13 14-15
            %- LowStop vs. LowGo 46-47 48-49 50-51 52-53 54-55
            
           % order 1 % HighStop vs. LowStop 16-36 18-38 20-40 22-42 24-44 
           % order 1 % HighGo vs. LowGo 17-37 19-39 21-41 23-43 25-45 

           % order 2 % HighStop vs. LowStop 17-37 19-39 21-41 23-43 25-45 
           % order 2 % HighGo vs. LowGo 16-36 18-38 20-40 22-42 24-44 

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

demofood_items=cell(8,1);
for i=1:length(demonames{1})
    
    demofood_items{i}=imread(sprintf('stim/demo/%s',char(demonames{1}(i))));
    
end
%




% fid=fopen(['Output/' subjid '_high.txt']);
% high_food_images=textscan(fid, '%s');
% fclose(fid);
% fid=fopen(['Output/' subjid '_low.txt']);
% low_food_images=textscan(fid, '%s');
% fclose(fid);
% imgArraysHigh=cell(1,length(high_food_images{1}));
% imgArraysLow=cell(1,length(low_food_images{1}));

% for i=1:length(food_items{1})
% 
%     imgArraysHigh{i}=imread(['stim/' char(high_food_images{1}(i))],'bmp');
%     imgArraysLow{i}=imread(['stim/' char(low_food_images{1}(i))],'bmp');
% 
% end


onsetlist=linspace(0,18,4)+4.8;


%-----------------------------------------------------------------
% determine stimuli to use based on order number

HH_HS=[1 2 3 4];
HH_HG=[5 6 7 8];

stimnum1=cell(1,1);
stimnum2=cell(1,1);
leftname=cell(1,1);
rightname=cell(1,1);
lefthigh{1}=[1 0 1 0];
pairtype{1}=[1 1 1 1];
block=1;

for i=1:4 % trial num within block
    
    
    stimnum1{block}(i)=HH_HS(i);
    stimnum2{block}(i)=HH_HG(i);
    
    if lefthigh{block}(i)==1
        leftname{block}(i)=demonames{1}(stimnum1{block}(i));
        rightname{block}(i)=demonames{1}(stimnum2{block}(i));
    else
        leftname{block}(i)=demonames{1}(stimnum1{block}(i));
        rightname{block}(i)=demonames{1}(stimnum2{block}(i));
    end
    
end


ListenChar(2); %suppresses terminal ouput
KbQueueCreate;
%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen(['Output/' subjid '_demo_boostprobe_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid scanner runtrial onsettime ImageLeft ImageRight TypeLeft TypeRight IsLefthigh Response PairType Outcome RT \n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, instrSZ);
% CenterText(w,'This is similar to the choice part you did before.', white,0,-380);
% CenterText(w,'However this time there are NO POINTS associated with the items.', white,0,-325);
CenterText(w,'In this part two pictures of food items will be presented on the screen.', white,0,-270);
CenterText(w,'For each trial, we want you to choose one of the items using the keyboard.', white,0,-215);
CenterText(w,'You will have 1.5 seconds to make your choice on each trial, so please', white,0,-160);
CenterText(w,'try to make your choice quickly.', white,0,-105);
CenterText(w,'At the end of this part we will choose one trial at random and', white,0,-50);
CenterText(w,'honor your choice on that trial and give you the food item.', white,0,5);
CenterText(w,'Press any key to continue', white,0,180);

switch scan
    case 0
        CenterText(w,'Please use the `u` or `i` keys on the keyboard ', white,0,60);
        CenterText(w,'for the left and right items respectively.', white, 0,100);
    case 1
        CenterText(w,'1 or 2 keys on the keypad for the left and right item respectively.', white,0,60);
end
HideCursor;
Screen('Flip', w);
KbPressWait(-1);

Screen('TextSize',w, betsz);
Screen('DrawText', w, '+', xcenter, ycenter, white);
runStart=Screen(w,'Flip');
%WaitSecs(4);

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runtrial=1;

for block=1:1
    for trial=1:4

        colorleft=black;
        colorright=black;
        out=999;
        %-----------------------------------------------------------------
        % display images
        if lefthigh{block}(trial)==1
            Screen('PutImage',w,demofood_items{stimnum1{block}(trial)}, leftRect);
            Screen('PutImage',w,demofood_items{stimnum2{block}(trial)}, rightRect);
        else
            Screen('PutImage',w,demofood_items{stimnum2{block}(trial)}, leftRect);
            Screen('PutImage',w,demofood_items{stimnum1{block}(trial)}, rightRect);
        end
        CenterText(w,'+', white,0,0);
        StimOnset=Screen(w,'Flip', runStart+onsetlist(runtrial));
        KbQueueStart;

        %-----------------------------------------------------------------
        % get response


        noresp=1;
        goodresp=0;
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
                    case leftstack
                        respTime=firstPress(KbName(leftstack))-StimOnset;
                        noresp=0;
                        goodresp=1;
                    case rightstack
                        respTime=firstPress(KbName(rightstack))-StimOnset;
                        noresp=0;
                        goodresp=1;
                end
            end


            % check for reaching time limit
            if noresp && GetSecs-runStart >= onsetlist(runtrial)+maxtime
                noresp=0;
                keyPressed=badresp;
                respTime=maxtime;

            end
        end


        %-----------------------------------------------------------------


        % determine what bid to highlight

        switch keyPressed
            case leftstack
                colorleft=yellow;
                if lefthigh{block}(trial)==0
                    out=1;
                else
                    out=0;
                end
            case rightstack
                colorright=yellow;
                if lefthigh{block}(trial)==1
                    out=1;
                else
                    out=0;
                end
        end

        if goodresp==1
            if lefthigh{block}(trial)==1
                Screen('PutImage',w,demofood_items{stimnum1{block}(trial)}, leftRect);
                Screen('PutImage',w,demofood_items{stimnum2{block}(trial)}, rightRect);
            else
                Screen('PutImage',w,demofood_items{stimnum2{block}(trial)}, leftRect);
                Screen('PutImage',w,demofood_items{stimnum1{block}(trial)}, rightRect);
            end
            Screen('FrameRect', w, colorleft, leftRect, penWidth);
            Screen('FrameRect', w, colorright, rightRect, penWidth);
            CenterText(w,'+', white,0,0);
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime);

        else
            Screen('DrawText', w, 'Please respond faster!', xcenter-300, ycenter, white);
            Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime);
        end


        %-----------------------------------------------------------------
        % show fixation ITI
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5);

        if goodresp ~= 1
            respTime=999;
        end

        %-----------------------------------------------------------------
        % write to output file
                                                                    
        fprintf(fid1,'%s %d %d %d %s %s %d %d %d %s %d %d %f \n', subjid, scan, runtrial, StimOnset-runStart, char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum1{block}(trial), stimnum2{block}(trial), lefthigh{block}(trial), keyPressed, pairtype{block}(trial), out, respTime);

        runtrial=runtrial+1;
        KbQueueFlush;
    end
end




Screen('TextSize',w, betsz);
CenterText(w,'The Demo is done.', yellow,0,0);
CenterText(w,'We will continue shortly.', yellow,0,100);

Screen('Flip', w, StimOnset+5);
WaitSecs(3);


% noresp=1;
% while noresp
%     [keyIsDown,secs,keyCode] = KbCheck;
%     if find(keyCode)==44 & keyIsDown & noresp
%         noresp = 0;
%     end
% end

fclose(fid1);

time=clock;
outfile=strcat(outpath, sprintf('%s_boostprobe_demo_%s_%02.0f-%02.0f.mat',subjid,date,time(4),time(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear food_items demofood_items ;

save(outfile);


ListenChar(0);
ShowCursor;

fprintf(['\n \n \n You just ran probe demo. Next you want to run \n \n boost_mvpa_probe_eye(''' subjid ''',test_comp,' num2str(scan) ',order) \n \n \n']);
ListenChar(0);
Screen('closeall');
clear all;




