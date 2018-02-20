function train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, ...
    useSAMME, costsAlpha, costsBeta, costsGamma, shrinkage, fracFtrs, useFilters)
% dataDir - Path of the directory with the prepared face databases data.
% dataOutputDir - Path to store trained detector and detection results in. 
% D - max depth of the tree weak learners
% T - max number of tree weak learners.
% N - number of hard negatives to add per round
% NA - total number of hard negatives to add in 4 rounds of mining.
% 
% Cost related parameters are:
% useSAMME - wether cost matrix is 0-1 one.
% if useSAMME = 0, 
%   costsAlpha, costsBetha, costsGamma are used as in the paper to set
%   costs (weighting up errors of car orientation car).

if (nargin < 11)
  shrinkage = 0.1; 
end

if (nargin < 12)
  fracFtrs = 1/16; 
end

if (nargin < 13)
  useFilters = 'LDCF';
end

mkdir(dataOutputDir);

exp_name='AFLW';

NICE_VISUALISATION = false;
  NICE_VISUALISATION_SCORE_THRESHOLD = 10;

% Size of the search window
MIN_HEIGHT = 40;
 SQUARIFY_TYPE = 3;
  
A_RATIO_TYPE = 'mean';  
STRIDE = 4;
N_PER_OCT = 10; % Better detection.
N_OCT_UP = 1;
N_APPROX = 9;

BEST_ASPECT_RATIO  = 1;
BEST_PADDING_RATIO = 1/8;
CHNS_SHRINK = 2;
MAX_DEPTH = D;
MIN_DEPTH = 1;
VARIABLE_DEPTH = 0;
N_ACC_NEG = NA;
N_NEG = N;
N_WEAK = [64 256 512 T]; 

% Regularisation
RESAMPLING = 1;
SHRINKAGE  = shrinkage;
FRAC_FTRS  = fracFtrs;

% Cascade calibration
USE_CALIBRATION = 1
CALIBRATION_THR_FRACTION = 1;

% For testing
OVERLAPING_TP = 0.5; % As needed in KITTI benchmark

% set up opts for training detector (see acfTrainBadacostTrees)
opts=acfTrainBadacostTrees(); 
opts.savePath = dataOutputDir;
opts.cascCal = 0.0;

if strcmp(useFilters, 'ROTATED')
  opts.filters = computeRotatedFilters(10,16,9);
elseif strcmp(useFilters, 'CHECKER')
  opts.filters = computeCheckerboardFilters(10,16,4);
elseif strcmp(useFilters, 'SQUARES')
  opts.filters = computeSquaresFilters(10,5,4);
else % if strcmp(useFilters, 'LDCF')
  % NIPS 2014 P.Dollar paper.
  opts.filters=[5 4];     
end

% SubCat paper parameters
opts.pPyramid.pChns.pColor.smooth=0;
opts.pPyramid.pChns.pGradHist.softBin=1;
opts.pPyramid.pChns.shrink=CHNS_SHRINK;

% Our parameters
imgTestDir = fullfile(dataDir, 'PASCAL_FACES/images');
lbsTestDir = fullfile(dataDir, 'PASCAL_FACES/annotations');
opts.posGtDir = fullfile(dataDir, 'aflw_pdollar_format_headhunter_rectangular_bb/annotations');
opts.posImgDir = fullfile(dataDir, 'aflw_pdollar_format_headhunter_rectangular_bb/images');
opts.negImgDir = fullfile(dataDir, 'VOC2007_WITHOUT_PERSON_MIN_IMG_SIZE_160/JPEGImages');
opts.nWeak=N_WEAK;

opts.pNms = {'type','max','overlap',.5,'ovrDnm','min'};
opts.nAccNeg = N_ACC_NEG;
opts.nNeg = N_NEG;
opts.aRatioType = A_RATIO_TYPE;
opts.stride = STRIDE;

% Trams, Truck and Vans can be similar to cars, so we want them ignored but
% present in the bounding boxes. This way the negative windows are not
% extracted from them.
pLoad={'lbls',{'Face'},'ilbls',{'DontCare'}}; 
%pLoad = {pLoad{:} 'hRng',[round(MIN_HEIGHT*0.8)  inf]}; 
pLoad = {pLoad{:} 'hRng',[round(MIN_HEIGHT*0.5)  inf]}; 
pLoad = {pLoad{:} 'format', 0}; 
num_classes = 5+1; % 5 orientations + background

% Compute costs matrix from the parameters already set:
Cost = compute_cost_matrix(num_classes, useSAMME, costsAlpha, costsBeta, costsGamma);
disp(Cost);

