function apply_badacost_detector_to_FDDB(dataDir, dataOutputDir, SHRINKAGE, RESAMPLING)
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

% % For testing
OVERLAPING_TP = 0.5; 
 
% Our parameters
imgTestDir = fullfile(dataDir, 'fddb_pdollar_format/images');
lbsTestDir = fullfile(dataDir, 'fddb_pdollar_format/annotations');
 
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
detectorBAK = detector;

% detector.opts.pNms.type = 'max';
% detector.opts.pNms.overlap = 0.5;
% detector.opts.pNms.ovrDnm = 'min';
detector.opts.pPyramid.nOctUp=1; % Needed in FDDB
detectorPrefix_FDDB = ['FDDB' ...
                       sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                       detector.opts.pBoost.shrinkage, ...
                       detector.opts.pBoost.resampling, BEST_ASPECT_RATIO) '_'];                  
detectorFile_FDDB = [detectorPrefix_FDDB 'Detector.mat'];                  
save(fullfile(dataOutputDir, detectorFile_FDDB), 'detector');
detector = detectorBAK;

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


[miss,roc,gt,dt]=acfTestBadacost('name',detectorPrefix_FDDB,...
   'imgDir',imgTestDir,...
   'gtDir',lbsTestDir,...
   'pLoad',pLoadTest,... 
   'show',1, ...
   'thr', OVERLAPING_TP, ...
   'numClasses', num_classes, ...
   'savePath', dataOutputDir);  % Overlaping threshold for a BoundingBox as TP

% From now on we use FDDB dataset to test ...
exp_name = 'FDDB'
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
IMG_RESULTS_PATH = fullfile(dataOutputDir, 'IMG_RESULTS_FDDB');
mkdir(IMG_RESULTS_PATH);
LABELS_RESULTS_PATH =  fullfile(dataOutputDir, 'LABELS_RESULTS_FDDB');
mkdir(LABELS_RESULTS_PATH);
showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 1}; 
imgNms = bbGt('getFiles',{imgTestDir});

% Compute per class average detection bb -> ground thruth bb transform.
% IT IS WRONLY IMPLEMENTED: It should take into account only the 
%                           correct detections.
gt_all = cell2mat(gt(:));
dt_all = cell2mat(dt(:));
gt_all(gt_all(:,5) ~= 1,:) = [];
dt_all(dt_all(:,6) ~= 1,:) = [];
dx = zeros(num_classes-1,1);
dy = zeros(num_classes-1,1);
dw = ones(num_classes-1,1);
dh = ones(num_classes-1,1);
for c=1:num_classes-1
  ind_c = find((dt_all(:, 7) == c+1));
  gt_c = gt_all(ind_c,:); 
  dt_c = dt_all(ind_c,:); 
  for it=1:1
    x_dt = dt_c(:,1)-1; % + dt_c(:,3)/2;
    y_dt = dt_c(:,2)-1; % + dt_c(:,4)/2;
    x_gt = gt_c(:,1)-1; % + gt_c(:,3)/2;
    y_gt = gt_c(:,2)-1; % + gt_c(:,4)/2;
   
    % All scale changes.
    dw_c = gt_c(:,3)./dt_c(:,3);
    dh_c = gt_c(:,4)./dt_c(:,4);

    % All traslations scaled
    dx_c = (x_gt - x_dt)./dt_c(:,3); 
    dy_c = (y_gt - y_dt)./dt_c(:,4);

    % update the data
    delta_dxc = median(dx_c);
    delta_dyc = median(dy_c);
    dx(c) = dx(c) + delta_dxc;
    dy(c) = dy(c) + delta_dyc;
    delta_dwc = median(dw_c);
    delta_dhc = median(dh_c);
    dw(c) = dw(c) * delta_dwc;
    dh(c) = dh(c) * delta_dhc;
    
    dt_c(:,1) = dt_c(:,1) + dx(c)*dt_c(:,3); % x update
    dt_c(:,2) = dt_c(:,2) + dy(c)*dt_c(:,4); % y update
    dt_c(:,3) = dt_c(:,3) .* dw(c); % w update
    dt_c(:,4) = dt_c(:,4) .* dh(c); % h update
  end   
end

% Output transforms.
if (~exist('NICE_VISUALISATION', 'var'))
  NICE_VISUALISATION = false;
end

if (~exist('NICE_VISUALISATION_SCORE_THRESHOLD', 'var'))
  NICE_VISUALISATION = false;
end

if (~NICE_VISUALISATION)
  fid = fopen(fullfile(dataOutputDir,'FDDB_COMPATIBLE_Dets.txt'), 'w');
  fid_ellip = fopen(fullfile(dataOutputDir,'FDDB_COMPATIBLE_ELLIPSE_Dets.txt'), 'w');
  fid_rect2 = fopen(fullfile(dataOutputDir,'FDDB_COMPATIBLE_RECT2_Dets.txt'), 'w');
