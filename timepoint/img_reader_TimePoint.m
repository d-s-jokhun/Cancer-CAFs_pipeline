
%%% written by D.S.JOKHUN on 02/03/2018



function [XYZ]=img_reader_TimePoint(MetaData,iT)

    
    Reader = bfGetReader (MetaData.Filename);
    


        Reader.setSeries(0);
        
        XYZ=cell(MetaData.Num_of_Ch,1);

            for iCh=1%:MetaData.Num_of_Ch;
                XYZ_temp =uint16(zeros(MetaData.Num_of_Pixels_Y,MetaData.Num_of_Pixels_X,MetaData.Num_of_Pixels_Z));
                for iZ=1:MetaData.Num_of_Pixels_Z
                    iPlane = Reader.getIndex(iZ-1, iCh-1, iT-1) + 1;     %%% The last '1-1' is for timepoint 0 (the 1st timepoint)
                    XYZ_temp(:,:,iZ)= bfGetPlane(Reader, iPlane);
                end
                
                XYZ{iCh,1}=XYZ_temp; 
%                 XYZ{iCh}=XYZ_temp;   %%% 1st element of XYZ will be a 3D matrix of series 1 (XY1) in Channel 1
                %%% 2st element of XYZ will be a 3D matrix of series 1 (XY1) in Channel 2
            end
            
            
            %%% {XYZ} currently has the 3D intensity matrices of all the channels at iT(timepoint iT) from iSeries(multipoint i) found in file f
            %% PERFORM ANALYSIS BELOW!!!
            

            %% PERFORM ANALYSIS ABOVE!!!
        

    
end

