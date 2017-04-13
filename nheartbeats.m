function nbeats = nheartbeats(data, properties)
  %NHEARTBEATS Determines the number of heart beats in the given EKG sample
  %data interval.
  %   Param:
  %      data       - an EKG data interval, represented as a 1-D vector
  %      properties - a struct containing a value for 'MinPeakHeight'
  %   Return:
  %      nbeats - the number of heart beats
  %
  %   Since:  April 13, 2017
  %   Author: Ted Frohlich (ttf10@case.edu)
  
  next = zeros(size(data));
  next(1:end-1) = data(2:end);
  
  mph = properties.MinPeakHeight;
  ibeats = find(data <= mph & next > mph);
  
  nbeats = length(ibeats);
  
end
