
%%% written by D.S.JOKHUN on 02/03/2018


clear all
% clc

filenames = dir (['006_2hr of * co.nd2']);


%%
tic
MetaData={};
tif_idx={};
'Importing Metadata'
parfor meta_count=1:size(filenames,1);
    
    Reader = bfGetReader (filenames(meta_count).name);
    OmeMeta = Reader.getMetadataStore();
    MetaData_temp=[];
    MetaData_temp.Filename = filenames(meta_count).name;
    MetaData_temp.SeriesCount = Reader.getSeriesCount();
    MetaData_temp.TimePoints = OmeMeta.getPixelsSizeT(0).getValue();
    MetaData_temp.Num_of_Ch = OmeMeta.getPixelsSizeC(0).getValue();
    MetaData_temp.Num_of_Pixels_Z = OmeMeta.getPixelsSizeZ(0).getValue();
    MetaData_temp.Num_of_Pixels_X = OmeMeta.getPixelsSizeX(0).getValue();
    MetaData_temp.Num_of_Pixels_Y = OmeMeta.getPixelsSizeY(0).getValue();
    MetaData_temp.Voxel_Size_X = double(OmeMeta.getPixelsPhysicalSizeX(0).value); % in µm
    MetaData_temp.Voxel_Size_Y = double(OmeMeta.getPixelsPhysicalSizeY(0).value); % in µm
    MetaData_temp.Voxel_Size_Z = double(OmeMeta.getPixelsPhysicalSizeZ(0).value); % in µm
    %     MetaData_temp.Voxel_Size_X = double(OmeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM)); % in µm
    %     MetaData_temp.Voxel_Size_Y = double(OmeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM)); % in µm
    %     MetaData_temp.Voxel_Size_Z = double(OmeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)); % in µm
    MetaData_temp.Plane_Origin_X = double(OmeMeta.getPlanePositionX(0,0).value);
    MetaData_temp.Plane_Origin_Y = double(OmeMeta.getPlanePositionY(0,0).value);
    MetaData_temp.Plane_Origin_Z = double(OmeMeta.getPlanePositionZ(0,0).value);
    
    MetaData_temp.ChannelID = [];
    for ch_count = 1:MetaData_temp.Num_of_Ch ;
        chID_temp = ['   ' char(num2str(ch_count-1)) '.'] ;
        chNAME_temp= [char(OmeMeta.getChannelName(0,ch_count-1))];
        MetaData_temp.ChannelID = [MetaData_temp.ChannelID  chID_temp chNAME_temp];  % (series 0, channel ch_count)
    end
    
    MetaData{meta_count,1}=MetaData_temp;
    
    
    %     %
    %     Reader_tif = bfGetReader ([filenames(meta_count).name,'.ims.tif']);
    %     OmeMeta_tif = Reader_tif.getMetadataStore();
    %     MetaData_temp_tif=[];
    %     MetaData_temp_tif.TimePoints = OmeMeta_tif.getPixelsSizeT(0).getValue();
    %     MetaData_temp_tif.Num_of_Ch = OmeMeta_tif.getPixelsSizeC(0).getValue();
    %     MetaData_temp_tif.Num_of_Pixels_Z = OmeMeta_tif.getPixelsSizeZ(0).getValue();
    %
    %     tif_idx_temp=zeros(MetaData_temp_tif.Num_of_Pixels_Z,MetaData_temp_tif.TimePoints,MetaData_temp_tif.Num_of_Ch);
    %     for iCh=1:MetaData_temp_tif.Num_of_Ch
    %         for iT=1:MetaData_temp_tif.TimePoints
    %             for iZ=1:MetaData_temp_tif.Num_of_Pixels_Z
    %                 tif_idx_temp(iZ,iT,iCh) = Reader_tif.getIndex(iZ-1, iCh-1, iT-1) + 1;
    %             end
    %         end
    %     end
    %     tif_idx{meta_count,1}=tif_idx_temp;
    %
    %     %OR the following if there is only 1 channel in the tiff file
    
    tif_idx{meta_count,1}=reshape(1:(MetaData_temp.TimePoints*MetaData_temp.Num_of_Pixels_Z),[MetaData_temp.Num_of_Pixels_Z,MetaData_temp.TimePoints]);
    
    
end
clear filenames
toc
%%





%%
tic
XYZ={};
ran_labelled_segments_rough={};

