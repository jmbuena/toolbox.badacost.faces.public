

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
HEADHUNTER_EVAL_SOFTWARE_PATH=fullfile(pwd(), 'headhunter_python_evaluation');


OUTPUT_DATA_PATH =  fullfile(pwd(),'FACES_DETECTION_EXPERIMENTS');
OUTPUT_DATA_PATH_H_20 =  fullfile(pwd(),'FACES_DETECTION_EXPERIMENTS_H_20');
PREPARED_DATA_PATH =  fullfile(pwd(), 'FACES_TRAINING_DATA');

% ------------------------------------------------------------------------
% 3.1 Experiments over SAMME and number of hard negatives
Ns = [5000, 7500, 10000, 12500, 17500];
NAs = [20000, 30000, 40000, 50000, 70000];
D = 6;
T = 1024;
mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_N_NEGS'));
for i=1:length(Ns)
  N = Ns(i);
  NA = NAs(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_N_NEGS', ... 
                                sprintf('SAMME,_N=%2.1fk,_NA=%2.1fk.txt', N/1000, NA/1000))));                              
end
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SAMME_N_NEGS');

% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth
Ds = [4, 5, 6, 7];
T = 1024;
N = 10000;
NA = 40000;
mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_TREE_DEPTH'));
for i=1:length(Ds)
   D = Ds(i);
   dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
   system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_TREE_DEPTH', ... 
                                sprintf('SAMME,_D=%d.txt', D))));                              
   close all;
end
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SAMME_TREE_DEPTH');

% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth
mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_N_NEGS'));
Ts = [4096]; %[2048, 4096];
Ns = [5000, 5000, 7500]; %10000];
NAs = [10000, 20000, 30000]; %, 40000];
Ds = [2]; %, 3]; %, 3, 4];
for i=1:length(Ts)
  T = Ts(i);
  for j=1:length(Ns)
    N = Ns(j);
    NA = NAs(j);
    for k=1:length(Ds)
      D = Ds(k);
      dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
       system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_N_NEGS', ... 
                                sprintf('SUBCAT,_N=%d,_NA=%d.txt', N, NA))));                              
               %                 sprintf('SUBCAT,_D=%d,_T=%d,_N=%d,_NA=%d.txt', D, T, N, NA))));                              
    end
  end
end
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SUBCAT_N_NEGS');


% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth
mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_ITERATIONS'));
Ts = [2048, 4096]; %[2048, 4096];
Ns = [5000]; %10000];
NAs = [10000]; %, 40000];
Ds = [2]; %, 3]; %, 3, 4];
for i=1:length(Ts)
  T = Ts(i);
  for j=1:length(Ns)
    N = Ns(j);
    NA = NAs(j);
    for k=1:length(Ds)
      D = Ds(k);
      dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
       system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_ITERATIONS', ... 
                                sprintf('SUBCAT,_T=%d.txt', T))));                              
%                                sprintf('SUBCAT,_D=%d,_T=%d,_N=%d,_NA=%d.txt', D, T, N, NA))));                              
    end
  end
end
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SUBCAT_ITERATIONS');


% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth

mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_TREE_DEPTH'));
Ts = [4096]; %[2048, 4096];
Ns = [5000]; %10000];
NAs = [20000]; %, 40000];
Ds = [2, 3, 4]; %, 3]; %, 3, 4];
for i=1:length(Ts)
  T = Ts(i);
  for j=1:length(Ns)
    N = Ns(j);
    NA = NAs(j);
    for k=1:length(Ds)
      D = Ds(k);
      dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
       system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SUBCAT_TREE_DEPTH', ... 
                                sprintf('SUBCAT,_D=%d.txt', D))));                              
                                %sprintf('SUBCAT,_D=%d,_T=%d,_N=%d,_NA=%d.txt', D, T, N, NA))));                              
     close all;
    end
  end
end
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SUBCAT_TREE_DEPTH');


