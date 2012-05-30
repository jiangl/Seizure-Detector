function [rf,num_ignored] = RFEATURE(y,feat,L,d,varargin)
% [rf,num_ignored] = RFEATURE(y,'feature_name',L,d,additional_feature_parameters,...)
%
% Generates running feature (feature time-series) from input data for a named feature.
% y = Input data sequence. If y is a matrix, the columns dimension is the time
%		axis (signals are rows), and the feature is expected to be of multichannel type (for two channels,
%		the signals are passed to the named feature separated by comma, for more, they are passed jointly
%     as the matrix). If there are more rows than columns, the signals are assumed to be columns and if
%     additionally multiple features are returned, they are expected to be a row (e.g., MEAN of matrix).
% L = Observation window length
% d = Displacement between consecutive slides of the window = L - overlap
% 'feature_name' = Name of the m-file or internal function that implements the feature.
% 		If this function outputs a vector for each feature instant, it is expected to
%		be a column, and then rf is a matrix with the vector's trajectory.
% Additional parameters particular of a feature are passed as a comma-separated list.
% rf = Running features, with one column per feature time, and one row per output returned by the named feature.
%
% L and d > 1 cause a compression in the time axis: length(rf) < length(y).
% The running feature is "right aligned" so that the last value of a feature always
% corresponds in time to the last value of y (e.g., the time of UEO). This implies
% that some values of y may be ignored from the beginning (instead of from the end).
% The alignment is such that the command
%		[zeros(1,num_ignored+L-1) interp1(num_ignored+L:d:length(y),rf,num_ignored+L:length(y),'*linear')]
% is exactly time-synchronized with and has the same length as the original data sequence y.
% This interpolated feature sequence can be fed to classifiers to see their output at each "real-time" data instant,
% but this is non-causal. There's no interp in MATLAB for a zero-order hold.
% For a more realistic, online, zero-order hold version, use
%		[zeros(1,num_ignored+L-1) zohinterp(rf(1:end-1),d) rf(end)]
%							[re, ext. jre 8/00]

% (Extended to multi-input data and multi-ouput features; added help)
% (Implemented using FEVAL instead of EVAL; same speed, but cleaner and compiles to C++)
% (Made 1-D signal case accept column)
% (Added cases so that for matrix y, common functions such as MEAN & CORRCOEF can operate along their default dimension)


Ly = length(y);
num_seg = floor((Ly-L)/d + 1);   % Number of sliding obs windows that fit within the length of y
num_ignored = Ly-L+d-num_seg*d;   % Number of points ignored from the beginning of y

signals_were_rows = 1; if size(y,1)>size(y,2), signals_were_rows = 0; end
switch signals_were_rows
  case 1   % For user-defined functions which take row signals and return a column of features
   if size(y,1)~=2
      % Run just once the first time to find out if feature gives multiple outputs ...
      n = 1;
      rf(:,n) = feval(feat,y(:,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),varargin{:});
      rf = [rf zeros(size(rf,1),num_seg-1)];   % to allow initialization and slightly faster execution of the rest
      for n=2:num_seg
         rf(:,n) = feval(feat,y(:,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),varargin{:});
      end
   else   % For two channels, will send to feature separated by comma instead of as matrix
      n = 1;
      rf(:,n) = feval(feat,y(1,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),y(2,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),varargin{:});
      rf = [rf zeros(size(rf,1),num_seg-1)];
      for n=2:num_seg
         rf(:,n) = feval(feat,y(1,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),y(2,num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L),varargin{:});
      end
   end
   
  case 0   % For common MATLAB functions such as MEAN (better make it work across dim 2 by sending addit param 2 and not 2 channels) & CORRCOEF (after extracting element 1,2)
   if size(y,2)~=2
      % Run just once the first time to find out if feature gives multiple outputs ...
      n = 1;
      rf(:,n) = feval(feat,y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,:),varargin{:})';
      rf = [rf zeros(size(rf,1),num_seg-1)];   % to allow initialization and slightly faster execution of the rest
      for n=2:num_seg
         rf(:,n) = feval(feat,y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,:),varargin{:})';
      end
   else   % For two channels, will send to feature separated by comma instead of as matrix
      n = 1;
      rf(:,n) = feval(feat,y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,1),y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,2),varargin{:})';
      rf = [rf zeros(size(rf,1),num_seg-1)];
      for n=2:num_seg
         rf(:,n) = feval(feat,y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,1),y(num_ignored+1+(n-1)*d:num_ignored+(n-1)*d+L,2),varargin{:})';
      end
   end
   
end
