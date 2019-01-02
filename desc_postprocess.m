% Apply some post-processing operations 
%
% Usage: [X Xm] = desc_postprocess (X, Xm)
%
%  X   descriptors
%  Xm  mean descriptor after root-SIFT and L2 normalization
function [X Xm] = desc_postprocess (X, Xm)

X = single (X);
X = X.^0.5; % Root-SIFT
X = yael_fvecs_normalize (X); % L2 normalize

if ~exist ('Xm')
  Xm = mean (X, 2);
end

X = bsxfun (@minus, X, Xm);   % Subtract the mean
X = yael_fvecs_normalize (X); % L2 normalize
X = single (X);
