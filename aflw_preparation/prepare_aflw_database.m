
PDOLLAR_ANNONTATION_VERSION = 4; % Version 4 adds the positive subclass index
ADD_VERTICALLY_FLIPPED_IMAGES = true; %false;

SUBDIR = 'flickr';
dataRoot= fullfile(PREPARED_DATA_PATH, 'aflw_pdollar_format_headhunter_rectangular_bb');
%dataRoot= fullfile(PREPARED_DATA_PATH, 'aflw_pdollar_format_headhunter_rectangular_bb_without_flipped');
gt_annotations_file = 'aflw_preparation/aflw_ann_headhunter.txt';        
flippedImagesPath = fullfile(PREPARED_DATA_PATH, 'aflw_flipped/images');

show_images = false;

mkdir(fullfile(dataRoot,'images'));
mkdir(fullfile(dataRoot,'1'));
mkdir(fullfile(dataRoot,'2'));
mkdir(fullfile(dataRoot,'3'));
mkdir(fullfile(dataRoot,'4'));
mkdir(fullfile(dataRoot,'5'));
mkdir(fullfile(dataRoot,'annotations'));

%% Construct training set
fid=fopen(gt_annotations_file); 
%fmt = '%s %f %f %f %f %f %f %f *[^\n]';
fmt = '%s %f %f %f %f %f %f %f %s %d %f %[^\n]'; %%*[^\n]';
data = textscan(fid, fmt, 'Delimiter', ',', 'CommentStyle', '#', 'CollectOutput', true); 
fclose(fid);

if ADD_VERTICALLY_FLIPPED_IMAGES
% Create flipped training set if it does not exists
if ~exist(flippedImagesPath, 'dir')
  mkdir(flippedImagesPath);
  N = length(data{1});
  for i=1:N   
     % Link Image
     full_path_file = data{1}{i};
     %disp(full_path_file);
     [pathstr, file_name, ext] = fileparts(full_path_file);
     inImg = fullfile(AFLW_PATH,SUBDIR,data{1}{i});
     disp(inImg);
     full_path = fullfile(flippedImagesPath, pathstr);
     if ~exist(full_path, 'dir')
       mkdir(full_path);
     end
     outImg = fullfile(full_path, [file_name '_flipped' ext]);

     % Check if it is a color image, if not, we don't use it.
     I = imread(inImg);
     if length(size(I)) < 3
%         I2 = zeros(size(I,1), size(I,2), 3);
%         I2(:,:,1) = I;
%         I2(:,:,2) = I;
%         I2(:,:,3) = I;
%         I = I2;
       continue;
     end     
     for c=1:3
       I(:,:,c) = fliplr(I(:,:,c));
     end

     if show_images
       imshow(I);
%       pause;
     end;
     imwrite(I, outImg);
  end
end
end

% Process images.
N = length(data{1});
for i=1:N
  currbb = [data{2}(i,1) data{2}(i,2) data{2}(i,3) data{2}(i,4)];
  yaw = data{2}(i,5);
  pitch = data{2}(i,6);
  roll = data{2}(i,7);
    
  % We initially perform classification of faces depending on the 
  % yaw angle only: Partitions of head hunter paper.
  if (yaw < -60) && (roll >= -35) && (roll < 35)
    class_label = 1;
  elseif (yaw >= -60) && (yaw < -20) && (roll >= -35) && (roll < 35)
    class_label = 2;
  elseif (yaw >= -20) && (yaw < 20) && (roll >= -35) && (roll < 35)
    class_label = 3;
  elseif (yaw >= 20) && (yaw < 60) && (roll >= -35) && (roll < 35)
    class_label = 4;
  elseif (roll >= -35) && (roll < 35) %if (yaw >=60) 
    class_label = 5;
  end
             
  % Link Image
  full_path_file = data{1}{i};
  [pathstr, file_name, ext] = fileparts(full_path_file);
  inImg = fullfile(AFLW_PATH, SUBDIR, pathstr, [file_name ext]);
  disp(inImg);

  % Check if it is a color image, if not, we don't use it.
  if ~exist(inImg, 'file')
    continue;
  end     
  I = imread(inImg);
  if length(size(I)) < 3
