% Creates config structure with filenames of data
% The function optionally takes a path to specify where data is stored
%
% Authors: G. Tolias, Y. Avrithis, H. Jegou. 2013. 
%
function cfg = config_oxford(datarootdir)

if ~exist('datarootdir')
  cfg.datarootdir = 'data/';
else cfg.datarootdir = datarootdir;
end

% Training data descriptors for Paris6k dataset
% Provided by CVUT (Prague)
cfg.train_sift_fname = [cfg.datarootdir 'paris_sift.uint8'];
% File storing visual words of Paris6k descriptors used in our ICCV paper
cfg.train_vw_fname = [cfg.datarootdir 'clust_preprocessed/oxford_train_vw.int32'];

% Pre-learned quantizer used in our ICCV paper (used if docluster=false)
cfg.codebook_fname = [cfg.datarootdir 'clust_preprocessed/oxford_codebook.fvecs'];

% Files storing descriptors/geometry for Oxford5k dataset
% Provided by CVUT (Prague)
cfg.test_sift_fname = [cfg.datarootdir 'oxford_sift.uint8'];
cfg.test_geom_fname = [cfg.datarootdir 'oxford_geom_sift.float'];
cfg.test_nf_fname = [cfg.datarootdir 'oxford_nsift.uint32'];

% File storing visual words of Oxford5k descriptors used in our ICCV paper
cfg.test_vw_fname = [cfg.datarootdir 'clust_preprocessed/oxford_vw.int32'];

% File for the inverted file
cfg.ivf_fname =  [cfg.datarootdir 'ivf_oxford'];

% Ground-truth for Oxford dataset
cfg.gnd_fname =  [cfg.datarootdir 'gnd_oxford.mat'];