end
for i=1:length(imgNms)
  file_name = strsplit(imgNms{i}, '/');
  file_name = file_name{end};
  [pathstr,name,ext]=fileparts(file_name);
  I = imread(fullfile(imgTestDir, file_name));
  dt_i = dt{i};
  gt_i = gt{i};
  
  dt_i(:,6) = ones(size(dt_i, 1), 1);
  dt_i(:,7) = dt_i(:,7)-ones(size(dt_i, 1), 1);
  if NICE_VISUALISATION
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '--', 'lw', 2, 'cols', 'kry'}; 
    dt_i_nice = dt_i(dt_i(:,5)>=NICE_VISUALISATION_SCORE_THRESHOLD, :);
    [hs,hImg] = bbGt('showRes', I, gt_i, dt_i_nice, showResOpts); % multiClass = 1
     
    % Ellipses
    for j=1:size(dt_i_nice,1)
      lbl = dt_i_nice(j,7);
      x1 = dt_i_nice(j,1)-1 + dx(lbl)*dt_i_nice(j,3);
      y1 = dt_i_nice(j,2)-1 + dy(lbl)*dt_i_nice(j,4);
      w = dt_i_nice(j,3)*dw(lbl);
      h = dt_i_nice(j,4)*dh(lbl);
      a = h/2; % + h*0.2;
      b = w/2; % * 1.1;
      xc = x1 + w/2;
      yc = y1 + h/2; % - h*0.2;
      hold on;
      plotEllipse(yc+1, xc+1, b, a, 0.0 ,'g',100, 3);
    end ;
    hold off;    
    saveas(gcf, fullfile(IMG_RESULTS_PATH, ['NICE_VISUALISATION_' file_name]), 'png');  
  else 
    % Show full results and comparison with ground thruth
    showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 1}; 
    [hs,hImg] = bbGt('showRes', I, gt_i, dt_i, showResOpts); % multiClass = 1
  
    pos = strfind(file_name, '_');
    file_name_orig = fullfile(strrep(file_name(1:pos(end-1)-1), '_', '/'), file_name(pos(end-1)+1:end-4))
  
    % Rectangles/squares
    fprintf(fid, '%s\n', file_name_orig);
    fprintf(fid, '%d\n', size(dt_i,1));
    for j=1:size(dt_i,1)
      x1 = dt_i(j,1)-1;
      y1 = dt_i(j,2)-1;
      w = dt_i(j,3);
      h = dt_i(j,4);
      fprintf(fid, '%f %f %f %f %f\n', x1, y1, w, h, dt_i(j,5));
    end;
  
    % Ellipses
    fprintf(fid_ellip, '%s\n', file_name_orig);
    fprintf(fid_ellip, '%d\n', size(dt_i,1));
    for j=1:size(dt_i,1)
      lbl = dt_i(j,7);
      x1 = dt_i(j,1)-1 + dx(lbl)*dt_i(j,3);
      y1 = dt_i(j,2)-1 + dy(lbl)*dt_i(j,4);
      w = dt_i(j,3)*dw(lbl);
      h = dt_i(j,4)*dh(lbl);
      a = h/2; % + h*0.2;
      b = w/2; % * 1.1;
      xc = x1 + w/2;
      yc = y1 + h/2; % - h*0.2;
      fprintf(fid_ellip, '%f %f %f %f %f %f\n', a, b, deg2rad(90), xc, yc,  dt_i(j,5));
      hold on;
      plotEllipse(yc+1, xc+1, b, a, 0.0 ,'b',100, 2);
    end ;
    hold off;
  
    % Rect2
    fprintf(fid_rect2, '%s\n', file_name_orig);
    fprintf(fid_rect2, '%d\n', size(dt_i,1));
    for j=1:size(dt_i,1)
      lbl = dt_i(j,7);
      x1 = dt_i(j,1)-1 + dx(lbl)*dt_i(j,3);
      y1 = dt_i(j,2)-1 + dy(lbl)*dt_i(j,4);
      w = dt_i(j,3)*dw(lbl);
      h = dt_i(j,4)*dh(lbl);
      hold on;
      fprintf(fid_rect2, '%f %f %f %f %f\n', x1, y1, w, h, dt_i(j,5));
      plot([x1+1 x1+w-2 x1+w-2 x1 x1], [y1+1 y1+1 y1+h-2 y1+h-2 y1+1], 'm');
    end;
    hold off;
   
    %pause;
    saveas(gcf, fullfile(IMG_RESULTS_PATH, [file_name '.png']), 'png');  
  end
end
if (~NICE_VISUALISATION)
  fclose(fid);
  fclose(fid_ellip);
  fclose(fid_rect2);
end
