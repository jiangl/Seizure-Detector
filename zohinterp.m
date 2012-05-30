function yi = ZOHINTERP(y,uf)
% ZOHINTERP(y,uf)
%							J. Echauz 9/00, Modified R. Esteller 02-09-01 
% Expands the vector y with zero-order hold samples by an upsampling factor uf.
% The resulting vector is uf times longer.
% Example:
% [1 3 2 -1] with uf = 3 becomes [1 1 1 3 3 3 2 2 2 -1 -1 -1]


yi = reshape(repmat(y,uf,1),1,length(y)*uf);