% Set the BAdaCost paramenters.
opts.pBoost = struct('Cost', Cost, 'shrinkage', SHRINKAGE, 'resampling', RESAMPLING, ...
                     'minDepth', MIN_DEPTH, ...
                     'maxDepth', MAX_DEPTH, ...
                     'variable_depth', VARIABLE_DEPTH, ...
                     'verbose',1, 'fracFtrs', FRAC_FTRS, ...
                     'quantized', 1);

opts.modelDs=round([MIN_HEIGHT MIN_HEIGHT*BEST_ASPECT_RATIO]); 
opts.modelDsPad=round(opts.modelDs .* (1.0 + BEST_PADDING_RATIO));
opts.name = [exp_name ...
             sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                     opts.pBoost.shrinkage, ...
                     opts.pBoost.resampling, BEST_ASPECT_RATIO) '_'];
opts.pLoad = {pLoad{:} 'squarify', {SQUARIFY_TYPE, BEST_ASPECT_RATIO}}; 

%--------------------------------------------------------------------------
% Now, train the BAdaCost based detector
%--------------------------------------------------------------------------
detectorFile = fullfile(dataOutputDir, [opts.name 'Detector.mat']);
if ~exist(detectorFile, 'file')
  % train detector (see acfTrainBadacostTrees)
  detector = acfTrainBadacostTrees( opts );
  if USE_CALIBRATION
    % Watch out!!! This is faster but you can miss detections!!
    detector.opts.cascThr=detector.opts.cascThr*CALIBRATION_THR_FRACTION;
  end
  detector.opts.pPyramid.nPerOct=N_PER_OCT; % Better detection.
  detector.opts.pPyramid.nOctUp=N_OCT_UP; % Better detection.
  detector.opts.pPyramid.nApprox=N_APPROX; % Better detection.
  save(detectorFile, 'detector');
end

%--------------------------------------------------------------------------
% Load the trained detector
%--------------------------------------------------------------------------
detector = load(detectorFile);
detector = detector.detector;
detectorBAK = detector;

detector.opts.pNms.type = 'max';
detector.opts.pNms.overlap = 0.5;
detector.opts.pNms.ovrDnm = 'min';
detector.opts.pPyramid.nOctUp=1; % Not needed in PASCAL
detectorPrefix_PASCAL = ['PASCAL' ...
                       sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                       opts.pBoost.shrinkage, ...
                       opts.pBoost.resampling, BEST_ASPECT_RATIO) '_'];                  
detectorFile_PASCAL = [detectorPrefix_PASCAL 'Detector.mat'];                  
save(fullfile(dataOutputDir, detectorFile_PASCAL), 'detector');
%['mv ' fullfile(dataOutputDir, [opts.name 'Dets.txt']) ' ' fullfile(dataOutputDir, [detectorPrefix_PASCAL 'Dets.txt'])]
%system(['mv ' fullfile(dataOutputDir, [opts.name 'Dets.txt']) ' ' fullfile(dataOutputDir, [detectorPrefix_PASCAL 'Dets.txt'])]);
detector = detectorBAK;

%--------------------------------------------------------------------------
% Plot the selected features by the detector
%--------------------------------------------------------------------------
[featMap, featChnMaps, nFilters] = computeSelectedFeaturesMap(detector);

plotSelectedFeaturesMap(exp_name, dataOutputDir, featMap, featChnMaps, nFilters);

%--------------------------------------------------------------------------
% test detector and plot roc (see acfTest)
%--------------------------------------------------------------------------
%% test detector and plot roc (see acfTest)
pLoad2=pLoad;
if iscell(pLoad)
  index = find(strcmp(pLoad2, 'format'));
  if ~isempty(index)
    pLoad2{index+1} = 0; % Format 0 is all data
  end
elseif isstruct(pLoad2)
  if isfield(pLoad2, 'format')
    pLoad2.format = 0; % Format 0 is all data.
  end
end
pLoadTest = {pLoad2{:}}; 


[miss,roc,gt,dt]=acfTestBadacost('name',detectorPrefix_PASCAL,...
   'imgDir',imgTestDir,...
   'gtDir',lbsTestDir,...
   'pLoad',pLoadTest,... 
   'show',1, ...
   'thr', OVERLAPING_TP, ...
   'numClasses', num_classes, ...
   'savePath', dataOutputDir);  % Overlaping threshold for a BoundingBox as TP

% From now on we use PASCAL dataset to test ...
exp_name = 'PASCAL'
save(fullfile(dataOutputDir, [exp_name '_TEST_RESULTS.mat']), 'miss', 'roc', 'gt', 'dt');

