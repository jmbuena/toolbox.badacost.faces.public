
dataRoot= fullfile(PREPARED_DATA_PATH, 'afw_pdollar_format');
show_images = true;
PDOLLAR_ANNONTATION_VERSION=4;

mkdir(fullfile(dataRoot,'images'));
mkdir(fullfile(dataRoot,'1'));
mkdir(fullfile(dataRoot,'2'));
mkdir(fullfile(dataRoot,'3'));
mkdir(fullfile(dataRoot,'4'));
mkdir(fullfile(dataRoot,'5'));
mkdir(fullfile(dataRoot,'annotations'));
mkdir(fullfile(dataRoot,'images'));
mkdir(fullfile(dataRoot,'annotations'));

%% Construct training set
fid=fopen(fullfile(AFW_PATH, 'afw_ann.txt')); 
fmt = '%s %f %f %f %f %f %f %f %*[^\n]';
data = textscan(fid, fmt, 'Delimiter', ',', 'CommentStyle', '#', 'CollectOutput', true); 
fclose(fid);

% Process images.
N = length(data{1});
for i=1:N  
  t = data{2}(i,3);
  b = data{2}(i,4);
  l = data{2}(i,1);
  r = data{2}(i,2);
  w = r-l+1;
  h = b-t+1;
  currbb = [l t w h];
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
  inImg = fullfile(AFW_PATH, pathstr, [file_name ext]);
  disp(inImg);
  
  % Check if it is a color image, if not, we don't use it.
  I = imread(inImg);
  if length(size(I)) < 3
    continue;
  end     
  
  outImg = fullfile(dataRoot,'images', [file_name ext]);
  disp(outImg);
  outImgInClass = fullfile(dataRoot,sprintf('%d',class_label),[file_name ext]);
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


