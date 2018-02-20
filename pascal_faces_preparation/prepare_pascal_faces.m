
dataRoot = cell(5);
dataRoot{1}=fullfile(PASCAL_PATH, '2012', 'VOCdevkit', 'VOC2012');
dataRoot{2}=fullfile(PASCAL_PATH, '2008_test', 'VOCdevkit', 'VOC2008');
dataRoot{3}=fullfile(PASCAL_PATH, '2009_test', 'VOCdevkit', 'VOC2009');
dataRoot{4}=fullfile(PASCAL_PATH, '2010_test', 'VOCdevkit', 'VOC2010');
dataRoot{4}=fullfile(PASCAL_PATH, '2011_test', 'VOCdevkit', 'VOC2011');

PDOLLAR_ANNOTATION_VERSION=4; % This for new format added in the BAdaCost modified toolbox.

savePath = fullfile(PREPARED_DATA_PATH, 'PASCAL_FACES');
SUBDIR = 'JPEGImages';
show_results = true;

mkdir(fullfile(savePath, 'annotations'));
mkdir(fullfile(savePath, 'images'));

% Load fixed annotations from "Face detection without bells and whistles", ECCV 2014:
load(fullfile('pascal_faces_preparation', 'Annotations_Face_PASCALLayout_large_fixed.mat'));

% Keep only the names
for i=1:length(Annotations)
  disp(Annotations(i).imgname);
  [pathstr, file_name, ext] = fileparts(Annotations(i).imgname);    
  outImg = fullfile(savePath,'images', [file_name '.jpg']);    
  
  for k=1:length(dataRoot)
    inImg = fullfile(dataRoot{k}, SUBDIR, [file_name '.jpg'])
    if exist(inImg, 'file')
      break;
    end
  end

  if ~exist(inImg, 'file')
    warning(['Image ' inImg ' does not exists!!!']);
    continue;
  end
  
  I = imread(inImg);
  if ispc()
    system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
  elseif isunix()
%    system(sprintf('ln -s %s %s',inImg,outImg));
    system(sprintf('cp %s %s',inImg,outImg));
  end
    
  if show_results
    imshow(I);
    hold on;
  end

  % Write Annotation
  annotation_file = fullfile(savePath,'annotations',[file_name '.txt']);
  if ~exist(annotation_file, 'file');
    fileID = fopen(annotation_file,'w+');
    fprintf(fileID, '%% bbGt version=%d\n',PDOLLAR_ANNOTATION_VERSION);
  else
    fileID = fopen(annotation_file,'a+');
  end;
  for j=1:size(Annotations(i).objects,1)
    % Id left top width height 0 0 0 0 0 0 0 face_orientation_class_label
    fmt = '%s %d %d %d %d 0 0 0 0 0 0 0 %d\n';
    l = Annotations(i).objects(j,1);
    t = Annotations(i).objects(j,2); 
    r = Annotations(i).objects(j,3);
    b = Annotations(i).objects(j,4);
    fprintf(fileID, fmt, 'Face', l, t, r-l+1, b-t+1, 1);
    if show_results
      XX = [l r r l l];
      YY = [t t b b t];
      plot(XX, YY, 'r', 'LineWidth', 2);
    end
  end
  fclose(fileID);
  
  if (show_results)
    title(Annotations(i).imgname);
    hold off;
%    pause;
  end
end

