
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/toolbox.badacost';

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
  PREPARE_PASCAL_VOC2017_NO_PERSON = 1;
  PREPARE_PASCAL_FACES = 1;
  PREPARE_AFW = 1;
  PREPARE_FDDB = 1;
 
% Change to 1 in order to train the faces detector over AFLW
% (otherwise it would use the already trained one for test).
DO_TRAINING = 0; 

% Variables for testing trained detector on real images.
% if 1 less accurate but faster, if 0 better detection.
FAST_DETECTION = 0;

SAVE_RESULTS = 1;
NICE_VISUALIZATION_SCORE_THRESHOLD = 10;

VIDEO_FILES_PATH = 'FACES_FULL_SEQUENCES/Oxford_Street_London_Walk'
IMG_RESULTS_PATH = 'FACES_FULL_SEQUENCES_EXPERIMENTS/Oxford_Street_London_Walk'
FIRST_IMAGE = 1; % first_image_index
IMG_EXT = 'png';

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
  if PREPARE_PASCAL_VOC2017_NO_PERSON
    addpath(genpath(fullfile('.', 'pascal_voc2017_no_person_preparation')));
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

% -----------------------------------------------------------------------------
useSAMME = 0;
dataDir = PREPARED_DATA_PATH; 
D = 6;
T = 1024;
N = 10000;
NA = 40000;
costsAlpha = 1;
costsBeta = 1.5;
costsGamma = 1;
if DO_TRAINING
  % Now we call the script to train BAdaCost detector with different parameters:
  %   3) Finally we train BAdaCost detector with first 90% of training images and we test in the last 10%. 
  if useSAMME
    dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  else
    dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  end
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
end
 
% -----------------------------------------------------------------------------
% 4) Now we use the trained car detector in the images given in a directory:
 
% The already trained detector file:
if useSAMME
  TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
                                  sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA), ...
                                  'AFLW_SHRINKAGE_0.100000_RESAMPLING_1.000000_ASPECT_RATIO_1.000000_Detector.mat');

else
  TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
                                  sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA), ...
                                  'AFLW_SHRINKAGE_0.100000_RESAMPLING_1.000000_ASPECT_RATIO_1.000000_Detector.mat');
end                              
 
% %% The already trained SubCat detector file:
% TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
%                                   'SUBCAT_D_2_T_4096_N_5000_NA_20000', ...
%                                   'SUBCAT_D_2_Detector.mat');

det = load(TRAINED_DETECTOR_FILE);
badacost_detector = det.detector;
 
apply_detector_to_imgs(badacost_detector, ...
                        VIDEO_FILES_PATH, ... 
                        IMG_EXT, ...
                        FIRST_IMAGE, ...
                        NICE_VISUALIZATION_SCORE_THRESHOLD, ...
                        FAST_DETECTION, ...
                        SAVE_RESULTS, ...
                        IMG_RESULTS_PATH);
 
 