% ------------------------------------------------------------------------
% 3.3 Experiments over BAdaCost and alpha, beta and gamma values for costs.
alphaBetaGamma = [1, 1, 1; ...
                  1, 1.5, 1;...
                  1, 2, 1; ...
                  ];
D = 6;
T = 1024;
N = 10000;
NA = 40000;
mkdir(fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_VS_BADACOST'));
for i=1:size(alphaBetaGamma,1)
  costsAlpha = alphaBetaGamma(i, 1);
  costsBeta = alphaBetaGamma(i, 2);
  costsGamma = alphaBetaGamma(i, 3);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_VS_BADACOST', ... 
                                sprintf('BAdaCost,_%1.2f-%1.2f,_D=%d.txt', costsAlpha, costsBeta, D))));                              
end
                                                     
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                              fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_VS_BADACOST', ... 
                              sprintf('SAMME,_N=%2.1fk,_NA=%2.1fk.txt', N/1000, NA/1000))));                              
T=4096; D=2; N=5000; NA=20000;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'PASCAL_FACES_COMPATIBLE_Dets.txt'), ...
                                fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'PASCAL_SAMME_VS_BADACOST', ... 
                                sprintf('SUBCAT,_D=%d,_T=%d,_N=%d,_NA=%d.txt', D, T, N, NA))));                              
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=PASCAL_SAMME_VS_BADACOST');
  
 
% ------------------------------------------------------------------------
% 3.5 BAdaCost experiments over AFW 
D = 6;
T = 1024;
N = 10000;
NA = 40000;
costsAlpha = 1;
costsBeta = 2.5;
costsGamma = 1;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
disp(dataOutputDir);
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'AFW_FACES_COMPATIBLE_Dets.txt'), ...
                              fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'AFW', ... 
                              'BAdaCost.txt')));                              
                          
% SUBCAT.
D = 2; N = 5000; NA = 20000; T = 4096;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'AFW_FACES_COMPATIBLE_Dets.txt'), ...
                              fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'AFW', ... 
                              'SubCat.txt')));                              

% SAMME.
D = 6;
T = 1024;
N = 10000;
NA = 40000;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'AFW_FACES_COMPATIBLE_Dets.txt'), ...
                              fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'AFW', ... 
                              'SAMME.txt')));                              
system('cd headhunter_python_evaluation; python plot_AP.py --dataset=AFW');

 
% ------------------------------------------------------------------------
% BAdaCost experiments over FDDB
D = 6;
T = 1024;
N = 10000;
NA = 40000;
costsAlpha = 1;
costsBeta = 2.5;
costsGamma = 1;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
disp(dataOutputDir);
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempDiscROC.txt'), ...
                              fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb', ... 
                              'BAdaCost.txt')));                              
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempContROC.txt'), ...
                               fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb_continuous', ... 
                               'BAdaCost.txt')));                              

% SUBCAT.
D = 2; N = 5000; NA = 20000; T = 4096;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempDiscROC.txt'), ...
                               fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb', ... 
                               'SubCat.txt')));                              
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempContROC.txt'), ...
                               fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb_continuous', ... 
                               'SubCat.txt')));                              

% SAMME.
D = 6;
T = 1024;
N = 10000;
NA = 40000;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempDiscROC.txt'), ...
                               fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb', ... 
                               'SAMME.txt')));                              
%                               sprintf('SAMME,_N=%d,_NA=%d.txt', N, NA))));                              
system(sprintf('ln -s %s %s', fullfile(dataOutputDir, 'tempContROC.txt'), ...
                               fullfile(HEADHUNTER_EVAL_SOFTWARE_PATH, 'detections', 'fddb_continuous', ... 
                               'SAMME.txt')));                              
%                               sprintf('SAMME,_N=%d,_NA=%d.txt', N, NA))));                              
system('cd headhunter_python_evaluation; python plot_AP_fddb.py');
system('cd headhunter_python_evaluation; python plot_AP_fddb_continuous.py');