%     I2 = zeros(size(I,1), size(I,2), 3);
%     I2(:,:,1) = I;
%     I2(:,:,2) = I;
%     I2(:,:,3) = I;
%     I = I2;
    continue;
  end     
  
  outImg = fullfile(dataRoot,'images', [pathstr '_' file_name ext]);
  outImgInClass = fullfile(dataRoot, sprintf('%d',class_label),[file_name ext]);
  if ispc()
    system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    system(['mklink', ' ', '"', outImgInClass, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
  elseif isunix()
    system(sprintf('ln -s %s %s',inImg,outImg));
    system(sprintf('ln -s %s %s',inImg,outImgInClass));
  end
          
  % Write Annotation
  annotation_file = fullfile(dataRoot,'annotations',[pathstr '_' file_name '.txt']);
  disp(annotation_file);
  if ~exist(annotation_file, 'file');
    fileID = fopen(annotation_file,'w+');
    fprintf(fileID, '%% bbGt version=%d\n',PDOLLAR_ANNONTATION_VERSION);
  else
    fileID = fopen(annotation_file,'a+');
  end;
  % Id left top width height 0 0 0 0 0 0 0 face_orientation_class_label
  fmt = '%s %d %d %d %d 0 0 0 0 0 0 0 %d\n';
  t = currbb(2)+1; % 0-based coordinates to 1-based
  l = currbb(1)+1;
  r = currbb(1)+currbb(3);
  b = currbb(2)+currbb(4);
  fprintf(fileID, fmt, 'Face', l, t, currbb(3), currbb(4), class_label);
  fclose(fileID);

  if show_images
    imshow(I);
    hold on;
    XX = [l r r l l];
    YY = [t t b b t];
    plot(XX, YY, 'r', 'LineWidth', 2);
    title(sprintf('%d rows x %d cols, y=%f, r=%f, p=%f', size(I,1), size(I,2), yaw, roll, pitch));
    hold off;
    drawnow;
%    pause;
  end
end

if ADD_VERTICALLY_FLIPPED_IMAGES
% Process flipped images.
N = length(data{1});
for i=1:N   
  currbb = [data{2}(i,1) data{2}(i,2) data{2}(i,3) data{2}(i,4)];
  yaw = -data{2}(i,5);
  pitch = data{2}(i,6);
  roll = -data{2}(i,7);
    
  % We initially perform classification of faces depending on the 
  % yaw angle only: Partitions of head hunter paper.
  if (yaw < -60) && (roll >= -35) && (roll < 35)
    class_label = 1;
  elseif (yaw >= -60) && (yaw < -20) && (roll >= -35) && (roll < 35)
    class_label = 2;
  elseif (yaw >= -20) && (yaw < 20) && (roll >= -35) && (roll < 35)
    class_label = 3;
  elseif (yaw >= 20) && (yaw < 60) && (roll >= -35) && (roll < 35)
    class_label = 4;
  elseif (roll >= -35) && (roll < 35) %if (yaw >=60) 
    class_label = 5;
  end
            
  % Link flipped image
  full_path_file = data{1}{i};
  [pathstr, file_name, ext] = fileparts(full_path_file);
  inImg = fullfile(flippedImagesPath, pathstr, [file_name '_flipped' ext]);
  disp(inImg);

  % Check if it is a color image, if not, we don't use it.
  if ~exist(inImg, 'file')
    continue;
  end     
  I = imread(inImg);
  if length(size(I)) < 3
%     I2 = zeros(size(I,1), size(I,2), 3);
%     I2(:,:,1) = I;
%     I2(:,:,2) = I;
%     I2(:,:,3) = I;
%     I = I2;
    continue;
  end     
  
  outImg = fullfile(dataRoot,'images', [pathstr '_' file_name '_flipped' ext]);
  outImgInClass = fullfile(dataRoot, sprintf('%d',class_label),[file_name '_flipped' ext]);
  if ispc()
    system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    system(['mklink', ' ', '"', outImgInClass, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
  elseif isunix()
    system(sprintf('ln -s %s %s',inImg,outImg));
    system(sprintf('ln -s %s %s',inImg,outImgInClass));
  end
     
  % Write Annotation file for flipped image-
  annotation_file = fullfile(dataRoot,'annotations',[pathstr '_' file_name '_flipped.txt']);
  disp(annotation_file);
  if ~exist(annotation_file, 'file');
    fileID = fopen(annotation_file,'w+');
    fprintf(fileID, '%% bbGt version=%d\n',PDOLLAR_ANNONTATION_VERSION);
  else
    fileID = fopen(annotation_file,'a+');
  end;
  % Id left top width height 0 0 0 0 0 0 0 face_orientation_class_label
  fmt = '%s %d %d %d %d 0 0 0 0 0 0 0 %d\n';
  t_flipped = currbb(2)+1; % 0-based coordinates to 1-based
  l_flipped = size(I,2)-currbb(1)-currbb(3);
  r_flipped = size(I,2)-currbb(1)-1;
  b_flipped = currbb(2)+currbb(4);
  fprintf(fileID, fmt, 'Face', l_flipped, t_flipped, currbb(3), currbb(4), class_label);
  fclose(fileID);
     
  if show_images
    imshow(I);
    hold on;
    XX = [l_flipped r_flipped r_flipped l_flipped l_flipped];
    YY = [t_flipped t_flipped b_flipped b_flipped t_flipped];
    plot(XX, YY, 'r', 'LineWidth', 2);
    title(sprintf('%d rows x %d cols, y=%f, r=%f, p=%f', size(I,1), size(I,2), yaw, roll, pitch));
    hold off;
    drawnow;
%    pause;
  end
end
end
