


%%% written by D.S.JOKHUN on 19/03/2018



function T_chro_comp=chromatin_compaction(filename,segmented_raw)


rslt_filename=cell(size(segmented_raw,2),1);
I80_by_I20 = zeros(size(segmented_raw,2),1);
nHigh_by_nLow = zeros(size(segmented_raw,2),1);

parfor nuclei_count=1:size(segmented_raw,2)
    
    rslt_filename{nuclei_count,1}=filename;
    
    I_exclude_percentiles=prctile(single(nonzeros(segmented_raw{1,nuclei_count})),[0.1,99.9]);   %elimimating extreme values from the image (e.g saturated pixels etc.)
    aft_excl_extremes=segmented_raw{1,nuclei_count}.*uint16(segmented_raw{1,nuclei_count}>=I_exclude_percentiles(1)).*uint16(segmented_raw{1,nuclei_count}<=I_exclude_percentiles(2));
    
    I_percentiles=prctile(single(nonzeros(aft_excl_extremes)),[20,80]);
    I80_by_I20(nuclei_count,1)=I_percentiles(2)/I_percentiles(1);
    
    normalize_aft_excl_extremes=mat2gray(nonzeros(aft_excl_extremes));
    nHigh_by_nLow(nuclei_count,1)=sum(normalize_aft_excl_extremes>=0.8)/sum(normalize_aft_excl_extremes<=0.2);
    
end

T_chro_comp = table;
T_chro_comp.Filename = rslt_filename;
T_chro_comp.I80_by_I20=I80_by_I20;
T_chro_comp.nHigh_by_nLow=nHigh_by_nLow;



end


