
%%% written by D.S.JOKHUN on 02/03/2018



function [AutoLabelled_segments_rough,AutoLabelled_segments_rough_2D]=rough_seg_3D(filename,XYZ,MetaData)


%             imtool(sum(XYZt{1,1},3),[])
%             imshow(sum(XYZt{1,1},3),[])
processing_1=imfill(imdilate(imdilate(imerode(XYZ>0,strel('disk',5)),strel('disk',3)),strel('sphere',1)),'holes');
%             imtool(sum(processing_1,3),[])
processing_2=medfilt3(uint16(processing_1).*XYZ,[15 15 3]);

processing_3=imbinarize(processing_2);

%             imtool(sum(processing_3,3))
processing_4=imclearborder(processing_3,8);
%             imtool(sum(processing_4,3))

CC_processing_4 = bwconncomp(processing_4);

rough_segmentation = false(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y, MetaData.Num_of_Pixels_Z);
for segment_count=1:size(CC_processing_4.PixelIdxList,2)
    if size(CC_processing_4.PixelIdxList{segment_count},1)>10000  % volume filter of segment
        area_filter=false(MetaData.Num_of_Pixels_X, MetaData.Num_of_Pixels_Y, MetaData.Num_of_Pixels_Z);
        area_filter(CC_processing_4.PixelIdxList{segment_count})=1;
        if sum(sum(sum(area_filter,3)>0))>5000   % projected area filter of segment
            rough_segmentation(CC_processing_4.PixelIdxList{segment_count})=1;
        end
    end
end
%             imtool(sum(segmentation_1,3))

CC_segmentation=bwconncomp(rough_segmentation);
AutoLabelled_segments_rough = labelmatrix(CC_segmentation);
segment_cen = regionprops(AutoLabelled_segments_rough, 'Centroid');

AutoLabelled_segments_rough_2D=uint8([]);
AutoLabelled_segments_rough_2D(1:size(AutoLabelled_segments_rough,1),1:size(AutoLabelled_segments_rough,2))=0;
for segment_count=1:max(max(max(AutoLabelled_segments_rough)))
    AutoLabelled_segments_rough_2D=AutoLabelled_segments_rough_2D+uint8(((sum(AutoLabelled_segments_rough==segment_count,3)>0)*double(segment_count)));
end



jpeg_name_gray=[filename,'_gray.jpg'];
figure('Name',jpeg_name_gray,'Visible', 'off');
%             imshow(label2rgb(labelled_segments_2D),'InitialMagnification','fit');
imshow(sum(XYZ,3),[],'InitialMagnification','fit');
hold on
text(size(AutoLabelled_segments_rough_2D,1)/2, 10, [filename,' (',num2str(segment_count),')'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
    'FontSize',15,'FontWeight','bold','BackgroundColor','w');
for obj_count = 1:size(segment_cen,1)
    text(segment_cen(obj_count).Centroid(1), segment_cen(obj_count).Centroid(2), num2str(obj_count), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',...
        'FontSize',8,'FontWeight','normal','BackgroundColor','w');
end
saveas(gcf,jpeg_name_gray)
hold off



jpeg_name_RGB=[filename,'_RGB.jpg'];
figure('Name',jpeg_name_RGB,'Visible', 'off');
imshow(label2rgb(AutoLabelled_segments_rough_2D),'InitialMagnification','fit');
%             imshow(sum(XYZt_2hr{1,1},3),[],'InitialMagnification','fit');
hold on
text(size(AutoLabelled_segments_rough_2D,1)/2, 10, [filename,' (',num2str(segment_count),')'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
    'FontSize',15,'FontWeight','bold','BackgroundColor','w');
for obj_count = 1:size(segment_cen,1)
    text(segment_cen(obj_count).Centroid(1), segment_cen(obj_count).Centroid(2), num2str(obj_count), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',...
        'FontSize',8,'FontWeight','normal','BackgroundColor','w');
end
saveas(gcf,jpeg_name_RGB)
hold off


end







