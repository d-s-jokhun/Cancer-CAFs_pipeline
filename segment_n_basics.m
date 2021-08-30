


%%% written by D.S.JOKHUN on 02/03/2018





function [segmented_bw_2d,segmented_raw_2d, clean_bw_2d, clean_raw_2d, T_basic_measurements]=segment_n_basics(filename,labelled_segments_rough,XYZ,MetaData,good_nuclei)

segmented_bw_2d={};
segmented_raw_2d={};
rslt_filename={};
rslt_nuc_num=single([]);
rslt_pro_area=single([]);
rslt_AR=single([]);
rslt_surface_roundness=single([]);
rslt_PDI=single([]);
rslt_centre_mismatch=single([]);
parfor good_nuclei_count=1:size(good_nuclei,2);
    indi_process=labelled_segments_rough==good_nuclei(good_nuclei_count);
    indi_process_1= imdilate(imdilate(indi_process,strel('disk',50)),strel('sphere',2));
    raw_indi_2D_process= uint16(sum((uint16(indi_process_1).*XYZ),3));
    smoothened_indi_2D_process=imgaussfilt3(raw_indi_2D_process,5,'FilterSize',11);
    pre_segmented_bw_2d=imbinarize(smoothened_indi_2D_process);
    
    CC_pre_segmented_bw_2d=bwconncomp(pre_segmented_bw_2d);   % there could be parts of surrounding nuclei in the field since we did some dilation in line 18
    [~, max_index] = max(cellfun('size', CC_pre_segmented_bw_2d.PixelIdxList, 1));
    temp_field=false(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y);
    temp_field(CC_pre_segmented_bw_2d.PixelIdxList{max_index})=1;
    segmented_bw_2d{1,good_nuclei_count}=temp_field;
    segmented_raw_2d{1,good_nuclei_count}=uint16(temp_field).*raw_indi_2D_process;
    
    stats_temp_field=regionprops(temp_field,(uint16(temp_field).*raw_indi_2D_process),'Area','MajorAxisLength','MinorAxisLength','Perimeter', 'Centroid','WeightedCentroid');
    
    rslt_filename{good_nuclei_count,1}=filename;
    rslt_nuc_num(good_nuclei_count,1)=good_nuclei(good_nuclei_count);  %identity of nucleus from the image
    rslt_pro_area(good_nuclei_count,1)=(stats_temp_field.Area * (MetaData.Voxel_Size_X*MetaData.Voxel_Size_Y));
    rslt_AR(good_nuclei_count,1)=(stats_temp_field.MajorAxisLength/stats_temp_field.MinorAxisLength);
    rslt_surface_roundness(good_nuclei_count,1)= ((stats_temp_field.Perimeter^2)/(4*pi*stats_temp_field.Area));
    
    distance_frm_cen_squared=zeros(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y);
    for countX=1:MetaData.Num_of_Pixels_X
        for countY=1:MetaData.Num_of_Pixels_Y
            distance_frm_cen_squared(countY,countX)=((sqrt(((countX-stats_temp_field.Centroid(1))^2)...
                +((countY-stats_temp_field.Centroid(2))^2)))...
                *MetaData.Voxel_Size_X).^2;
        end
    end
    actual_IntMoment_2=distance_frm_cen_squared.*mat2gray(uint16(temp_field).*raw_indi_2D_process);
    total_NormInt=sum(sum(mat2gray(uint16(temp_field).*raw_indi_2D_process)));
    uniform_IntMoment_2=distance_frm_cen_squared.*(double(temp_field)*(total_NormInt/stats_temp_field.Area));
    rslt_PDI(good_nuclei_count,1)=sum(sum(actual_IntMoment_2))/sum(sum(uniform_IntMoment_2));
    
    rslt_centre_mismatch(good_nuclei_count,1)=(sqrt(((stats_temp_field.WeightedCentroid(1)-stats_temp_field.Centroid(1))^2)...
        +((stats_temp_field.WeightedCentroid(2)-stats_temp_field.Centroid(2))^2)))...
        *MetaData.Voxel_Size_X;

    
end

clean_bw_2d=uint8(sum(cat(3,segmented_bw_2d{:}),3));  %element-wise addition of all matrices within a cell
jpeg_name_clean=[filename,'_cleanBW.jpg'];
imwrite(double(clean_bw_2d),jpeg_name_clean)

clean_raw_2d=uint16(sum(cat(3,segmented_raw_2d{:}),3));

T_basic_measurements = table; 
T_basic_measurements.Filename = rslt_filename;
T_basic_measurements.Nuc_num=rslt_nuc_num;
T_basic_measurements.Pro_area=rslt_pro_area;
T_basic_measurements.AR=rslt_AR;
T_basic_measurements.Surface_roundness=rslt_surface_roundness;
T_basic_measurements.PDI=rslt_PDI;
T_basic_measurements.Centre_mismatch=rslt_centre_mismatch;




end






