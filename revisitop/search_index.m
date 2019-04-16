% This script is used to reproduce the results for  DELF-ASMK* in the paper 
% Radenovic, Iscen, Tolias, Avrithis, and Chum,
% Revisiting Oxford and Paris: Large-Scale Image Retrieval Benchmarking, CVPR 2018
% It searches using DELF-ASMK* on ROxford or RParis (optionally with R1m distractors) 
% SP is not (yet) part of the provided package

addpath('../');
addpath('../yael'); 
rmpath('revisitop-master/matlab'); addpath('revisitop-master/matlab');

dir_data 				= '/mnt/lascar/toliageo/projects/revop/reproduce/data/';
% dataset 				= 'rparis6k';
dataset 				= 'roxford5k';
addr1m          = true;       % use the index with 1 million distractors
% parameters
prm.nbits 		  = 128;        % dimension of binary signatures
prm.k 					= 2^16;       % codebook size
prm.ma 					= 3;					% descriptor soft-assignment to ma visual words
prm.ht 					= 48;         % hamming distance threshold, (similarity threshold in the paper tau = 1-2*ht/nbits)

data_root = fullfile(fileparts(mfilename('fullpath')), 'data')
cfg = configdataset (dataset, fullfile(data_root, 'datasets/')); 

if addr1m, extra_str = [cfg.dataset, '_r1m']; else, extra_str = [cfg.dataset]; end
ivf_fname = sprintf('%s/ivf_%s_k%d_nbits%d', dir_data, extra_str, prm.k, prm.nbits); 
fprintf('Loading from %s\n', ivf_fname);
ivfextra_fname = [ivf_fname, '_extra.mat'];
ivfgeom_fname = [ivf_fname, '_geom.float'];

ivfstruct = yael_ivf_he (ivf_fname);
load(ivfextra_fname, 'vw', 'nof', 'nof_aggr');

ivfstruct.scoremap = single (sign ([1:-2/ivfstruct.nbits:-1]) .* abs([1:-2/ivfstruct.nbits:-1]) .^ 3);
ivfstruct.cs    		= [1 cumsum( double (nof_aggr)) + 1];
ivfstruct.listw 		= single (compute_idf (vw, nof_aggr, ivfstruct.k)) .^ 2;
ivfstruct.normf 		= compute_norm_factor (vw, nof_aggr, ivfstruct.listw);
ivfstruct.geom_fname = ivfgeom_fname;

% Compute image ids for all descriptors to be inserted in the ivf structure
[~, image_ids] = histc (1:sum(nof_aggr), [1 cumsum(double (nof_aggr)) + 1]);

fprintf ('* Perform queries\n');
for q = 1:cfg.nq
	% im = crop_qim(imread(cfg.qim_fname(cfg, q)), uint32(max(cfg.gnd(q).bbx+1, 1)));
	desq = single(load_ext([dir_data, dataset, '/queries/delf_desc.', num2str(q), '.fvecs']));

	[vwq, ~] = ivfstruct.quantizer (ivfstruct.quantizer_params, desq, prm.ma);	vwq = uint32(vwq);
	querystruct.vw = int32(reshape (vwq', [1, prm.ma * size(desq, 2)]));
	querystruct.des = repmat (desq, 1, prm.ma);
	[querystruct.vw, querystruct.des, ~] = aggregate_all(uint32(querystruct.vw), querystruct.des, uint32(numel(querystruct.vw))); 	
	querystruct.bs = ivfstruct.binsign (ivfstruct, querystruct.des, querystruct.vw);
	t = tic;
	[matches, sim] = ivfstruct.queryw (ivfstruct, int32(1:numel(querystruct.vw)), querystruct.des, prm.ht, querystruct.vw, querystruct.bs);
	fprintf ('* Performed query %d in %.3f seconds\n', q, toc(t));		
	score = accumarray (image_ids(matches (2,:))', sim, [numel(ivfstruct.normf) 1]) ./ ivfstruct.normf';
  [~, ranks(:, q)] = sort (score, 'descend');
end


% evaluate ranks
ks = [1, 5, 10];
% search for easy (E setup)
for i = 1:numel(cfg.gnd), gnd(i).ok = [cfg.gnd(i).easy]; gnd(i).junk = [cfg.gnd(i).junk, cfg.gnd(i).hard]; end
[mapE, apsE, mprE, prsE] = compute_map (ranks, gnd, ks);
% search for easy & hard (M setup)
for i = 1:numel(cfg.gnd), gnd(i).ok = [cfg.gnd(i).easy, cfg.gnd(i).hard]; gnd(i).junk = cfg.gnd(i).junk; end
[mapM, apsM, mprM, prsM] = compute_map (ranks, gnd, ks);
% search for hard (H setup)
for i = 1:numel(cfg.gnd), gnd(i).ok = [cfg.gnd(i).hard]; gnd(i).junk = [cfg.gnd(i).junk, cfg.gnd(i).easy]; end
[mapH, apsH, mprH, prsH] = compute_map (ranks, gnd, ks);

fprintf('>> %s: mAP E: %.2f, M: %.2f, H: %.2f\n', dataset, 100*mapE, 100*mapM, 100*mapH);
fprintf('>> %s: mP@k[%d %d %d] E: [%.2f %.2f %.2f], M: [%.2f %.2f %.2f], H: [%.2f %.2f %.2f]\n', dataset, ks(1), ks(2), ks(3), 100*mprE, 100*mprM, 100*mprH);
