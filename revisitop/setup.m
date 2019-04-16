skip_r1m_download = false; % if true, do not download the distractor DELF files

% download revisitop package
if ~exist('revisitop-master') 
	fprintf('Downloading revisitop package from github\n');
	system('rm master.zip');
	system('wget https://github.com/filipradenovic/revisitop/archive/master.zip');
	system('unzip master.zip');
end	 
addpath('revisitop-master/matlab');
% download yael
if ~exist('../yael') 
	fprintf('Downloading pre-compiled yael from gforge\n');
  system('wget https://gforge.inria.fr/frs/download.php/file/34218/yael_matlab_linux64_v438.tar.gz');
  system('mkdir ../yael');
  system('tar -C ../yael/ -zxvf yael_matlab_linux64_v438.tar.gz');
end

% download datasets 
data_root = fullfile(fileparts(mfilename('fullpath')), 'data')
download_datasets(data_root)
% download_distractors(data_root); % comment out to get 10^6 distractor image files

% Download DELF features
url_delf = 'http://ptak.felk.cvut.cz/personal/toliageo/share/revisitop/features/delf/';
path_delf = fullfile(data_root, 'delf');
if ~exist(path_delf)
	mkdir(path_delf);
end
% Download DELF for roxford5k
if ~exist(fullfile(path_delf, 'roxford5k.tar.gz'))
	fprintf('Download and untar DELF features for ROxford\n');
	system(sprintf('wget %s/roxford5k.tar.gz -O %s/roxford5k.tar.gz', url_delf, path_delf));
	system(sprintf('mkdir %s/roxford5k/', path_delf));
	system(sprintf('tar -C %s -zxvf %s/roxford5k.tar.gz', path_delf, path_delf));
end
% Download DELF for rparis6k
if ~exist(fullfile(path_delf, 'rparis6k.tar.gz'))
	fprintf('Download and untar DELF features for RParis\n');
	system(sprintf('wget %s/rparis6k.tar.gz -O %s/rparis6k.tar.gz', url_delf, path_delf));
	system(sprintf('mkdir %s/rparis6k/', path_delf));
	system(sprintf('tar -C %s -zxvf %s/rparis6k.tar.gz', path_delf, path_delf));
end
% download DELF for training set (for ivf and codebook)
if ~exist(fullfile(path_delf, 'train'))
	mkdir(fullfile(path_delf, 'train'));
	fprintf('Download and untar DELF features for the external set used for ivf and codebook learning\n');
	fprintf('This will take a while....\n'); pause(10);
	for i = 0:12,
		zname = sprintf('train.%d.tar.gz',i);
		if ~exist(fullfile(path_delf, 'train', zname))
			system(sprintf('wget %s/train/%s -O %s/train/%s', url_delf, zname, path_delf, zname));
			system(sprintf('tar -C %s/train/ -zxvf %s/train/%s', path_delf, path_delf, zname));
		end
	end
end
% download DELF for r1m
if ~skip_r1m_download
	if ~exist(fullfile(path_delf, 'r1m'))
		mkdir(fullfile(path_delf, 'r1m'));
		fprintf('Download and untar DELF features for R1m\n');
		fprintf('This will take a while....\n'); pause(10);
		for i = 0:100,
			zname = sprintf('r1m.%d.tar.gz',i);
			if ~exist(fullfile(path_delf, 'r1m', zname))
				system(sprintf('wget %s/r1m/%s -O %s/r1m/%s', url_delf, zname, path_delf, zname));
				system(sprintf('tar -C %s/r1m/ -zxvf %s/r1m/%s', path_delf, path_delf, zname));
			end
		end
	end
end
