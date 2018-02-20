% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';

% Set the paths to all the datasets used in training. In this case the
% scheme is to train in AFLW data and validate in PASCAL images. Once we
% have the best detector, then we test on AFW and FDDB datasets.

% directory with data/flickr/0, data/flickr/2 and data/flickr/3 images
% subdirs.
AFLW_PATH = '/home/imagenes/FACE_DATABASES/aflw'; 
PASCAL_VOC2007_PATH = '/home/imagenes/PASCAL_VOC/2007/VOCdevkit/VOC2007';
AFW_PATH = '/home/imagenes/FACE_DATABASES/afw';
PASCAL_PATH = '/home/imagenes/PASCAL_VOC';
FDDB_PATH = '/home/imagenes/FACE_DATABASES/fddb';

OUTPUT_DATA_PATH =  fullfile(pwd(),'FACES_DETECTION_EXPERIMENTS');
PREPARED_DATA_PATH =  fullfile(pwd(), 'FACES_TRAINING_DATA');

% Change to 1 to prepare the data from downloaded datasets.
PREPARE_DATA = 0; 

% Add BAdaCost toolbox to the path
addpath(genpath(TOOLBOX_BADACOST_PATH));
if PREPARE_DATA 
  
  addpath(genpath('aflw_preparation'));
  % First we prepare AFLW databases for training/testing:
  %   1) We add flipped images horizontally (and modify labels accordingly) 
  %     in order to double training images set.
  %   2) We train in the full AFLW dataset plus flipped images.
  prepare_aflw_database_subcat;
end

% ------------------------------------------------------------------------
% Now we call the script to train BAdaCost detector with different parameters:
%   3) Finally we train BAdaCost detector with first 90% of training images and we test in the last 10%. 
dataDir = PREPARED_DATA_PATH; 

% ------------------------------------------------------------------------
% 3.1 Experiments over SubCat and number of hard negatives
Ds = [2, 3, 4];
Ts = [2048, 4096];
Ns = [5000, 7500, 10000];
NAs = [20000, 30000, 40000];
for i=1:length(Ts)
  T = Ts(i);
  for j=1:length(Ns)
    N = Ns(j);
    NA = NAs(j);
    for k=1:length(Ds)
      D = Ds(k);
      dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
      train_subcat_detector(dataDir, dataOutputDir, D, T, N, NA);
      close all;
    end
  end
end

BEST_T = 4096;
BEST_D = 2;
BEST_N = 5000;
BEST_NA = 20000;
  
% ------------------------------------------------------------------------
% Now testing best detector so far over AFW
D = BEST_D;
T = BEST_T;
N = BEST_N;
NA = BEST_NA;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
disp(dataOutputDir);
apply_subcat_detector_to_AFW(dataDir, dataOutputDir, D); 
close all;
 
%------------------------------------------------------------------------
% Now testing best detector so far over FDDB
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
apply_subcat_detector_to_FDDB(dataDir, dataOutputDir, D);
close all;

% Compile and execute FDDB evaluation software:
%unix('cd fddb_cpp_evaluation; make');
EVAL_EXEC = fullfile(pwd(), 'fddb_cpp_evaluation', 'evaluate');
FDDB_FOLDS_ELLIPSE_FILE = fullfile(pwd(), 'fddb_cpp_evaluation', 'FDDB-ALL-folds-ellipse.txt');
FDDB_FOLDS_FILE = fullfile(pwd(), 'fddb_cpp_evaluation', 'FDDB-ALL-folds.txt');
FDDB_BADACOST_RESULTS_FILE = fullfile(dataOutputDir, 'FDDB_COMPATIBLE_ELLIPSE_Dets.txt');
%FDDB_BADACOST_RESULTS_FILE = fullfile(dataOutputDir, 'FDDB_COMPATIBLE_RECT2_Dets.txt');
FDDB_ORIG_PICS = fullfile(FDDB_PATH, 'originalPics/');
unix(['cd ' dataOutputDir '; ' ...
      EVAL_EXEC ' -a ' FDDB_FOLDS_ELLIPSE_FILE ...
                ' -d ' FDDB_BADACOST_RESULTS_FILE ...
                ' -i ' FDDB_ORIG_PICS ...
                ' -l ' FDDB_FOLDS_FILE ...
                ' -z .jpg' ...
                ' -f 1']);
%                ' -f 0']);

