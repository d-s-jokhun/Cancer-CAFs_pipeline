


%%% written by D.S.JOKHUN on 25/04/2018




function [Pro_area, AR, Shape_factor, PDI, Centre_mismatch, I80_by_I20, nHigh_by_nLow, Centroid]=basic_measurements_TimePoint(MetaData,segmented_bw_2d,segmented_raw_2d)


Pro_area=[];
AR=[];
Shape_factor=[];
PDI=[];
Centre_mismatch=[];
I80_by_I20=[];
nHigh_by_nLow=[];

Centroid=zeros(MetaData.TimePoints,MetaData.num_of_nuc*2);

for nuc_count=1:MetaData.num_of_nuc;
    nuc_count
    CentroidX=[];
    CentroidY=[];
    parfor time_count=1:MetaData.TimePoints
        bw=segmented_bw_2d{1,nuc_count}(:,:,time_count);
        raw=segmented_raw_2d{1,nuc_count}(:,:,time_count);
        stats=regionprops(bw,raw,'Area','MajorAxisLength','MinorAxisLength','Perimeter', 'Centroid','WeightedCentroid');
        
        Pro_area(time_count,nuc_count)=(stats.Area * (MetaData.Voxel_Size_X*MetaData.Voxel_Size_Y));
        AR(time_count,nuc_count)=(stats.MajorAxisLength/stats.MinorAxisLength);
        Shape_factor(time_count,nuc_count)=((stats.Perimeter^2)/(4*pi*stats.Area));
        
        distance_frm_cen_squared=zeros(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y);
        for countX=1:MetaData.Num_of_Pixels_X
            for countY=1:MetaData.Num_of_Pixels_Y
                distance_frm_cen_squared(countY,countX)=((sqrt(((countX-stats.Centroid(1))^2)...
                    +((countY-stats.Centroid(2))^2)))...
                    *MetaData.Voxel_Size_X).^2;
            end
        end
        actual_IntMoment_2=distance_frm_cen_squared.*mat2gray(raw);
        total_NormInt=sum(sum(mat2gray(raw)));
        uniform_IntMoment_2=distance_frm_cen_squared.*(double(bw)*(total_NormInt/stats.Area));
        PDI(time_count,nuc_count)=sum(sum(actual_IntMoment_2))/sum(sum(uniform_IntMoment_2));
        
        Centre_mismatch(time_count,nuc_count)=(sqrt(((stats.WeightedCentroid(1)-stats.Centroid(1))^2)...
            +((stats.WeightedCentroid(2)-stats.Centroid(2))^2)))...
            *MetaData.Voxel_Size_X;
        
        
        
        I_exclude_percentiles=prctile(single(nonzeros(raw)),[0.1,99.9]);   %elimimating extreme values from the image (e.g saturated pixels etc.)
        aft_excl_extremes=raw.*uint16(raw>=I_exclude_percentiles(1)).*uint16(raw<=I_exclude_percentiles(2));
        
        I_percentiles=prctile(single(nonzeros(aft_excl_extremes)),[20,80]);
        I80_by_I20(time_count,nuc_count)=I_percentiles(2)/I_percentiles(1);
        
        normalize_aft_excl_extremes=mat2gray(nonzeros(aft_excl_extremes));
        nHigh_by_nLow(time_count,nuc_count)=sum(normalize_aft_excl_extremes>=0.8)/sum(normalize_aft_excl_extremes<=0.2);
        
        
        
        
        CentroidX(time_count,1)=stats.Centroid(1);
        CentroidY(time_count,1)=stats.Centroid(2);
        
        
        
    end
    
    Centroid(:,(nuc_count*2)-1)=CentroidX;
    Centroid(:,(nuc_count*2))=CentroidY;
    
end




end






