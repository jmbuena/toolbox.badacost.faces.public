
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
  PREPARE_AFLW = 1;
  PREPARE_PASCAL_VOC2007_NO_PERSON = 0;
  PREPARE_PASCAL_FACES = 0;
  PREPARE_AFW = 0;
  PREPARE_FDDB = 0;
 
% if 1 less accurate but faster, if 0 better detection.
SAVE_RESULTS = 1;
NICE_VISUALIZATION_SCORE_THRESHOLD = 0;

% -----------------------------------------------------------------------------
if PREPARE_DATA 
  % Add BAdaCost toolbox to the path
  addpath(genpath(TOOLBOX_BADACOST_PATH))
  
  % First we prepare AFLW databases for training/testing:
  %   1) We add flipped images horizontally (and modify labels accordingly) 
  %     in order to double training images set.
  %   2) We train in the full AFLW dataset plus flipped images.
  if PREPARE_AFLW
    addpath(genpath(fullfile('.', 'aflw_preparation')));
    prepare_aflw_database;
  end
  
  % Second we prepare dataset for hard negative examples mining.
  if PREPARE_PASCAL_VOC2007_NO_PERSON
    addpath(genpath(fullfile('.', 'pascal_voc2007_no_person_preparation')));
    prepare_pascal_voc2007_no_person_database;
  end

  % Now the validation dataset to choose the best detector parameters on
  % it.
  if PREPARE_PASCAL_FACES
    addpath(genpath(fullfile('.', 'pascal_faces_preparation')));
    prepare_pascal_faces;
  end

  % And then the rest of datasets for testing the 
  if PREPARE_AFW
    addpath(genpath(fullfile('.', 'afw_preparation')));
    prepare_afw_database;
  end
  
  % And then the rest of datasets for testing the
  if PREPARE_FDDB
    addpath(genpath(fullfile('.', 'fddb_preparation')));
    prepare_fddb_database;
  end
end
dataDir = PREPARED_DATA_PATH; 
 
% ------------------------------------------------------------------------
% 3.1 Experiments over SAMME and number of hard negatives
Ns = [5000, 7500, 10000, 12500, 17500];
NAs = [20000, 30000, 40000, 50000, 70000];
D = 6;
T = 1024;
useSAMME = 1;
costsAlpha = 1;
costsBeta = 1;
costsGamma = 1;
for i=1:length(Ns)
  N = Ns(i);
  NA = NAs(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end

% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth
Ds = [4, 5, 6, 7];
T = 1024;
N = 10000;
NA = 40000;
useSAMME = 1;
costsAlpha = 1;
costsBeta = 1;
costsGamma = 1;
for i=1:length(Ds)
  D = Ds(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  system(['mv ' fullfile(dataOutputDir, 'AFLW_TEST_RESULTS.mat') ' ' fullfile(dataOutputDir, 'PASCAL_TEST_RESULTS.mat')]);
  disp(dataOutputDir);
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end

% ------------------------------------------------------------------------
% 3.3 Experiments over BAdaCost and alpha, beta and gamma values for costs.
alphaBetaGamma = [...
                  1, 1.5, 1;...
                  1, 2, 1; ...
                  1, 2.5, 1; ...
                 ];
D = 6;
T = 1024;
N = 10000;
NA = 40000;
useSAMME = 0;
for i=1:size(alphaBetaGamma,1)
  costsAlpha = alphaBetaGamma(i, 1);
  costsBeta = alphaBetaGamma(i, 2);
  costsGamma = alphaBetaGamma(i, 3);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  system(['mv ' fullfile(dataOutputDir, 'AFLW_TEST_RESULTS.mat') ' ' fullfile(dataOutputDir, 'PASCAL_TEST_RESULTS.mat')]);
  disp(dataOutputDir);
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end

% ------------------------------------------------------------------------
% 3.4 Experiments over BAdaCost and number of trees and depths
Ds = [5, 6, 7]; 
Ts = [1024, 1500, 2048];
Ds = [6]; 
Ts = [1024];
N = 10000;
NA = 40000;
useSAMME = 0;
for i=1:size(alphaBetaGamma,1)
  costsAlpha = alphaBetaGamma(i, 1);
  costsBeta = alphaBetaGamma(i, 2);
  costsGamma = alphaBetaGamma(i, 3);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  system(['mv ' fullfile(dataOutputDir, 'AFLW_TEST_RESULTS.mat') ' ' fullfile(dataOutputDir, 'PASCAL_TEST_RESULTS.mat')]);
  disp(dataOutputDir);
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end
 
BEST_T = 1024;
BEST_costsBeta = 2.5;
BEST_D = 6;
BEST_N = 10000;
BEST_NA = 40000;
SHRINKAGE=0.1;
FRAC_FTRS=1/16;
 
% ------------------------------------------------------------------------
% Now testing best detector so far over AFW
D = BEST_D;
T = BEST_T;
N = BEST_N;
NA = BEST_NA;
costsAlpha = 1;
costsBeta = BEST_costsBeta;
costsGamma = 1;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
if (SHRINKAGE ~= 0.1)
  dataOutputDir = [dataOutputDir sprintf('_S_%f', SHRINKAGE)];
end
if (FRAC_FTRS ~= 1/16)
  dataOutputDir = [dataOutputDir sprintf('_F_%f', FRAC_FTRS)];
end
disp(dataOutputDir);
apply_badacost_detector_to_AFW(dataDir, dataOutputDir, SHRINKAGE); 
close all;

%------------------------------------------------------------------------
% Now testing best detector so far over FDDB
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
if (SHRINKAGE ~= 0.1)
  dataOutputDir = [dataOutputDir sprintf('_S_%f', SHRINKAGE)];
end
if (FRAC_FTRS ~= 1/16)
  dataOutputDir = [dataOutputDir sprintf('_F_%f', FRAC_FTRS)];
end
apply_badacost_detector_to_FDDB(dataDir, dataOutputDir,SHRINKAGE);
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

% ------------------------------------------------------------------------
% Now testing best SAMME detector so far over AFW
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
%dataOutputDir = [dataOutputDir '_STRIDE_2'];
apply_badacost_detector_to_AFW(dataDir, dataOutputDir); 
close all;


%------------------------------------------------------------------------
% Now testing best SAMME detector so far over FDDB
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
%dataOutputDir = [dataOutputDir '_STRIDE_2'];
apply_badacost_detector_to_FDDB(dataDir, dataOutputDir);
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


