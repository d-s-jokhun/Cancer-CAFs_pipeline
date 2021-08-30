


%%% written by D.S.JOKHUN on 05/04/2018





function [segmented_bw_2d,segmented_raw_2d]=segment_n_basics_TimePoint(labelled_segments_rough,XYZ,MetaData,label_idx)

segmented_bw_2d=false(MetaData.Num_of_Pixels_X,MetaData.Num_of_Pixels_Y,MetaData.num_of_nuc);
segmented_raw_2d=uint16([]);
rslt_filename={};
rslt_nuc_num=single([]);
rslt_pro_area=single([]);
rslt_AR=single([]);
rslt_surface_roundness=single([]);
parfor good_nuclei_count=1:MetaData.num_of_nuc;
    indi_process=labelled_segments_rough==label_idx(good_nuclei_count,6);
    indi_process_1= imdilate(imdilate(indi_process,strel('disk',round(5/MetaData.Voxel_Size_X))),strel('sphere',round(6/MetaData.Voxel_Size_Z))); %5um in xy and 6um in Z
    raw_indi_2D_process= uint16(sum((uint16(indi_process_1).*XYZ),3));
    smoothened_indi_2D_process=imgaussfilt3(raw_indi_2D_process,5,'FilterSize',(2*ceil((1/MetaData.Voxel_Size_X)/2))+1); % filter size of 1um
    pre_segmented_bw_2d=imbinarize(smoothened_indi_2D_process);
    
    CC_pre_segmented_bw_2d=bwconncomp(pre_segmented_bw_2d);   % there could be parts of surrounding nuclei in the field since we did some dilation in line 18
    [~, max_index] = max(cellfun('size', CC_pre_segmented_bw_2d.PixelIdxList, 1));
    temp_field=false(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y);
    temp_field(CC_pre_segmented_bw_2d.PixelIdxList{max_index})=1;
    segmented_bw_2d(:,:,good_nuclei_count)=temp_field;
    segmented_raw_2d(:,:,good_nuclei_count)=uint16(temp_field).*raw_indi_2D_process;
    

end


end






