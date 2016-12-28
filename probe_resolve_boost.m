function probe_resolve_boost(subjid)

%subjid=input('Enter subject id used for BDM: ', 's');

tmp=dir(['Output/' subjid '_boostprobe_*.txt']);
fid=fopen(['Output/' tmp(length(tmp)).name]); %tmp(length(tmp)).name
probe=textscan(fid, '%s %d %d %d %d %d %s %s %d %d %d %s %d %d %f %d %d %f %f', 'Headerlines',1);
                     

%  fprintf(fid1,'%s %d %d %d %s %s %d %d %d %s %d %d %.2f %.2f %.2f \n', subjid, test_comp, runtrial, onsetlist(runtrial), char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum1{block}(trial), stimnum2{block}(trial), lefthigh{block}(trial), keyPressed, pairtype{block}(trial), out, respTime*1000, bidIndex(stimnum1{block}(trial)), bidIndex(stimnum2{block}(trial)));


fclose(fid);


trial_choice=ceil(rand()*64);
%if probe{9}>0

leftpic=probe{7}(trial_choice);
rightpic=probe{8}(trial_choice);
if strcmp(probe{12}(trial_choice),'u') || strcmp(probe{12}(trial_choice),'b')
   choice=leftpic;
else
   choice=rightpic;
end



% else
%  leftpic=probe{6}(trial_choice);
% rightpic=probe{5}(trial_choice);   
% 
% if strcmp(probe{10}(trial_choice),'u')
%    choice=leftpic
% else
%    choice=leftpic
% end
% 
% end

fid=fopen(['Output/' subjid '_probe_resolve.txt'],'a');


    fprintf(fid,'%s %s %s %s %s %s %s \n', 'In the choice between', char(leftpic), 'and', char(rightpic), 'participant chose', char(choice), 'they receive this item.');

%     fprintf(fid,'%s %s %s %s %s %s %s \n', 'In the choice between', char(leftpic(t)), 'and', char(rightpic(t)), 'the subject chose', char(rightpic(t)), 'they receive this item.');
% end
fclose(fid);
    
    