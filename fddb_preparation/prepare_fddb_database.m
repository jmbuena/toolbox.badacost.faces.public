
PDOLLAR_ANNONTATION_VERSION = 4; % Version 4 adds the positive subclass index

fddbRoot=FDDB_PATH;
SUBDIR = 'originalPics';
dataRoot= fullfile(PREPARED_DATA_PATH, 'fddb_pdollar_format');
show_images = true;

mkdir(fullfile(dataRoot,'images'));
mkdir(fullfile(dataRoot,'annotations'));

%% Construct training set
NUM_FOLDS = 10;
data = cell(1, NUM_FOLDS);
data_ellipse = cell(1, NUM_FOLDS);
for i=1:NUM_FOLDS
  filename = fullfile(fddbRoot, 'FDDB-folds', sprintf('FDDB-fold-%02d.txt', i));
  fid=fopen(filename); 
  fmt = '%s'; %%*[^\n]';
  data2 = textscan(fid, fmt, 'Delimiter', ' ', 'CommentStyle', '#', 'CollectOutput', true); 
  fclose(fid);      
  data{i} = data2;
  filename = fullfile(fddbRoot, 'FDDB-folds', sprintf('FDDB-fold-%02d-ellipseList.txt', i));
  data_ellipse{i} = readfddb_annotation_file(filename);
end
data = cat(1, data{:});
data = cat(1, data{:});

cat_data_ellipse = cell(1, length(data));
i = 1;
for j=1:NUM_FOLDS
  for k=1:length(data_ellipse{j})
    cat_data_ellipse{i} = data_ellipse{j}{k};
    i = i+1;
  end
end
data_ellipse = cat_data_ellipse;

% Process images.
N = length(data);
for i=1:N
  % Link Image
  full_path_file = data{i};
  [pathstr, file_name, ext] = fileparts(full_path_file);
  ext = '.jpg';
  inImg = fullfile(fddbRoot, SUBDIR, pathstr, [file_name ext]);

  % Check if it is a color image, if not, we don't use it.
  if ~exist(inImg, 'file')
    continue;
  end     
  I = imread(inImg);
  
  outImg = fullfile(dataRoot,'images', [strrep(pathstr, '/', '_') '_' file_name ext]);
  if ispc()
    system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
  elseif isunix()
    system(sprintf('ln -s %s %s',inImg,outImg));
  end
          
  % Write Annotation
  annotation_file = fullfile(dataRoot,'annotations', [strrep(pathstr, '/', '_') '_' file_name  '.txt'])
  if ~exist(annotation_file, 'file');
    fileID = fopen(annotation_file,'w+');
    fprintf(fileID, '%% bbGt version=%d\n',PDOLLAR_ANNONTATION_VERSION);
  else
    fileID = fopen(annotation_file,'a+');
  end;
  % Id left top width height 0 0 0 0 0 0 0 face_orientation_class_label
  faces = data_ellipse{i}.faces;
  fmt = '%s %d %d %d %d 0 0 0 0 0 0 0 %d\n';
  
  major_axis = faces(:,2);
  minor_axis = faces(:,1);
  angle = faces(:,3);
  center_x = faces(:,4);
  center_y = faces(:,5);
  for f=1:size(faces,1)
    % We assume that the maior axis is almost vertical (a face) and
    % the minor axis is almost horizontal (a face).
    [l, r, t, b] = ellipse2bb(minor_axis(f), major_axis(f), angle(f), center_x(f), center_y(f));
    
    fprintf(fileID, fmt, 'Face', l, t, r-l+1, b-t+1, 1);

    if show_images
      imshow(I);
      hold on;
      XX = [l r r l l];
      YY = [t t b b t];
      plot(XX, YY, 'r', 'LineWidth', 2);
      title(sprintf('%d rows x %d cols', size(I,1), size(I,2)));
      plot_ellipse(minor_axis(f), major_axis(f), angle(f), center_x(f), center_y(f));
      hold off;
      drawnow;
%      pause;
    end
  end  
  fclose(fileID);
end

