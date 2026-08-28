function gapFill_filter(output_name,output_path)
clearvars -except output_name output_path

load(fullfile(output_path,[output_name '_pose.mat']));

lateral = {'right','left'};
bradyKin_items = fieldnames(bradyKin_analyze);
%% Interpolate over gaps
for i = 1:length(bradyKin_items)
    for j = 1:length(lateral)
%% openpose
        eval(['data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill = nan(size(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw));'])
        eval(['frameInfo.openpose.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.body = false(size(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,:,1)));'])

        eval(['[noFrames noKeypoints noCoor] = size(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k))) > 1; data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k) = interp1gap(data.openpose.' bradyKin_items{i} '.' lateral{j} '.time,data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k),data.openpose.' bradyKin_items{i} '.' lateral{j} '.time,0.400); end; nan_data_body = isnan(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k)); frameInfo.openpose.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.body(nan_data_body,m) = ~isnan(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(nan_data_body,m,1)); end; clearvars nan_data_body; end; clearvars m k noFrames noKeypoints noCoor; '])
%% mediapipe        
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw));'])
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.gapFill = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw));'])
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.gapFill = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw));'])
        eval(['frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.body = false(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,:,1)));'])
        eval(['frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right = false(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw(:,:,1)));'])
        eval(['frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left = false(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw(:,:,1)));'])

        eval(['[noFrames noKeypoints noCoor] = size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k))) > 1; data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k) = interp1gap(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k),data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,0.400); end; nan_data_body = isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw(:,m,k)); frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.body(nan_data_body,m) = ~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(nan_data_body,m,1)); end; clearvars nan_data_body; end; clearvars m k noFrames noKeypoints noCoor; '])

        eval(['[noFrames noKeypoints noCoor] = size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw(:,m,k))) > 1; data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.gapFill(:,m,k) = interp1gap(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw(:,m,k),data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,0.400); end; nan_data_hand_right = isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw(:,m,k)); frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right(nan_data_hand_right,m) = ~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.gapFill(nan_data_hand_right,m,1)); if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw(:,m,k))) > 1; data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.gapFill(:,m,k) = interp1gap(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw(:,m,k),data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.time,0.400); end; nan_data_hand_left = isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw(:,m,k)); frameInfo.mediapipe.isGapFilled.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left(nan_data_hand_left,m) = ~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.gapFill(nan_data_hand_left,m,1)); end; clearvars  nan_data_hand_right nan_data_hand_left; end; clearvars m k noFrames noKeypoints noCoor;'])
    end
end
%% Low-pass filter
ANyq = videoInfo.vid.FrameRate/2;
cf = 5; % set cut-off frequency
Wn = cf/ANyq/.802;
[B,A] = butter(2,Wn,'low');

for i = 1:length(bradyKin_items)
    for j = 1:length(lateral)
%% openpose
        eval(['data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.filt = nan(size(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw));'])

        eval(['[noFrames noKeypoints noCoor] = size(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k))) > 6;  data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.filt(:,m,k) = nanfiltfilt(B,A,data.openpose.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k)); end; end; clearvars nan_data_body; end; clearvars m k noFrames noKeypoints noCoor; '])
%% mediapipe
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.filt = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw));'])
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.filt = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw));'])
        eval(['data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.filt = nan(size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.raw));'])

        eval(['[noFrames noKeypoints noCoor] = size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k))) > 6;  data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.filt(:,m,k) = nanfiltfilt(B,A,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.body.gapFill(:,m,k)); end; end; clearvars nan_data_body; end; clearvars m k noFrames noKeypoints noCoor; '])

        eval(['[noFrames noKeypoints noCoor] = size(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.raw);'])
        eval(['for m = 1:noKeypoints; for k = 1:noCoor; if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.gapFill(:,m,k))) > 6; data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.filt(:,m,k) = nanfiltfilt(B,A,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.right.gapFill(:,m,k)); end; if sum(~isnan(data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.gapFill(:,1,1))) > 6; data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.filt(:,m,k) = nanfiltfilt(B,A,data.mediapipe.' bradyKin_items{i} '.' lateral{j} '.pose.hand.left.gapFill(:,m,k)); end; end; clearvars nan_data_hand_right nan_data_hand_left; end; clearvars m k noFrames noKeypoints noCoor;'])
    end
