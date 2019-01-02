% Compute inverted document frequency (idf)
%
% Usage: [idf] = compute_idf (vidx, nf, k);
%
%   vidx  input vector with visual words (concatenated for all images)
%   nf    input vector with number of features per image
%   k     number of visual words
function idf = compute_idf (vidx, nf, k)

nvw = zeros (k,1);

cs = [1 cumsum(double (nf)) + 1];

for i=1:length (nf)

  vw = vidx (cs (i):cs (i + 1) -1);

  u = unique (vw);

  nvw(u) = nvw(u) + 1;	

end

idf = log (length (nf) ./ nvw);
idf (find (isinf (idf))) = 0;
