

%%% written by D.S.JOKHUN on 09/04/2018

tic

clear all
% clc

filenames = dir (['*2hr of day 2 fib_timepoint ana.mat']);


label_idx={};
MetaData={};
segmented_bw_2d={};
segmented_raw_2d={};

'loading data'

for load_count=1:size(filenames,1)
    load_count
    temp_label_idx(load_count,1) = parfeval(@load,1,filenames(load_count).name, 'label_idx');
    temp_MetaData(load_count,1) = parfeval(@load,1,filenames(load_count).name, 'MetaData');
    temp_segmented_bw_2d(load_count,1) = parfeval(@load,1,filenames(load_count).name, 'segmented_bw_2d');
    temp_segmented_raw_2d(load_count,1) = parfeval(@load,1,filenames(load_count).name, 'segmented_raw_2d');
    
end

temp_label_idx=fetchOutputs(temp_label_idx);
temp_MetaData=fetchOutputs(temp_MetaData);
temp_segmented_bw_2d=fetchOutputs(temp_segmented_bw_2d);
temp_segmented_raw_2d=fetchOutputs(temp_segmented_raw_2d);


for load_count1=1:size(filenames,1)
    
    label_idx(end+1:end+size(temp_label_idx(load_count1).label_idx,1),1:size(temp_label_idx(load_count1).label_idx,2))=temp_label_idx(load_count1).label_idx(:,:);
    MetaData(end+1:end+size(temp_MetaData(load_count1).MetaData,1),1:size(temp_MetaData(load_count1).MetaData,2))=temp_MetaData(load_count1).MetaData(:,:);
    segmented_bw_2d(end+1:end+size(temp_segmented_bw_2d(load_count1).segmented_bw_2d,1),1:size(temp_segmented_bw_2d(load_count1).segmented_bw_2d,2))=temp_segmented_bw_2d(load_count1).segmented_bw_2d(:,:);
    segmented_raw_2d(end+1:end+size(temp_segmented_raw_2d(load_count1).segmented_raw_2d,1),1:size(temp_segmented_raw_2d(load_count1).segmented_raw_2d,2))=temp_segmented_raw_2d(load_count1).segmented_raw_2d(:,:);
    
end


clear filenames load_count load_count1 temp*

toc
%%


%% Basic measurements
tic
'Basic Measurements'
total_num_of_objs=0;
for count=1:size(MetaData,1)
    total_num_of_objs=total_num_of_objs+MetaData{count}.num_of_nuc;
end


Pro_area_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
AR_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
Shape_factor_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
PDI_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
Centre_mismatch_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
I80_by_I20_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);
nHigh_by_nLow_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs);

Centroid_temp=zeros(MetaData{1}.TimePoints,total_num_of_objs*2);

num_of_obj_processed=0;
for file_count=1:size(MetaData,1)
    file_count
    [Pro_area_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        AR_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        Shape_factor_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        PDI_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        Centre_mismatch_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        I80_by_I20_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        nHigh_by_nLow_temp(:,num_of_obj_processed+1:num_of_obj_processed+MetaData{file_count}.num_of_nuc),...
        Centroid_temp(:,(num_of_obj_processed*2)+1:(num_of_obj_processed*2)+((MetaData{file_count}.num_of_nuc))*2)]...
        =...
        basic_measurements_TimePoint(MetaData{file_count},segmented_bw_2d(file_count,1:MetaData{file_count}.num_of_nuc),segmented_raw_2d(file_count,1:MetaData{file_count}.num_of_nuc));
    
    total_num_of_objs
    num_of_obj_processed=num_of_obj_processed+MetaData{file_count}.num_of_nuc
end

time=zeros(MetaData{1}.TimePoints,1);
time(1:end,1)=(0:MetaData{1}.TimePoints-1);
header=cell(1,total_num_of_objs+1);
header{1,1}='Time(min)';
header_Cen=cell(1,(total_num_of_objs*2)+1);
header_Cen{1,1}='Time(min)';
nuc_label=0;
for file_count=1:size(MetaData,1)
    for nuc_count=1:MetaData{file_count}.num_of_nuc
        nuc_label=nuc_label+1;
        header{1,nuc_label+1}=[MetaData{file_count}.Filename,' - Nuc ',num2str(label_idx{file_count}(nuc_count,6))];
        header_Cen{1,nuc_label*2}=[MetaData{file_count}.Filename,' - Nuc ',num2str(label_idx{file_count}(nuc_count,6))];
        header_Cen{1,(nuc_label*2)+1}=[MetaData{file_count}.Filename,' - Nuc ',num2str(label_idx{file_count}(nuc_count,6))];
    end
end

Result_Pro_Area=vertcat(header,num2cell(horzcat(time,Pro_area_temp)));
Result_AR=vertcat(header,num2cell(horzcat(time,AR_temp)));
Result_Shape_factor=vertcat(header,num2cell(horzcat(time,Shape_factor_temp)));
Result_PDI=vertcat(header,num2cell(horzcat(time,PDI_temp)));
Result_Centre_mismatch=vertcat(header,num2cell(horzcat(time,Centre_mismatch_temp)));
Result_I80_by_I20=vertcat(header,num2cell(horzcat(time,I80_by_I20_temp)));
Result_nHigh_by_nLow=vertcat(header,num2cell(horzcat(time,nHigh_by_nLow_temp)));
Result_Centroid=vertcat(header_Cen,num2cell(horzcat(time,Centroid_temp)));

clear count file_count nuc_count nuc_label num_of_obj_processed time total_num_of_objs

toc
%%