end
%%
save(fullfile(output_path,[output_name '_pose.mat']),'data','frameInfo','-append');
end
%% inter1gap function
function [ vq ] = interp1gap(varargin)
%INTERP1GAP performs interpolation over small gaps in 1D data. 
% 
%% Syntax
% 
%  vq = interp1gap(v)
%  vq = interp1gap(x,v,xq)
%  vq = interp1gap(...,maxgapval)
%  vq = interp1gap(...,'method')
%  vq = interp1gap(...,'interpval',vval)
%  vq = interp1gap(...,'extrap',extrapval)
% 
%% Description 
% 
% vq = interp1gap(v) linearly interpolates to give undefined (NaN) values of v.
%
% vq = interp1gap(x,v,xq) interpolates to find vq, the values of the underlying 
% function v at the points in the vector or array xq.
%
% vq = interp1gap(...,maxgapval) specifies a maximum gap in the independent variable
% over which to interpolate. If x and xq are given, units of maxgapval match the
% units of x.  If x and xq are not provided, units of maxgapval are indices
% of v, assuming any gaps in v are represented by NaN.  If maxgapval is not 
% declared, interp1gap will interpolate over infitely-large gaps. 
%
% vq = interp1gap(...,'method') specifies a method of interpolation. Default method 
% is 'linear', but can be any of the following: 
%
% * 'nearest' nearest neighbor interpolation 
% * 'linear' linear interpolation (default) 
% * 'spline' cubic spline interpolation
% * 'pchip' piecewise cubic Hermite interpolation
% * 'cubic' (same as 'pchip')
% * 'v5cubic' Cubic interpolation used in MATLAB 5. 
% * 'next' next neighbor interpolation (Matlab R2014b or later) 
% * 'previous' previous neighbor interpolation (Matlab R2014b or later) 
% 
% vq = interp1gap(...,'interpval',vval) specifies a value with which to replace 
% vq elements corresponding to large gaps. Default is NaN. 
% 
% vq = interp1gap(...,'extrap',extrapval) returns the scalar extrapval
% for out-of-range values. NaN and 0 are often used for extrapval. 
% 
%% Examples 
% EXAMPLE 1: Interpolate over gaps equal to or smaller than 0.5 x units:
% 
% First create some data with holes and plot it: 
% x = 0:.02:15; 
% y = sin(x); 
% x([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% y([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% plot(x,y,'ko'); hold on
% 
% % Now interpolate y values to an xi grid: 
% xi = 0:.015:15;
% yi = interp1gap(x,y,xi,.5); 
% 
% plot(xi,yi,'b.')
% 
% .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
%
% EXAMPLE 2: Same as Example 1, but cubic interpolation instead of default linear:
% 
% First create some data with holes and plot it: 
% x = 0:.02:15; 
% y = sin(x); 
% x([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% y([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% plot(x,y,'ko'); hold on
% 
% % Now interpolate y values to an xi grid: 
% xi = 0:.015:15;
% yi = interp1gap(x,y,xi,.5,'cubic'); 
% 
% plot(xi,yi,'b.')
% 
% .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
%
% EXAMPLE 3: Same as Example 2, but replace large holes with y = 0.75:
% 
% % First create some data with holes and plot it: 
% x = 0:.02:15; 
% y = sin(x); 
% x([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% y([1:3 25 32:33 200:280 410:425 500:575]) = []; 
% plot(x,y,'ko'); hold on
% 
% % Now interpolate y values to an xi grid: 
% xi = 0:.015:15;
% yi = interp1gap(x,y,xi,.5,'cubic','interpval',.75); 
% 
% plot(xi,yi,'b.')
% 
%% Author Info:
% Written by Chad Greene with help from 'Paul', Feb. 2014. 
% (http://www.mathworks.com/matlabcentral/answers/117174)
% Updated November 2014 to allow for monotonically decreasing x. 
% 
% http://www.chadagreene.com
% The University of Texas at Austin
% Institute for Geophysics (UTIG)
%
% See also interp1, interp1q, interp2, interpn. 


%% Check inputs:

assert(nargin>0,'interp1gap requires at least one input. C''mon, one lousy input is the least you could do.')

%% Set defaults: 

maxgapval = inf; 
method = 'linear'; 
interpval = NaN; 
extrap = false; 

% Look for user-defined interpolation method: 
tmp = strncmpi(varargin,'lin',3)|strncmpi(varargin,'cubic',3)|...
    strncmpi(varargin,'near',4)|strncmpi(varargin,'spline',3)|...
    strncmpi(varargin,'pchip',3)|strncmpi(varargin,'v5cub',3)|...
    strncmpi(varargin,'next',4)|strncmpi(varargin,'prev',4); 
if any(tmp)
    method = varargin{tmp}; 
    varargin = varargin(~tmp); 
end

% Look for user-defined interpval: 
tmp = strncmpi(varargin,'interpval',6); 
if any(tmp)
    interpval = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
end

% Look for user-defined extrapval: 
tmp = strncmpi(varargin,'extrap',6); 
if any(tmp)
    extrapval = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
    extrap = true; 
    assert(isscalar(extrapval)==1,'Extrapval must be a scalar.') 
end

narginleft = length(varargin); % the number of arguments after parsing inputs

%% Parse inputs:
% If only one input is declared, assume the user simply wants to interpolate
% over any NaN values in the input. 
if narginleft==1 
    v = varargin{1}; 
    x = 1:length(v); 
    xq = x;
end

% If only two inputs are declared, assume NaN interpolation as above, and
% assume the second input is the maxgapval: 
if narginleft==2
    v = varargin{1}; 
    maxgapval = varargin{2};
    x = 1:length(v); 
    xq = x; 
end    

% If no maxgapval is declared, assume infinitely large gaps are A-OK:
if narginleft==3 
    x = varargin{1}; 
    v = varargin{2}; 
    xq = varargin{3}; 
end

if narginleft==4 
    x = varargin{1}; 
    v = varargin{2}; 
    xq = varargin{3}; 
    maxgapval = varargin{4};
end

%% Post-parsing input checks: 

assert(isscalar(maxgapval)==1,'maxgapval must be a scalar.') 
assert(isnumeric(x)==1&isvector(x)==1,'x must be a numeric array.') 
assert(isvector(v)==1,'Input v must be a vector.') 
assert(isvector(xq)==1,'Input xq must be a vector.') 

%% Deal with input NaNs: 

x = x(~isnan(v)); 
v = v(~isnan(v)); 

%% Columnate everything: 
% Columnation may be unnecessary, but it ensures that the heavy lifting will always be performed 
% the same way, regardless of input format: 

StartedRow = false; 
if isrow(xq)
    xq = xq'; 
    StartedRow = true; 
end

x = x(:); 
v = v(:); 

%% Perform interpolation: 

if extrap
    vq = interp1(x,v,xq,method,extrapval); 
else
    vq = interp1(x,v,xq,method); 
end

%% Replace data where gaps are too large: 

% Find indices of gaps in x larger than maxgapval: 
x_gap = diff(x); 
ind=find(abs(x_gap)>maxgapval);

% Preallocate array which will hold vq indices corresponding to large gaps in x data: 
ind_int=[];  

% For each gap, find corresponding xq indices: 
for N=1:numel(ind)
    
    if x_gap(1)>=0 % assume x is montaonically increasing
        ind_int = [ind_int;find((xq>x(ind(N)) & xq<x(ind(N)+1)))];
        
    else % assume x is monatonically decreasing
        ind_int = [ind_int;find((xq>x(ind(N)+1) & xq<x(ind(N))))];
    end
end

% Replace vq values corresponding to large gaps in x:  
vq(ind_int)=interpval;

%% Clean up: 

% If xq started as a row vector, return vq as a row vector:  
if StartedRow
    vq = vq'; 
end
end
%% nanfiltfilt function
function Y = nanfiltfilt(B, A, X)
%  Y = NANFILTFILT(B, A, X) filters data X with NaNs by segmenting data
%  into pieces without NaNs.
[m n] = size(X);
if ~any(isnan(X(:)))
    Y = filtfilt(B,A,X);
    return
end
if ndims(X)<=2
    Y = nan(m,n);
    for i = 1:n
        x = X(:,i);
        if all(~isnan(x))
            Y(:,i) = filtfilt(B,A,x);
        else
            y = ~isnan(x);
            dy = diff(y);
            t1 = find(dy==1)+1;
            t2 = find(dy==-1);
            if ~isempty(t1) && ~isempty(t2)
                if t1(1)>t2(1)
                    t1 = [1; t1];
                end
                if (length(t1)>length(t2))
                    t2 = [t2; length(y)];
                end
                for j = 1:length(t1)
                    seg = x(t1(j):t2(j));
                    if length(seg) > 3*length(B)
                        Y(t1(j):t2(j),i) = filtfilt(B,A,seg);
                    else
                        Y(t1(j):t2(j),i) = seg;
                    end
                end
            elseif isempty(t1)
                seg = x(1:t2);
                Y(1:t2) = filtfilt(B,A,seg);
            elseif isempty(t2)
                seg = x(t1:end);
                Y(t1:end) = filtfilt(B,A,seg);
            end
        end
    end
end
end