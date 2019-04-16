% This script is used to reproduce the results for  DELF-ASMK* in the paper 
% Radenovic, Iscen, Tolias, Avrithis, and Chum,
% Revisiting Oxford and Paris: Large-Scale Image Retrieval Benchmarking, CVPR 2018
% It creates the indexing structure on ROxford or RParis (optionally with R1m distractors) 

addpath('../');
addpath('../yael');
rmpath('revisitop-master/matlab'); addpath('revisitop-master/matlab');

dir_data 				= '/mnt/lascar/toliageo/projects/revop/reproduce/data/';
% dataset 				= 'rparis6k';
dataset 				= 'roxford5k';
addr1m          = true;       % add 1 million distractors
% parameters
nbits 					= 128;        % dimension of binary signatures`
k 							= 2^16;       % codebook size
ivf_train_nimg 	= 60000; 			% number of training images for IVF median estimation
Nr1m 						= 1001001;		% number of images in r1m
batch_size 			= 1000;				% number of images stored per file

data_root = fullfile(fileparts(mfilename('fullpath')), 'data')
cfg = configdataset (dataset, fullfile(data_root, 'datasets/')); 

%%% Training of IVF
fprintf('Training/Initializing the ivf\n');
codebook = load_ext(fullfile(dir_data,'/train/','/delf_randsample20M_kmeans_65k.fvecs'));
vwtrain = int32(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_vw.%d.uint32', [dir_data,'/train/'], i), 1), 1:ceil(ivf_train_nimg/batch_size), 'un', 0)));
destrain = cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_desc.%d.fvecs', [dir_data,'/train/'], i), 128), 1:ceil(ivf_train_nimg/batch_size), 'un', 0));
ivfstruct = yael_ivf_he (k, nbits, destrain, @yael_nn, codebook, vwtrain);
clear destrain vwtrain;


%%% Load the main dataset
fprintf('Loading %s to the ivf\n', cfg.dataset);
desd = single(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_desc.%d.fvecs', [dir_data, cfg.dataset], i), 128), 1:ceil(cfg.n/batch_size), 'un', 0)));
nofd = uint32(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_nof.%d.uint32', [dir_data, cfg.dataset], i), 1), 1:ceil(cfg.n/batch_size), 'un', 0)));
vwd = uint32(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_vw.%d.uint32', [dir_data, cfg.dataset], i), 1), 1:ceil(cfg.n/batch_size), 'un', 0)));

[vwd, desd, nof_aggrd] = aggregate_all(uint32(vwd), desd, uint32(nofd)); % aggregation for ASMK*
nof_aggr = [nof_aggrd]; nof = nofd; vw  = vwd;
Nivf = 0;
ivfstruct.add (ivfstruct, uint32((1:numel(vwd))+Nivf), desd, vwd);   % add to the ivf
% geom = single(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_geom.%d.float', [dir_data,cfg.dataset], i), 5), 1:ceil(cfg.n/batch_size), 'un', 0)));

%%% Load R1M distractors
if addr1m
	fprintf('Loading distractor images to the ivf\n'); 
	for i = 1:ceil(Nr1m/batch_size)
		t=tic;
		desd = single(load_ext (sprintf ('%s/delf_desc.%d.fvecs', [dir_data, '/r1m/'], i), 128));
	  vwd = uint32(load_ext (sprintf ('%s/delf_vw.%d.uint32', [dir_data, '/r1m/'], i), 1));
		nofd = uint32(load_ext (sprintf ('%s/delf_nof.%d.uint32', [dir_data, '/r1m/'], i), 1));
   	[vwd, desd, nof_aggrd] = aggregate_all(uint32(vwd), desd, uint32(nofd)); 
		Nivf = sum(nof_aggr);	
		nof_aggr = [nof_aggr, nof_aggrd]; nof = [nof, nofd]; vw = [vw, vwd];
		assert(numel(vwd)+Nivf < 2^32, 'Assertion failed: Features ids in ivf\n');
		ivfstruct.add(ivfstruct, uint32((1:numel(vwd))+Nivf), desd, vwd);
		fprintf('Added chunk %d in %.2f seconds\n', i, toc(t));
	end
	% geom = [geom, single(cell2mat(arrayfun(@(i) load_ext(sprintf ('%s/delf_geom.%d.float', [dir_data,'/r1m/'], i), 5), 1:ceil(N/batch_size), 'un', 0))) ];
end

%%% Save IVF and other
if addr1m, extra_str = [cfg.dataset, '_r1m']; else, extra_str = [cfg.dataset]; end
ivf_fname = sprintf('%s/ivf_%s_k%d_nbits%d', dir_data, extra_str, k, nbits); 
fprintf('Saving in %s\n', ivf_fname);
ivfextra_fname = [ivf_fname, '_extra.mat'];
ivfgeom_fname = [ivf_fname, '_geom.float'];
ivfstruct.save (ivfstruct, ivf_fname);
save(ivfextra_fname, 'nof', 'vw', 'nof_aggr','-v7.3');
% save_ext(ivfgeom_fname, geom, 0);
yael_ivf('free'); 