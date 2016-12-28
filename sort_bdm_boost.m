
function sort_bdm_boost(subjid,order)

%load oneSeveral.mat;

path='Output';

file=dir([path '/' subjid '_BDM1*']);                       %determine BDM output file for subject subjid

fid=fopen([path '/' sprintf(file(length(file)).name)]);     %if multiple BDM files, open the last one
C=textscan(fid, '%d%s%f%d' , 'HeaderLines', 1);     %red in BDM output file into C
fclose(fid);

[names_sort,names_sort_ind]=sort(C{2}); %sorting by item name for later oneSeveral comparison
sorted_bids=C{3}(names_sort_ind); %sorting the bids based on the item name sort to later determine oneSeveral
%present_ind_sort=C{1}(names_sort_ind); % this is the order by which items were presented in the BDM sorted according to name

M(:,1)=sorted_bids; %bids of items sorted alphabetically 
M(:,2)=1:56; %index sort by bid so I can sort images later 
%M(:,3)=oneSeveral; % order of items sorted by name to determine nonSeveral


sortedM=sortrows(M,-1);      %Sort descending indices by bid - sorts also the present_ind_sort (order of presentation index from BDM) and the item index to determine ChoclateNon

sortedlist(1:56,1)=cell(1);

for i=1:56
    sortedlist(i,1)=names_sort(sortedM(i,2)); %creates the name list based on the sorted list of bids
end

	
%%% add in the type - stop/go high/low to the sorted list.
sortedM(:,3)=0;

switch order
    case 1
        
        sortedM([8 12 14 18],3)=11;      %GO HIGH;
        sortedM([2 3 5 6 9 11 15 17 20 21 23 24],3)=12;      %NOGO HIGH;
        
        sortedM([39 43 45 49],3)=21;   %'GO LOW';
        sortedM([33 34 36 37 40 42 46 48 51 52 54 55],3)=22;   %'NOGO LOW';
        
    case 2
        
        sortedM([9 11 15 17],3)=11;      %GO HIGH;
        sortedM([2 3 5 6 8 12 14 18 20 21 23 24],3)=12;      %NOGO HIGH;
        
        sortedM([40 42 46 48],3)=21;   %'GO LOW';
        sortedM([33 34 36 37 39 43 45 49 51 52 54 55],3)=22;   %'NOGO LOW';
        
end

sortedM([1 4 7 10 13 16 19 22 25:32 35 38 41 44 47 50 53 56],3)=30;   %'LOCALIZER';

           
fid=fopen([path '/' subjid sprintf('_stopGoList_order%d.txt', order)], 'w');    

for i=1:length(M)
             %write out the full list with the bids and also which item will be a stop item
    fprintf(fid, '%s\t%d\t%d\t%d\t%d\n', sortedlist{i,1},sortedM(i,3),i,sortedM(i,2),sortedM(i,1)); %  item names ; GO/NGO ; item_indeex_bid ; item index name ; bid
end
fprintf(fid, '\n');
fclose(fid);

