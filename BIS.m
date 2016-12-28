%=========================================================================
% BIS task code (5/15/2012 AB)
%=========================================================================

function BIS(sinit, scanflag)


Screen('Preference', 'VisualDebuglevel', 0);
c=clock;
hr=num2str(c(4));
min=num2str(c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));       %#ok<RAND> % resets 'randomization'

%---------------------------------------------------------------
%% 'GET user input' DISABLED TO USE WRAPPER
%---------------------------------------------------------------

% % input checkers
% oktype=[0 1 2];
% okscan=[0 1];
% % okrun=[1 2];
% % 
% % % get subject code
% sinit=input('Subject code: ','s');
% while isempty(sinit)
%     disp('ERROR: no value entered. Please try again.');
%     sinit=input('Subject code:','s');
% end
% 
% load(['Output/',sinit,'_last.mat']);
% load(['Output/',sinit,'_list.mat']);
% 
% if lastorder==1 && strcmp(last,'rprobe') ~= 1
%     disp(['ERROR: ',last, ' run last. Must be rprobe']);
%     break
% elseif lastorder==2 && strcmp(last,'training1') ~= 1
%     disp(['ERROR: ',last, ' run last. Must be training1']);
%     break
% 
% end

% 
% % get run number
% runNum=input('First(1) or Second(2) run?: ');
% while isempty(runNum) || sum(okrun==runNum)~=1
%     disp('ERROR: input must be 1 or 2. Please try again.');
%     runNum=input('First(1) or Second(2) run?: ');
% end
% 
% % get run type
% runType=input('Demo(0), self-run(2) or Study(1) ?');
% while isempty(runType) || sum(oktype==runType)~=1
%     disp('ERROR: input must be 0, 1, or 2. Please try again.');
%     runType=input('Demo(0), self-run(2) or Study(1) ?');
% end
% 
% % is this a scan?
% scanflag=input('Are you scanning? yes(1) or no(0)');
% while isempty(scanflag) || sum(okscan==scanflag)~=1
%     disp('ERROR: input must be 0 or 1. Please try again.');
%     scanflag=input('Are you scanning? yes(1) or no(0)');
% end



%---------------------------------------------------------------
%% 'INITIALIZE Screen variables'
%---------------------------------------------------------------

screenNumber = max(Screen('Screens'));
pixelSize=32;
[w] = Screen('OpenWindow',screenNumber,[],[],pixelSize);


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
instrSZ=32;
betsz=45;
Screen('TextSize',w, instrSZ);

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');
switch scanflag
    case 0
        leftstack='u';
        midleftstack= 'i';
        midrightstack='o';
        rightstack='p';
        
    case 1
        leftstack='b';
        midleftstack= 'y';
        midrightstack='g';
        rightstack='r';
        
end

%-----------------------------------------------------------------
% set phase times

%maxtime=4;      % 4 second limit on each selection


ListenChar(2);
KbQueueCreate;

%---------------------------------------------------------------
%% Questions
%---------------------------------------------------------------

qlist={'I plan tasks carefully.' 'I do things without thinking.' 'I make up my mind quickly.' 'I am happy-go-lucky.' 'I don`t ``pay attention``.' 'I have ``racing`` thoughts.' 'I plan trips well ahead of time.' 'I am self-controlled.' 'I concentrate easily.' 'I save regularly.' 'I ``squirm`` at plays or lectures.' 'I am a careful thinker.' 'I plan for job security.' 'I say things without thinking.' 'I like to think about complex problems.' 'I change jobs.' 'I act ``on impulse``.' 'I get easily bored when solving thought problems.' 'I act on the spur of the moment.' 'I am a steady thinker.' 'I change where I live.' 'I buy things on impulse.' 'I can only think about one problem at a time.' 'I change hobbies.' 'I spend or charge more than I earn.' 'I have outside thoughts when thinking.' 'I am more interested in the present than the future.'  'I am restless at lectures or talks.' 'I like puzzles.' 'I plan for the future.'};

