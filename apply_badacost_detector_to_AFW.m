function apply_badacost_detector_to_AFW(dataDir, dataOutputDir, SHRINKAGE, RESAMPLING)
% dataDir - Path of the directory with the prepared face databases data.
% dataOutputDir - Path to store trained detector and detection results in. 

if (nargin < 4)
  RESAMPLING = 1;
end
 
if (nargin < 3)
  SHRINKAGE = 0.1;
end

mkdir(dataOutputDir);

exp_name='AFLW';

% Size of the search window
MIN_HEIGHT = 40;

BEST_ASPECT_RATIO  = 1;
BEST_PADDING_RATIO = 1/8;

% Regularisation
%RESAMPLING = 1;
%SHRINKAGE  = 0.1;
% FRAC_FTRS  = 1/16;

% Cascade calibration
% USE_CALIBRATION = 1
% CALIBRATION_THR_FRACTION = 1;

% For testing
OVERLAPING_TP = 0.5; 
 
% Our parameters
imgTestDir = fullfile(dataDir, 'afw_pdollar_format/images');
lbsTestDir = fullfile(dataDir, 'afw_pdollar_format/annotations');
 
pLoad={'lbls',{'Face'},'ilbls',{'DontCare'}}; 
pLoad = {pLoad{:} 'hRng',[round(MIN_HEIGHT*0.8)  inf]}; 
pLoad = {pLoad{:} 'format', 0}; 
num_classes = 5+1; % 5 orientations + background

DETECTOR_FILE_PREFIX = [exp_name ...
                      sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                      SHRINKAGE, ...
                      RESAMPLING, BEST_ASPECT_RATIO) '_'];

%--------------------------------------------------------------------------
% Now, load the already trained BAdaCost based detector
%--------------------------------------------------------------------------
detectorFile = fullfile(dataOutputDir, [DETECTOR_FILE_PREFIX 'Detector.mat']);

%--------------------------------------------------------------------------
% Load the trained detector
%--------------------------------------------------------------------------
detector = load(detectorFile);
detector = detector.detector;
%detectorBAK = detector;

% detector.opts.pNms.type = 'max';
% detector.opts.pNms.overlap = 0.5;
% detector.opts.pNms.ovrDnm = 'min';
detector.opts.pPyramid.nOctUp=0; % Not needed in AFW
detectorPrefix_AFW = ['AFW' ...
                       sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                       detector.opts.pBoost.shrinkage, ...
                       detector.opts.pBoost.resampling, BEST_ASPECT_RATIO) '_'];                  
detectorFile_AFW = [detectorPrefix_AFW 'Detector.mat'];                  
save(fullfile(dataOutputDir, detectorFile_AFW), 'detector');
%detector = detectorBAK;

%--------------------------------------------------------------------------
% test detector and plot roc (see acfTest)
%--------------------------------------------------------------------------
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


[miss,roc,gt,dt]=acfTestBadacost('name',detectorPrefix_AFW,...
   'imgDir',imgTestDir,...
   'gtDir',lbsTestDir,...
   'pLoad',pLoadTest,... 
   'show',1, ...
   'thr', OVERLAPING_TP, ...
   'numClasses', num_classes, ...
   'savePath', dataOutputDir);  % Overlaping threshold for a BoundingBox as TP

% From now on we use AFW dataset to test ...
exp_name = 'AFW'
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
IMG_RESULTS_PATH = fullfile(dataOutputDir, 'IMG_RESULTS_AFW_FACES');
mkdir(IMG_RESULTS_PATH);
LABELS_RESULTS_PATH = fullfile(dataOutputDir, 'LABELS_RESULTS_AFW_FACES');
mkdir(LABELS_RESULTS_PATH);
imgNms = bbGt('getFiles',{imgTestDir});

if (~exist('NICE_VISUALISATION', 'var'))
  NICE_VISUALISATION = false;
end

if (~exist('NICE_VISUALISATION_SCORE_THRESHOLD', 'var'))
  NICE_VISUALISATION = false;
end

fid = fopen(fullfile(dataOutputDir, 'AFW_FACES_COMPATIBLE_Dets.txt'), 'w');
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
