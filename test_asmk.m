% This script reproduces the results of the paper "Giorgos Tolias and Yannis Avrithis and Herve Jegou,
% To aggregate or not to aggregate: Selective match kernels for image search, ICCV 2013
% It creates the indexing structure and performs retrieval
% on Oxford5k for the variant called ASMK* in the paper. 

% download yael
if ~exist('yael') 
  system('wget https://gforge.inria.fr/frs/download.php/file/34218/yael_matlab_linux64_v438.tar.gz');
  system('mkdir yael');
  system('tar -C yael/ -zxvf yael_matlab_linux64_v438.tar.gz');
end
addpath('yael');
% download required data
if ~exist('data') 
  system('wget -nH --cut-dirs=4 -r -Pdata/ ftp://ftp.irisa.fr/local/texmex/corpus/iccv2013/');
end

cfg = config_oxford();

% Parameters
nbits = 128;        % dimension of binary signatures
ht = 0;	            % similarity threshold, possible values [0,nbits/2]
alpha = 3.0;        % parameter of the selective function sign(u)*u.^alpha
k = 2^16;           % codebook size
ma = 5;             % multiple assigned visual words		

docluster = false;  % compute codebook/used a pre-computed one
compute_vw = false; % compute visual words for test set/load pre-computed ones

% -----------------------------------
% Create inverted file
% -----------------------------------

% Load training descriptors
fprintf ('* Loading and post-processing training descriptors\n'); 
vtrain = load_ext(cfg.train_sift_fname, 128);
if ~docluster
  vwtrain = load_ext(cfg.train_vw_fname);
  codebook = load_ext(cfg.codebook_fname, 128);
end

% SIFT post processing, ROOT-SIFT and SHIFT-SIFT
[vtrain vtrain_mean] = desc_postprocess (vtrain);

% Learn the ivf structure
tic;
if docluster
  % Learn the IVF structure (and codebook)
  ivfhe = yael_ivf_he (k, nbits, single(vtrain), @yael_nn);
else
  % Learn the IVF structure
  % Learned codebook and visual words of training descriptors are provided
  ivfhe = yael_ivf_he (k, nbits, single(vtrain), @yael_nn, codebook, vwtrain);
end
fprintf ('* Learned the IVF structure in %.3f seconds\n', toc); 

% Load test descriptors and number of features per image
fprintf ('* Loading and post-processing database descriptors\n'); 
vtest = single (load_ext(cfg.test_sift_fname, 128));
nftest = load_ext(cfg.test_nf_fname);

% SIFT post processing, ROOT-SIFT and SHIFT-SIFT
vtest = desc_postprocess (vtest, vtrain_mean);

% Compute visual words for test descriptors
if compute_vw
  fprintf ('* Computing visual words for database descriptors\n'); 
  [vwtest, ~] = ivfhe.quantizer (ivfhe.quantizer_params, vtest);
else
  vwtest = load_ext(cfg.test_vw_fname);
end

% Descriptor aggregation per visual word
tic;
[vwtest, vtest, nftest] = aggregate_all (vwtest, vtest, nftest);
fprintf ('* Computed aggregated descriptors in %.3f seconds\n', toc); 

% Compute image ids for all descriptors to be inserted in the ivf structure
cs = [1 cumsum(double (nftest)) + 1];
[~, ids] = histc (1: sum(nftest), cs); %image ids here

% Add descriptors to the ivf structure
tic;
[vwtest, codes] = ivfhe.add (ivfhe, int32(ids), vtest, vwtest);
fprintf ('* Added %d images to the IVF structure in %.3f seconds\n', numel(nftest), toc); 

% Weighting function for descriptor similarity
idx = [1:-2/ivfhe.nbits:-1];
scoremap =  single (sign (idx) .* abs(idx) .^ alpha);
	
% Compute idf values
tic;
listw = single (compute_idf (vwtest, nftest, ivfhe.k));
listw = listw .^ 2; % squared to account idf for both images
fprintf ('* Computed idf values in %.3f seconds\n', toc); 

% Compute normalization factors for database images
tic;
normf = compute_norm_factor (vwtest, nftest, listw);
fprintf ('* Computed normalization factors in %.3f seconds\n', toc);

fprintf ('* Imbalance factor of inverted file %d\n', ivfhe.imbfactor());

% Save ivf
fivf_name = cfg.ivf_fname;
fprintf ('* Save the inverted file to %s\n', fivf_name);
ivfhe.save (ivfhe, fivf_name);

fprintf ('* Free the inverted file\n');
% Free the variables associated with the inverted file
yael_ivf ('free');
clear ivfhe;

% Save weighting function values, idf values and normalization factors for database images
save (sprintf ('%s_other.mat', fivf_name), 'scoremap', 'listw', 'normf');

% Clear training data
clear vtrain vwtrain;

	
% -----------------------------------
% Query inverted file
% -----------------------------------

% Load ivf
fprintf ('* Load the inverted file from %s\n', fivf_name);
ivfhe = yael_ivf_he (fivf_name);
load (sprintf ('%s_other.mat', fivf_name), 'scoremap', 'listw', 'normf');

ivfhe.scoremap = scoremap;
ivfhe.listw = listw;
ivfhe.normf = normf;

% Load ground truth structure for Oxford5k
load (cfg.gnd_fname);

% Load test images and number of features per image, to be used a queries
vtest = single (load_ext(cfg.test_sift_fname, 128));
gtest = load_ext(cfg.test_geom_fname, 5);
nftest = load_ext(cfg.test_nf_fname);

% SIFT post processing, ROOT-SIFT and SHIFT-SIFT
vtest = desc_postprocess (vtest, vtrain_mean);

cs = [1 cumsum( double (nftest)) + 1];

fprintf ('* Perform queries\n');
% Query using 55 predefined bounding boxes on oxford images
for q=1:numel(qidx)
  
  fprintf ('* Loading and postprocessing query descriptors\n');	
  % Descriptors of q-th image
  dquery = vtest (:, cs(qidx(q)):cs(qidx(q)+1)-1);
  gquery = gtest (:, cs(qidx(q)):cs(qidx(q)+1)-1);
  cqidx = crop_query (gnd.bbx (q, :), gquery(1:2, :));
  dquery = dquery (:, cqidx);
 
  % Compute visual words for test descriptors
  tic;
  [vquery, ~] = ivfhe.quantizer (ivfhe.quantizer_params, dquery, ma);
  fprintf ('* Computed visual words for query descriptors in %.3f seconds\n', toc);		
  
  vquery = reshape (vquery', [1 ma * numel(cqidx)]);
  dquery = repmat (dquery, 1, ma);
  nquery = size(dquery, 2);
 							
  % Descriptor aggregation per visual word
  [vquery, dquery, nquery] = aggregate_all (vquery, dquery, nquery);
  
  % Query ivf structure and collect matches
  tic;
  [matches, sim] = ivfhe.queryw (ivfhe, int32(1:nquery), dquery, -ht + nbits / 2, vquery);
  fprintf ('* Performed query %d in %.3f seconds\n', q, toc);		

  % Compute final similarity score per image and rank
  score = accumarray (matches (2,:)', sim, [numel(nftest) 1]) ./ ivfhe.normf';
  [~, ranks(:, q)] = sort (score, 'descend');
end

% Compute mean Average Precision (mAP)
map = compute_map (ranks, gnd);
fprintf ('* mAP on Oxford5k is %.4f\n', map);
