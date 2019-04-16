% Crop features inside a bounding box
%
% Usage: [idx] = crop_query (bbx, xy)
%
%  bbx  bounding box coordinates
%  xy   coordinates of the feature position
%  idx  indices of features inside the bounding box
%
% Authors: G. Tolias, Y. Avrithis, H. Jegou. 2013. 
%
function idx = crop_query (bbx, xy)

idx = find( xy(1, :)>bbx(1) & xy(1, :)<bbx(3) & xy(2, :)>bbx(2) & xy(2, :)<bbx(4) );
