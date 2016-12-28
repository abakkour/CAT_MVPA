%=========================================================================
% One/Several task code
%=========================================================================
function beep_no_beep(subjid,scan,order1,order2)


Screen('Preference', 'VisualDebugLevel', 0);
c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'


%
% subjid=input('Enter subject id used from BDM: ', 's');
% order=input('Enter order 1 or 2 ');
% %sort_bdm(subjid);
% 
% test_comp=input('Are you scanning? 2 imac, 1 MRI, 0 if testooom: ');


scanflag=scan;



outpath='Output/';



%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

screens=Screen('Screens');
screenNumber=max(screens);
pixelSize=32;
[w] = SCREEN('OpenWindow',screenNumber,[],[],pixelSize);


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
betsz=40;
Screen('TextSize',w, instrSZ);

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');
switch scanflag
    case 0
        leftstack='u';
        rightstack= 'i';
        badresp='x';
    case 1
        leftstack='b';
        rightstack= 'y';
        badresp='x';
end


%-----------------------------------------------------------------
% set phase times

maxtime=1;


%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------


food_images=dir ('stim/*.bmp');


shuffledlist=Shuffle(1:length(food_images));
imgArrays=cell(1,length(food_images));
for i=1:length(shuffledlist)
    
    imgArrays{i}=imread(['stim/' food_images(shuffledlist(i)).name],'bmp');
end

% r=Shuffle(1:4);
% onsetlist=load(['onsets/beep_onset_' num2str(r(1)) '.mat']);
% onsetlist=onsetlist.onsetlist;

%ListenChar(2); %suppresses terminal ouput
KbQueueCreate;
%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen(['Output/' subjid '_beepnobeep_' timestamp '.txt'], 'a');
fprintf(fid1,'subjid runtrial onsettime Name resp_beep RT order\n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, instrSZ);


if order1==1
    CenterText(w,'Press `u` if you heard a beep when this item was presented ,', white,0,-100);
    CenterText(w,'Press `i` if there was no beep when this item was presented', white, 0,0);
else
    CenterText(w,'Press `u` if there was no beep when this item was presented,', white,0,-100);
    CenterText(w,'Press `i` if you heard a beep when this item was presented', white, 0,0);
end


CenterText(w,'Press any key to continue', yellow,0,300);
HideCursor;
Screen('Flip', w);
KbPressWait;

if scanflag==1
    CenterText(w,'GET READY!', white, 0, 0);
    Screen('Flip',w);
    escapeKey = KbName('space');
    while 1
        [keyIsDown,secs,keyCode] = KbCheck(-1); %#ok<ASGLU>
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end
end

Screen('TextSize',w, betsz);
Screen('DrawText', w, '+', xcenter, ycenter, white);
Screen(w,'Flip');


%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runStart=GetSecs;

for trial=1:56
    
    
    %-----------------------------------------------------------------
    % display image
    % FOR using large pictures as features:
    
    WaitSecs(1);
    Screen('PutImage',w,imgArrays{trial});
    
if order1==1
    CenterText(w,'u - beep', white,-200,250);
    CenterText(w,'i - no beep ', white, 200,250);
else
    CenterText(w,'u - no beep', white,-200,250);
    CenterText(w,'i - beep', white, 200,250);
end    
    
    StimOnset=Screen(w,'Flip');
    
    KbQueueStart;
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
        
        
    end
    
    
    %-----------------------------------------------------------------
    
    
    % determine what bid to highlight
    
    switch keyPressed
        
        case leftstack
            response=1;
            
        case rightstack
            response=0;
    end
    
        
    WaitSecs(.5);
    
    Screen('TextSize',w, betsz);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen(w,'Flip');
    
    if goodresp ~= 1
        response=999;
        respTime=999;
    end
    

    
    %-----------------------------------------------------------------
    % write to output file
    
    fprintf(fid1,'%s %d %d %s %d %d %d \n', subjid, trial, StimOnset-runStart, food_images(shuffledlist(trial)).name, response, respTime, order1);
    KbQueueFlush;
end




WaitSecs(1);
Screen('TextSize',w, betsz);
CenterText(w,'Thank you! Please call the experimenter', yellow,0,0);
Screen('Flip', w);
WaitSecs(3);



    outfile=strcat(outpath, sprintf('%s_beepnobeep_%s_%02.0f-%02.0f.mat',subjid,date,c(4),c(5)));
    
    % create a data structure with info about the run
    run_info.subject=subjid;
    run_info.date=date;
    run_info.outfile=outfile;
    
    run_info.script_name=mfilename;
    clear imgArrays ;
    save(outfile);




ShowCursor;
Screen('closeall');




