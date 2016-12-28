%=========================================================================
% Probe task code
%=========================================================================

function probe_boost(subjid,test_comp,scan,order)

Screen('Preference', 'VisualDebugLevel', 0);

c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

%subjid=input('Enter subject id used from BDM: ', 's');
%order=input('Enter order 1 or 2 ');
%sort_bdm(subjid);

%test_comp=input('Are you scanning? 2 imac, 1 MRI, 0 if testooom: ');


outpath='Output/';

file=dir([outpath, subjid '_stopGoList_order',num2str(order),'.txt']);
fid=fopen([outpath, sprintf(file(length(file)).name)]);

%%%% Reading in sorted file
vars=textscan(fid, '%s%d%d%d%f') ;% these contain everything from the sortbdm

fclose(fid);

names=vars{1};
stop=vars{2};
%oneSeveral=vars{3};
bidIndex=vars{3};
bid=vars{5};

%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

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
instrSZ=40;
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
        leftstack='b';
        rightstack= 'y';
        badresp='x';
end
%[shuff_names,shuff_ind]=Shuffle(names);
%shuff_stop=stop(shuff_ind);
% shuff_oneSeveral=oneSeveral(shuff_ind);
%-----------------------------------------------------------------
% set phase times

maxtime=2;      % 2 second limit on each selection

%-----------------------------------------------------------------
% stack locations

stackW=576;
stackH=432;

leftRect=[xcenter-stackW-100 ycenter-stackH/2 xcenter-100 ycenter+stackH/2];
rightRect=[xcenter+100 ycenter-stackH/2 xcenter+stackW+100 ycenter+stackH/2];


penWidth=10;


%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

food_items=cell(1,length(names));
for i=1:length(names)

    food_items{i}=imread(sprintf('~/Documents/Boost_Context/stim/%s',names{i}));
end


onsetlist=linspace(0,378,64)+4.8;


%-----------------------------------------------------------------
% determine stimuli to use based on order number

switch order
    case 1
        
        HNG=vars{3}([9 11 15 17]);      %NOGO HIGH;
        LNG=vars{3}([40 42 46 48]);   %'NOGO LOW';
        
    case 2
        
        HNG=vars{3}(bidIndex==[8 12 14 18]);      %NOGO HIGH;
        LNG=vars{3}(bidIndex==[39 43 45 49]);   %'NOGO LOW';
        
end

HG=vars{3}(stop==11);
LG=vars{3}(stop==21);


HG_new=zeros(16,1);
HNG_new=zeros(16,1);

for i=1:4
     for j=1:4
         HG_new(j+(i-1)*4)=HG(i);
         HNG_new(j+(i-1)*4)=HNG(j);
     end
end

LG_new=zeros(16,1);
LNG_new=zeros(16,1);

for i=1:4
     for j=1:4
         LG_new(j+(i-1)*4)=LG(i);
         LNG_new(j+(i-1)*4)=LNG(j);
     end
end

lefthigh=cell(1,2);
stimnum1=cell(1,2);
stimnum2=cell(1,2);
leftname=cell(1,2);
rightname=cell(1,2);
pairtype=cell(1,2);



for block=1:2
    
    pairtype{block}= Shuffle([1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2]);
    
    lefthigh{block}=Shuffle([1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]);
    
    [shuffle_HG_new,shuff_HG_new_ind]=Shuffle(HG_new);
    shuffle_HNG_new=HNG_new(shuff_HG_new_ind);
    
    [shuffle_LG_new,shuff_LG_new_ind]=Shuffle(LG_new);
    shuffle_LNG_new=LNG_new(shuff_LG_new_ind);
    
    H_GNG=1;
    L_GNG=1;
    
    for i=1:32 % trial num within block
        switch pairtype{block}(i)
            case 1 %% High Value Stop vs. Go
                stimnum1{block}(i)=shuffle_HG_new(H_GNG);
                stimnum2{block}(i)=shuffle_HNG_new(H_GNG);
                H_GNG=H_GNG+1;
                if lefthigh{block}(i)==1
                    leftname{block}(i)=names(stimnum1{block}(i));
                    rightname{block}(i)=names(stimnum2{block}(i));
                else
                    leftname{block}(i)=names(stimnum2{block}(i));
                    rightname{block}(i)=names(stimnum1{block}(i));
                end
            case 2 %% Low Value Stop vs. Go
                stimnum1{block}(i)=shuffle_LG_new(L_GNG);
                stimnum2{block}(i)=shuffle_LNG_new(L_GNG);
                L_GNG=L_GNG+1;
                if lefthigh{block}(i)==1
                    leftname{block}(i)=names(stimnum1{block}(i));
                    rightname{block}(i)=names(stimnum2{block}(i));
                else
                    leftname{block}(i)=names(stimnum2{block}(i));
                    rightname{block}(i)=names(stimnum1{block}(i));
                end
        end

    end

