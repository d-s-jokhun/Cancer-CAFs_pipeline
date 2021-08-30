
%%% written by D.S.JOKHUN on 02/03/2018


clear all
clc


filenames = dir (['*.nd2']);


%%
'loading images'
tic
XYZ={};
MetaData={};
parfor reader_count=1:size(filenames,1);
    filename = filenames(reader_count).name
    [XYZ{reader_count},MetaData{reader_count}]=img_reader(filename)
end
toc
%%


%%
tic
'Rough segmentation and labelling'
AutoLabelled_segments_rough={};
AutoLabelled_segments_rough_2D={};
parfor RoughLabelling_count=1:size(XYZ,2)
    filename = filenames(RoughLabelling_count).name
    [AutoLabelled_segments_rough{RoughLabelling_count},AutoLabelled_segments_rough_2D{RoughLabelling_count}]=rough_seg_3D(filename,XYZ{1,RoughLabelling_count},MetaData{RoughLabelling_count});
end
toc
%%


%%
tic
'Proper segmentation and basic measurements'
segmented_bw_2d=cell(1,size(AutoLabelled_segments_rough,2));
segmented_raw_2d=cell(1,size(AutoLabelled_segments_rough,2));
clean_bw_2d=cell(1,size(AutoLabelled_segments_rough,2));
clean_raw_2d=cell(1,size(AutoLabelled_segments_rough,2));
basic_measurements=cell(1,size(AutoLabelled_segments_rough,2));
for CleanSegment_count1=1:size(AutoLabelled_segments_rough,2)   %use parfor only if number of workers needed is very high (~to number of workers available). Otherwise parfor is more useful inside segment_n_basics.
    filename = filenames(CleanSegment_count1).name

if CleanSegment_count1==1
    good_nuclei=[1:4,6,9:10,12:19,21];                          % as identified from images saved from rough_seg_3D
end
if CleanSegment_count1==2
    good_nuclei=[1,3,5:7,9,11,12,15,17:22,25];
end
if CleanSegment_count1==3
    good_nuclei=[1,3:7,9,10,12:15,17:21];
end


    
    
    
    [segmented_bw_2d{CleanSegment_count1},segmented_raw_2d{CleanSegment_count1},clean_bw_2d{CleanSegment_count1},clean_raw_2d{CleanSegment_count1},basic_measurements{CleanSegment_count1}]...
        =segment_n_basics(filename,AutoLabelled_segments_rough{1,CleanSegment_count1},XYZ{1,CleanSegment_count1},MetaData{CleanSegment_count1},good_nuclei);

end
result_measurements_combined=vertcat(basic_measurements{1:end});

for CleanSegment_count2=1:size(clean_bw_2d,2)
    figure('Name',[num2str(CleanSegment_count2),'binary mask'],'Visible', 'on')
    imshow(clean_bw_2d{CleanSegment_count2},[],'InitialMagnification','fit')
    
%     figure('Name',[num2str(CleanSegment_count2),'raw'],'Visible', 'on')
%     imshow(sum(XYZ{1,CleanSegment_count2},3),[],'InitialMagnification','fit')
end

toc
%%



%%
tic
chro_comp=cell(1,size(segmented_raw_2d,2));
for chro_comp_cell_count=1:size(segmented_raw_2d,2)
    filename = filenames(chro_comp_cell_count).name
    chro_comp{1,chro_comp_cell_count}=chromatin_compaction(filename,segmented_raw_2d{1,chro_comp_cell_count});
end
chro_comp_combined=vertcat(chro_comp{1:end});
result_measurements_combined.I80_by_I20=chro_comp_combined.I80_by_I20;
result_measurements_combined.nHigh_by_nLow=chro_comp_combined.nHigh_by_nLow;



toc
%%



