% Aggregate descriptors per visual word for a set of images
% 
% Usage: [va, da, na] = aggregate_all (v, d, n)
%
%  d  input matrix with descriptors (concatenated for all images)
%  v  input vector with visual words (concatenated for all images)
%  n  input vector with number of feature per image
%  da aggregated descriptors (concatenated for all images)
%  va unique visual words for each image (concatenated for all images)
%  na number of features per image after aggregation
%
% Authors: G. Tolias, Y. Avrithis, H. Jegou. 2013. 
%
function [va, da, na] = aggregate_all (v, d, n)
	
cs = [1 cumsum( double (n)) + 1];

%loop over all images, aggregate descriptors for each one
for i = 1:numel(n)
  if ~n(i)
    na(i) = 0;
    va{i} = uint32 ([]);
    da{i} = zeros (size (d, 1), 0, 'single');
   continue;
  end

  rng = cs(i):cs(i+1)-1;
  [va{i}, da{i}] = aggregate (v(rng), d(:, rng));
  na(i) = numel (va{i});	
end

va = cell2mat (va);
da = cell2mat (da);

% aggregate descriptors per visual word for a single image
%  d   descriptors 
%  v   visual words
%  da  aggregated descriptors
%  va  unique visual words
function [va, da] = aggregate(v, d)

va = unique(v);
n = numel(va);
da = zeros (size (d, 1), n, 'single');

for i = 1:n
  f = find(v==va(i));

  if numel(f) == 1
    da(:,i) = d(:,f);		
  else
    % compute mean descriptor here, median will be subtracted before binarizing
	% that would be equal to the mean residual instead of aggregated residual
	% but binarization of each produces the same binary vector
    da(:,i) = mean(d(:,f), 2);		
  end
end