end
%ListenChar(2); %suppresses terminal ouput
KbQueueCreate;
%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------


fid1=fopen(['Output/' subjid '_boostprobe_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid scanner order block runtrial onsettime ImageLeft ImageRight TypeLeft TypeRight IsLefthigh Response PairType Outcome RT bidIndexLeft bidIndexRight bidLeft bidRight\n'); %write the header line

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
CenterText(w,'honor your choice on that trial and give you the food item', white,0,5);
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
KbPressWait;

if scan==1
    CenterText(w,'GET READY!', white, 0, 0);
    Screen('Flip',w);
    escapeKey = KbName('space');
    while 1
        [keyIsDown, secs, keyCode] = KbCheck; %#ok<ASGLU>
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end
end

KbQueueStart;

Screen('TextSize',w, betsz);
Screen('DrawText', w, '+', xcenter, ycenter, white);
runStart=Screen(w,'Flip');
%WaitSecs(4);

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runtrial=1;

for block=1:2
    for trial=1:length(stimnum1{block})

        colorleft=black;
        colorright=black;
        out=999;
        %-----------------------------------------------------------------
        % display images
        if lefthigh{block}(trial)==1
            Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
            Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
        else
            Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
            Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
        end
        CenterText(w,'+', white,0,0);
        StimOnset=Screen(w,'Flip', runStart+onsetlist(runtrial));
        KbQueueFlush;

        %-----------------------------------------------------------------
        % get response


        noresp=1;
        goodresp=0;
        while noresp
            % check for response
            [keyIsDown, firstPress] = KbQueueCheck;


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
                if lefthigh{block}(trial)==1
                    out=1;
                else
                    out=0;
                end
            case rightstack
                colorright=yellow;
                if lefthigh{block}(trial)==0
                    out=1;
                else
                    out=0;
                end
        end

        if goodresp==1
            if lefthigh{block}(trial)==1
                Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
                Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
            else
                Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
                Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
            end
            Screen('FrameRect', w, colorleft, leftRect, penWidth);
            Screen('FrameRect', w, colorright, rightRect, penWidth);
            CenterText(w,'+', white,0,0);
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime);

        else
            Screen('DrawText', w, 'Please respond faster!', xcenter-300, ycenter, white);
            Screen(w,'Flip',runStart+onsetlist(runtrial)+2);
        end


        %-----------------------------------------------------------------
        % show fixation ITI
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+2.4);

        if goodresp ~= 1
            respTime=999;
        end

        %-----------------------------------------------------------------
        % write to output file 
      if lefthigh{block}(trial)==1    
                                                                         
        fprintf(fid1,'%s %d %d %d %d %d %s %s %d %d %d %s %d %d %f %d %d %f %f \n', subjid, scan, order, block, runtrial, StimOnset-runStart, char(leftname{block}(trial)), char(rightname{block}(trial)), stop(vars{3}==stimnum1{block}(trial)), stop(vars{3}==stimnum2{block}(trial)), lefthigh{block}(trial), keyPressed, pairtype{block}(trial), out, respTime, bidIndex(stimnum1{block}(trial)), bidIndex(stimnum2{block}(trial)),bid(stimnum1{block}(trial)), bid(stimnum2{block}(trial)));
 
      else
          
         fprintf(fid1,'%s %d %d %d %d %d %s %s %d %d %d %s %d %d %f %d %d %f %f \n', subjid, scan, order, block, runtrial, StimOnset-runStart, char(leftname{block}(trial)), char(rightname{block}(trial)), stop(vars{3}==stimnum2{block}(trial)), stop(vars{3}==stimnum1{block}(trial)), lefthigh{block}(trial), keyPressed, pairtype{block}(trial), out, respTime, bidIndex(stimnum2{block}(trial)), bidIndex(stimnum1{block}(trial)),bid(stimnum2{block}(trial)), bid(stimnum1{block}(trial)));
      end
      
        runtrial=runtrial+1;
        KbQueueFlush;
    end
end


fclose(fid1);

Screen('TextSize',w, betsz);
CenterText(w,'Thank you!', yellow,0,-100);
CenterText(w,'please get the experimenter', yellow,0,0);

Screen('Flip', w, StimOnset+12);
WaitSecs(5);

if scan==1
    fprintf(['\n \n \n You just ran probe( `' subjid '`,' num2str(order) ',' num2str(test_comp) '). Next you want to run one_sev( `' subjid '`,2,One/Several_order' num2str(MRI) ') \n \n \n']);
end

% noresp=1;
% while noresp
%     [keyIsDown,secs,keyCode] = KbCheck;
%     if find(keyCode)==44 & keyIsDown & noresp
%         noresp = 0;
%     end
% end

%time=clock;
outfile=strcat(outpath, sprintf('%s_boostprobe_%s_%02.0f-%02.0f.mat',subjid,date,c(4),c(5)));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear food_items ;
save(outfile);


%ListenChar(0);
ShowCursor;
Screen('closeall');