for reader_count=1:size(MetaData,1);
    'importing images and random_labelled_segs'
    reader_count
    parfor iT=1:MetaData{reader_count}.TimePoints
    
        
        XYZ{reader_count,iT}=img_reader_TimePoint(MetaData{reader_count},iT)
        
        for iZ=1:MetaData{reader_count}.Num_of_Pixels_Z
            ran_labelled_segments_rough{reader_count,iT}(:,:,iZ)=imread([MetaData{reader_count}.Filename,'.ims.tif'], tif_idx{reader_count,1}(iZ,iT));
        end
        
    end
end

clear reader_count tif_idx
toc

%%


%%
tic
'importing label xls files'
label_idx=cell(size(MetaData,1),1);
parfor xls_count=1:size(MetaData,1);
    label_idx{xls_count,1}=xlsread([MetaData{xls_count}.Filename,'.ims.xls'])
    
end

labelled_segments_rough=cell(size(ran_labelled_segments_rough));
for xls_count=1:size(label_idx,1);
    'relabelling segments'
    xls_count
    for time_count=1:size(ran_labelled_segments_rough,2)
        labelled_segments_rough{xls_count,time_count}=uint8(zeros(size(ran_labelled_segments_rough{xls_count,time_count})));
    end
    
    for int_count=1:size(label_idx{xls_count, 1},1)
        labelled_segments_rough{xls_count,label_idx{xls_count,1}(int_count,5)}(ran_labelled_segments_rough{xls_count,label_idx{xls_count,1}(int_count,5)}==label_idx{xls_count,1}(int_count,1))=label_idx{xls_count,1}(int_count,6);
    end
    
    MetaData{xls_count,1}.num_of_nuc=size(label_idx{xls_count, 1},1)/max(label_idx{xls_count,1}(:,5));
    
end

clear xls_count time_count int_count ran_labelled_segments_rough

toc
%%


%%
tic

segmented_bw_2d_temp={};
segmented_raw_2d_temp={};

for file_count=1:size(MetaData,1)   %use parfor only if number of workers needed is very high (~to number of workers available). Otherwise parfor is more useful inside segment_n_basics.
    'segmentation'
    file_count
    parfor iT_count=1:MetaData{file_count}.TimePoints
        
        [segmented_bw_2d_temp{file_count,iT_count},segmented_raw_2d_temp{file_count,iT_count}]=segment_TimePoint(labelled_segments_rough{file_count,iT_count},XYZ{file_count,iT_count}{1},MetaData{file_count},label_idx{file_count,1});
        
    end
    
end
clear file_count XYZ labelled_segments_rough
toc
%%



%%
tic
segmented_bw_2d={};
segmented_raw_2d={};
for file_count=1:size(MetaData,1)
    'rearranging and saving segments'
    parfor obj_count=1:MetaData{file_count}.num_of_nuc;
        obj_count
        for time_count=1:MetaData{file_count}.TimePoints
            segmented_bw_2d{file_count,obj_count}(:,:,time_count)=segmented_bw_2d_temp{file_count,time_count}(:,:,obj_count);
            segmented_raw_2d{file_count,obj_count}(:,:,time_count)=segmented_raw_2d_temp{file_count,time_count}(:,:,obj_count);
            if time_count==1
                imwrite(uint8((segmented_bw_2d_temp{file_count,time_count}(:,:,obj_count))*255),[MetaData{file_count}.Filename,'_',num2str(label_idx{file_count,1}(obj_count,6)),'BW2d.tif'],'WriteMode','overwrite','Compression','none')
                imwrite(segmented_raw_2d_temp{file_count,time_count}(:,:,obj_count),[MetaData{file_count}.Filename,'_',num2str(label_idx{file_count,1}(obj_count,6)),'Raw2d.tif'],'WriteMode','overwrite','Compression','none')
            else
                imwrite(uint8((segmented_bw_2d_temp{file_count,time_count}(:,:,obj_count))*255),[MetaData{file_count}.Filename,'_',num2str(label_idx{file_count,1}(obj_count,6)),'BW2d.tif'],'WriteMode','append','Compression','none')
                imwrite(segmented_raw_2d_temp{file_count,time_count}(:,:,obj_count),[MetaData{file_count}.Filename,'_',num2str(label_idx{file_count,1}(obj_count,6)),'Raw2d.tif'],'WriteMode','append','Compression','none')
            end
        end
        
    end
    
    
    
end

clear file_count segmented_bw_2d_temp segmented_raw_2d_temp

toc
%%