%onsetlist=[0    4.5000    9.0000   13.5000   18.0000   22.5000   27.0000   31.5000   36.0000   40.5000   45.0000   49.5000   54.0000   58.5000   63.0000 67.5000   72.0000   76.5000   81.0000   85.5000   90.0000   94.5000   99.0000  103.5000  108.0000  112.5000  117.0000  121.5000  126.0000  130.5000];

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen(['Output/' sinit '_BIS_' timestamp '.txt'], 'a');
fprintf(fid1,'sinit, scanner, runtrial, question, Response, RT \n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, instrSZ);
CenterText(w,'Please fill in the following questionnaire on the screen.', white,0,-200);
CenterText(w,'Read the statement carefully and select the appropriate response below.', white,0,-100);
CenterText(w,'Please answer quickly and honestly.', white,0,0);

switch scanflag
    case 0
        CenterText(w,'Select the appropriate answer using the `u` `i` `o` or `p`', white,0,100);
        CenterText(w,'button on the keyboard.', white,0,200);
    case 1
        CenterText(w,'Select the appropriate answer using the 1, 2, 3 or 4', white,0,100);
        CenterText(w,'button on the keypad.', white,0,200);
end

CenterText(w,'Press any key to continue', yellow,0,300);
HideCursor;
Screen('Flip', w);
KbPressWait;


%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
%runStart=GetSecs;

for trial=1:length(qlist)

    colorright=white;
    colormidright=white;
    colormidleft=white;
    colorleft=white;

    %-----------------------------------------------------------------
    % set image
    Screen('TextSize',w, betsz);
    CenterText(w,qlist{trial}, white,0,-150);
    Screen('TextSize',w, instrSZ);
    Screen('DrawText', w, 'Rarely/Never', xcenter-500, ycenter+100, white);
    Screen('DrawText', w, 'Occasionally', xcenter-150, ycenter+100, white);
    Screen('DrawText', w, 'Often', xcenter+150, ycenter+100, white);
    Screen('DrawText', w, 'Almost Always', xcenter+300, ycenter+100, white);

    StimOnset=Screen(w,'Flip');
    KbQueueStart;

    %-----------------------------------------------------------------
    % get response
    
    
    noresp=1;

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
                case midleftstack
                    respTime=firstPress(KbName(midleftstack))-StimOnset;
                    noresp=0;
                case midrightstack
                    respTime=firstPress(KbName(midrightstack))-StimOnset;
                    noresp=0;
                case rightstack
                    respTime=firstPress(KbName(rightstack))-StimOnset;
                    noresp=0;
            end
        end


        % check for reaching time limit
%         if noresp && GetSecs-runStart >= onsetlist(trial)+maxtime
%             noresp=0;
%             keyPressed=badresp;
%             respTime=maxtime;
% 
%         end
    end

    %-----------------------------------------------------------------

    
    % determine what bid to highlight
    
    switch keyPressed
        case leftstack
            colorleft=yellow;
            bid=1;
            
        case midleftstack
            colormidleft=yellow;
            bid=2;
            
        case midrightstack
            colormidright=yellow;
            bid=3;
            
        case rightstack
            colorright=yellow;
            bid=4;
    end

    Screen('TextSize',w, betsz);
    CenterText(w,qlist{trial}, white,0,-150);
    Screen('TextSize',w, instrSZ);
    Screen('DrawText', w, 'Rarely/Never', xcenter-500, ycenter+100, colorleft);
    Screen('DrawText', w, 'Occasionally', xcenter-150, ycenter+100, colormidleft);
    Screen('DrawText', w, 'Often', xcenter+150, ycenter+100, colormidright);
    Screen('DrawText', w, 'Almost Always', xcenter+300, ycenter+100, colorright);
    Screen(w,'Flip');
    WaitSecs(1);
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, betsz);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen(w,'Flip');
    WaitSecs(1);

    
    %-----------------------------------------------------------------
    % write to output file
    
    fprintf(fid1,'%s, %d, %d, %s, %d, %d \n', sinit, scanflag, trial, qlist{trial}, bid, respTime); 
    KbQueueFlush;
end

last='BIS';
save(['Output/',sinit,'_last.mat'],'last')



Screen('TextSize',w, betsz);
CenterText(w,'Great job! Thank you!', yellow,0,0);
CenterText(w,'We will continue shortly.', yellow,0,100);
Screen('Flip', w);
WaitSecs(3);

ListenChar(0);

fprintf(['\n \n \n You just ran BIS. Next you want to run \n \n boost_mvpa_probe_demo(''' sinit ''',test_comp,scan) \n \n \n']);

% noresp=1;
% while noresp
%     [keyIsDown,secs,keyCode] = KbCheck;
%     if find(keyCode)==44 & keyIsDown & noresp
%         noresp = 0;
%     end
% end


ShowCursor();
Screen('closeall');




