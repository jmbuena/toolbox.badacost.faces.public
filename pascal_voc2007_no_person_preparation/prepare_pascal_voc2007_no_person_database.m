

SUBDIR = 'JPEGImages';
savePath = fullfile(PREPARED_DATA_PATH, 'VOC2007_WITHOUT_PERSON');
USE_MIN_IMG_SIZE = 1;
  MIN_IMG_SIZE = 160;
show_results = true;

if USE_MIN_IMG_SIZE
  savePath = [savePath sprintf('_MIN_IMG_SIZE_%d', MIN_IMG_SIZE)];   
end

LABEL_TO_AVOID = 'person';
mkdir(fullfile(savePath, 'Annotations'));
mkdir(fullfile(savePath, 'JPEGImages'));

fnames = dir(fullfile(PASCAL_VOC2007_PATH, 'Annotations', '*.xml'));

% Keep only the names
fnames = {fnames.name}; % Vectors are columns.
for i=1:length(fnames)
  disp(fnames{i});
  textfile = fileread(fullfile(PASCAL_VOC2007_PATH, 'Annotations', fnames{i}));
  L = strfind(textfile, LABEL_TO_AVOID);
  if isempty(L) % Only save images that does not have persons.    
    % Link images in the savePath.
    [pathstr, file_name, ext] = fileparts(fnames{i});    
    inImg = fullfile(PASCAL_VOC2007_PATH, SUBDIR, [file_name '.jpg']);
    outImg = fullfile(savePath,'JPEGImages', [file_name '.jpg']);
    
    I = imread(inImg);
    if USE_MIN_IMG_SIZE && (min(size(I, 1), size(I,2)) < MIN_IMG_SIZE)
      continue;
    end

    if ispc()
      system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    elseif isunix()
      system(sprintf('ln -s %s %s',inImg,outImg));
    end
    
    if show_results
      imshow(I);
      drawnow;
    end
    
    % Link to the annotation
    inImg = fullfile(PASCAL_VOC2007_PATH, 'Annotations', fnames{i});
    outImg = fullfile(savePath,'Annotations', fnames{i});
    if ispc()
      system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
    elseif isunix()
      system(sprintf('ln -s %s %s',inImg,outImg));
    end
  end
end

