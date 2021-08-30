
%%% written by D.S.JOKHUN on 02/03/2018



function [XYZ,MetaData]=img_reader(filename)

% filename='1_3D of day 3 fib.nd2'
    
    Reader = bfGetReader (filename);
    OmeMeta = Reader.getMetadataStore();
    
    MetaData.SeriesCount = Reader.getSeriesCount();
    MetaData.TimePoints = OmeMeta.getPixelsSizeT(0).getValue();
    MetaData.Num_of_Ch = OmeMeta.getPixelsSizeC(0).getValue();
    MetaData.Num_of_Pixels_Z = OmeMeta.getPixelsSizeZ(0).getValue();
    MetaData.Num_of_Pixels_X = OmeMeta.getPixelsSizeX(0).getValue();
    MetaData.Num_of_Pixels_Y = OmeMeta.getPixelsSizeY(0).getValue();
    MetaData.Voxel_Size_X = double(OmeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROM)); % in µm
    MetaData.Voxel_Size_Y = double(OmeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROM)); % in µm
    MetaData.Voxel_Size_Z = double(OmeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROM)); % in µm
%     MetaData.Plane_Origin_X = double(OmeMeta.getPlanePositionX(0,0).value);
%     MetaData.Plane_Origin_Y = double(OmeMeta.getPlanePositionY(0,0).value);
%     MetaData.Plane_Origin_Z = double(OmeMeta.getPlanePositionZ(0,0).value);
    
    MetaData.ChannelID = [];
    for ch_count = 1:MetaData.Num_of_Ch ;
        chID_temp = ['   ' char(num2str(ch_count-1)) '.'] ;
        chNAME_temp= [char(OmeMeta.getChannelName(0,ch_count-1))];
        MetaData.ChannelID = [MetaData.ChannelID  chID_temp chNAME_temp];  % (series 0, channel ch_count)
    end
    
    MetaData.Filename=filename;
    
    MetaData
    
    
    
    %%% loading particular 3D frames
    for iSeries = 1%:MetaData.SeriesCount  %%%choosing a specific XY 3D point from the multipoint image
        %         iSeries
        XYZ=[];
        Reader.setSeries(iSeries - 1);
        for iT=1%:MetaData.TimePoints
%             iT
            for iCh=1%:MetaData_2hr.Num_of_Ch;
                XYZ_temp =uint16([]);
                
                for iZ=1:MetaData.Num_of_Pixels_Z
                    iPlane = Reader.getIndex(iZ-1, iCh-1, iT-1) + 1;     %%% The last '1-1' is for timepoint 0 (the 1st timepoint)
                    XYZ_temp(:,:,iZ)= bfGetPlane(Reader, iPlane);
                end
                
                XYZ=XYZ_temp; 
%                 XYZ{iCh}=XYZ_temp;   %%% 1st element of XYZ will be a 3D matrix of series 1 (XY1) in Channel 1
                %%% 2st element of XYZ will be a 3D matrix of series 1 (XY1) in Channel 2
            end
            
            
            %%% {XYZ} currently has the 3D intensity matrices of all the channels at iT(timepoint iT) from iSeries(multipoint i) found in file f
            %% PERFORM ANALYSIS BELOW!!!
            

            %% PERFORM ANALYSIS ABOVE!!!
        end
    end
    
end