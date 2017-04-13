function nbeats = nheartbeats(data, varargin)
  %NHEARTBEATS Determines the number of heart beats in the given EKG sample
  %data interval.
  %   Param:
  %      data - an EKG data interval, represented as a 1-D vector
  %      mph  - 'MinPeakHeight' property (optional, 800 by default)
  %   Return:
  %      nbeats - the number of heart beats
  %
  %   Since:  April 13, 2017
  %   Author: Ted Frohlich <ttf10@case.edu>
  
  if (nargin > 0)
    mph = varargin{1};
  else
    mph = 800;
  end
  
  next = zeros(size(data));
  next(1:end-1) = data(2:end);
  
  ibeats = find(data <= mph & next > mph);
  nbeats = length(ibeats);
  
end