h = figure;
ref   = 10.^(-2:.25:0);
lims = [3.1e-3 1e1 .05 1];
color = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};
lineSt = {'-', ':', '--', '.', '-', ':', '--'};

%[fp,tp,score,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[fp,tp,~,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[hs,~,~] =plotRoc([fp tp],'logx',1,'logy',0, 'xLbl', 'fppi',...
            'lims', lims, 'color', color{1}, 'lineSt', lineSt{1}, 'smooth', 1, 'fpTarget', ref);
legend_string = sprintf('asp.ratio=%2.2f, pad.ratio=%2.2f, recall (at 1FFPI)=%.2f%%', ...
                        BEST_ASPECT_RATIO, BEST_PADDING_RATIO, ...
                        miss_test(end)*100);
legend(hs, legend_string, 'Location', 'Best');
hold off;
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc.eps']), 'epsc');
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc.png']), 'png');

h = figure;
ref   = 10.^(-2:.25:0);
lims = [3.1e-3 1e1 .05 1];
color = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};
lineSt = {'-', ':', '--', '.', '-', ':', '--'};

%[fp,tp,score,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[fp,tp,~,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[hs,~,~] = plotRoc([fp tp],'logx',1,'logy',0, 'xLbl', 'fppi',...
            'lims', lims, 'color', color{1}, 'lineSt', lineSt{1}, 'smooth', 1, 'fpTarget', ref);
legend_string = sprintf('asp.ratio=%2.2f, pad.ratio=%2.2f, recall (at 0.1 FFPI)=%.2f%%', ...
                        BEST_ASPECT_RATIO, BEST_PADDING_RATIO, ...
                        miss_test(5)*100);
legend(hs, legend_string, 'Location', 'Best');
hold off;
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc2.eps']), 'epsc');
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc2.png']), 'png');

%--------------------------------------------------------------------------
% Plot results over images.
%--------------------------------------------------------------------------
figure; 
IMG_RESULTS_PATH = fullfile(dataOutputDir, 'IMG_RESULTS_PASCAL_FACES');
mkdir(IMG_RESULTS_PATH);
LABELS_RESULTS_PATH = fullfile(dataOutputDir, 'LABELS_RESULTS_PASCAL_FACES');
mkdir(LABELS_RESULTS_PATH);
imgNms = bbGt('getFiles',{imgTestDir});

if (~exist('NICE_VISUALISATION', 'var'))
  NICE_VISUALISATION = false;
end

if (~exist('NICE_VISUALISATION_SCORE_THRESHOLD', 'var'))
  NICE_VISUALISATION = false;
end

fid = fopen(fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), 'w');
for i=1:length(imgNms)
  file_name = strsplit(imgNms{i}, '/');
  file_name = file_name{end};
  [~,name,~]=fileparts(file_name);
  I = imread(fullfile(imgTestDir, file_name));
  dt_i = dt{i};
  gt_i = gt{i};
  
  dt_i(:,6) = ones(size(dt_i, 1), 1);
  dt_i(:,7) = dt_i(:,7)-ones(size(dt_i, 1), 1);
  if NICE_VISUALISATION
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '-'}; 
    dt_i_nice = dt_i(dt_i(:,5)>=NICE_VISUALISATION_SCORE_THRESHOLD, :);
    %[rows, cols] = size(I);

    %[hs,hImg] = bbGt('showRes', I, gt_i, dt_i_nice, showResOpts); % multiClass = 1
    bbGt('showRes', I, gt_i, dt_i_nice, showResOpts); % multiClass = 1
    saveas(gcf, fullfile(IMG_RESULTS_PATH, ['NICE_VISUALISATION_' file_name '.png']), 'png');  
  else 
    % Show full results and comparison with ground thruth
    showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 1}; 
    %[hs,hImg] = bbGt('showRes', I, gt_i, dt_i, showResOpts); % multiClass = 1
    bbGt('showRes', I, gt_i, dt_i, showResOpts); % multiClass = 1
    saveas(gcf, fullfile(IMG_RESULTS_PATH, [file_name '.png']), 'png');  
  end
  
  for j=1:size(dt_i,1)
     x1 = dt_i(j,1)-1;
     y1 = dt_i(j,2)-1;
     x2 = x1 + dt_i(j,3) - 1;
     y2 = y1 + dt_i(j,4) - 1;
     fprintf(fid, '%s %f %f %f %f %f\n', name, dt_i(j,5), x1, y1, x2, y2);
  end;
end
fclose(fid);
