% Compute normalization factor (for aggregated descriptors) for a set of images
%
% Usage: normf = compute_norm_factor (vidx, nf, idf);
%
%  vidx  input vector with visual words (concatenated for all images)
%  nf    input vector with number of features per image 
%  idf   idf values
%  normf normalization factors
%
% Authors: G. Tolias, Y. Avrithis, H. Jegou. 2013. 
%
function normf = compute_norm_factor (vidx, nf, idf)

cs = [1 cumsum( double (nf)) + 1];

normf = ones (1, numel(nf));

%loop over all images, compute normalization factor for each one
for i = 1:numel(nf)
  if ~nf(i)
    continue;
  end

  ridx = cs(i):cs(i + 1) - 1;

  uv = unique (vidx (ridx));

  % when aggregation is considered, the normalization factor is equal
  % to the squarerooted sum of the idf values of visual words that appear
  % in the image, each visual word counted only once
  normf(i) = sqrt (sum (idf (uv)));
  
end

normf(normf == 0) = 1.0;
