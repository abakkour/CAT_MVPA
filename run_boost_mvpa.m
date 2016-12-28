
subjid=input(['Enter subject ID: '],'s');
scan=str2num(input('Are you scanning? 1(yes) 0(no): ','s'));
test_comp=input('What computer are you using?: ','s');
order=str2num(input('Enter the subject order number (1 or 2): ','s'));
eye=str2num(input('Are you using the eyetracker? 1(yes) 0(no): ','s'));

LADDER1IN=950;
LADDER2IN=950;

if eye==1
    check_eyetracker
    eye=str2num(input('Use eyetracker?: 1(yes) 0(no) ','s'));
end

if eye==1
    
    sort_bdm_boost(subjid,order);
    
    boost_mvpa_localizer_demo(subjid,test_comp,scan);
    
    for runnum=1:2
        input(['Continue to localizer run ' num2str(runnum) '? : Enter to continue.. '],'s');
        boost_mvpa_localizer_eye(subjid,test_comp,scan,order,runnum);
    end
    
    
    input('Continue to training demo? : Enter to continue..','s');
    boost_mvpa_train_demo(subjid,test_comp,scan,LADDER1IN,LADDER2IN);
    
    
    for runnum=1:6
        input(['Continue to training run ' num2str(runnum) '? : Enter to continue.. '],'s');
        boost_mvpa_train_eye(subjid,test_comp,order,scan,LADDER1IN, LADDER2IN,runnum);
    end
    
    input('Continue to BIS? : Enter to continue.. ','s');
    BIS(subjid, scan);
    
    input('Continue to probe demo? : Enter to continue.. ','s');
    boost_mvpa_probe_demo(subjid,test_comp,scan);
    
    input('Continue to probe? : Enter to continue.. ','s');
    boost_mvpa_probe_eye(subjid,test_comp,scan,order);
    probe_resolve_boost(subjid);
        
elseif eye==0
    
    runloc=input('Run localizer training?: y(yes) n(no) ','s');
    if runloc=='y'
        boost_mvpa_localizer_demo(subjid,test_comp,scan);
    end
    
    sort_bdm_boost(subjid,order);
    
    for runnum=1:2
        input(['Continue to localizer run ' num2str(runnum) '? : Enter to continue.. '],'s');
        boost_mvpa_localizer_noeye(subjid,test_comp,scan,order,runnum);
    end
    
    input('Continue to training demo? : Enter to continue..','s');
    boost_mvpa_train_demo(subjid,test_comp,scan,LADDER1IN,LADDER2IN);
    
    
    for runnum=1:6
        input(['Continue to training run ' num2str(runnum) '? : Enter `y` to continue.. '],'s');
        boost_mvpa_train_noeye(subjid,test_comp,order,scan,LADDER1IN, LADDER2IN,runnum);
    end
    
    input('Continue to BIS? : Enter to continue.. ','s');
    BIS(subjid, scan);
    
    input('Continue to probe demo? : Enter to continue.. ','s');
    boost_mvpa_probe_demo(subjid,test_comp,scan);
    
    input('Continue to probe? : Enter to continue.. ','s');
    boost_mvpa_probe_noeye(subjid,test_comp,scan,order);
    probe_resolve_boost(subjid);

end




    
    
  

