function [coef,pval] = y_partialcorr(x,varargin)
%Adapted from MATLAB 2015a for back compatibility. YAN Chao-Gan, 20161001.
%PARTIALCORR Linear or rank partial correlation coefficients.
%   RHO = PARTIALCORR(X) returns the sample linear partial correlation
%   coefficients between pairs of variables in X, controlling for the
%   remaining variables in X.  X is an N-by-P matrix, with rows corresponding
%   to observations, and columns corresponding to variables.  RHO is a
%   symmetric P-by-P matrix, where the (I,J)-th entry is the sample linear
%   partial correlation between the I-th and J-th columns in X.
%
%   RHO = PARTIALCORR(X,Z) returns the sample linear partial correlation
%   coefficients between pairs of variables in X, controlling for the
%   variables in Z.  X is an N-by-P matrix, and Z an N-by-Q matrix, with rows
%   corresponding to observations, and columns corresponding to variables. RHO
%   is a symmetric P-by-P matrix.
%
%   RHO = PARTIALCORR(X,Y,Z) returns the sample linear partial correlation
%   coefficients between pairs of variables between X and Y, controlling for
%   the variables in Z.  X is an N-by-P1 matrix, Y an N-by-P2 matrix, and Z an
%   N-by-Q matrix, with rows corresponding to observations, and columns
%   corresponding to variables.  RHO is a P1-by-P2 matrix, where the (I,J)-th
%   entry is the sample linear partial correlation between the I-th column in
%   X and the J-th column in Y.
%
%   If the covariance matrix of [X,Z] is S = [S11 S12; S12' S22], then the
%   partial correlation matrix of X, controlling for Z, can be defined
%   formally as a normalized version of the covariance matrix
%
%      S_XZ = S11 - S12*inv(S22)*S12'.
%
%   [RHO,PVAL] = PARTIALCORR(...) also returns PVAL, a matrix of p-values for
%   testing the hypothesis of no partial correlation against the alternative
%   that there is a non-zero partial correlation.  Each element of PVAL is the
%   p-value for the corresponding element of RHO.  If PVAL(i,j) is small, say
%   less than 0.05, then the partial correlation RHO(i,j) is significantly
%   different from zero.
%
%   [...] = PARTIALCORR(...,'PARAM1',VAL1,'PARAM2',VAL2,...) specifies
%   additional parameters and their values.  Valid parameters are the
%   following:
%
%        Parameter  Value
%         'type'    'Pearson' (the default) to compute Pearson (linear)
%                   partial correlations or 'Spearman' to compute Spearman
%                   (rank) partial correlations.
%         'rows'    'all' (default) to use all rows regardless of missing
%                   values (NaNs), 'complete' to use only rows with no
%                   missing values, or 'pairwise' to compute RHO(i,j) using
%                   rows with no missing values in column i or j.
%         'tail'    The alternative hypothesis against which to compute
%                   p-values for testing the hypothesis of no partial
%                   correlation.  Choices are:
%                      TAIL         Alternative Hypothesis
%                   ---------------------------------------------------
%                     'both'     correlation is not zero (the default)
%                     'right'    correlation is greater than zero
%                     'left'     correlation is less than zero
%
%   The 'pairwise' option for the 'rows' parameter can produce RHO that is not
%   positive definite.  The 'complete' option always produces a positive
%   definite RHO, but when data are missing, the estimates will in generally
%   be based on fewer observations.
%
%   PARTIALCORR computes p-values for linear and rank partial correlations
%   using a Student's t distribution for a transformation of the correlation.
%   This is exact for linear partial correlation when X and Z are normal, but
%   is a large-sample approximation otherwise.
%
%   See also CORR, CORRCOEF, TIEDRANK.

%   References:
%   (1) Kendall's Advanced Theory of Statistics, Stuart, Ord and Arnold, 6th Ed, 
%       Volume 2A, 2nd Ed, 2004 (Chapter 28).
%   (2) The distribution of the partial correlation coefficient, 
%       Fisher, R.A., Metron, Vol. 3, p. 329-332.

%   Copyright 1984-2014 The MathWorks, Inc.


%   Partial correlation for X, controlling for Z, can be computed by
%   normalizing the full covariance matrix S_XZ = S11 - S12*inv(S22)*S12'.
%   However, PARTIALCORR instead computes it as the correlation of the
%   residuals from a regression of X on Z for linear partial correlation, or
%   from a regression of the ranks of X on the ranks of Z for rank partial
%   correlation.
%
%   An equivalent recursive definition in terms of the individual full
%   and partial correlation coefficients is
%      rxy_z = (rxy - rxz*ryx) / sqrt(1-rxz^2)*(1-ryz^2))
%      rxy_zw = (rxy_z - rxw_z*ryw_z) / sqrt(1-rxw_z^2)*(1-ryw_z^2))
%   etc.

% if ~ismatrix(x) || ~isnumeric(x)
%     error(message('stats:partialcorr:InputsMustBeMatrices'));
% end
[n,d] = size(x);

if ~isempty(varargin) && isnumeric(varargin{1})
    combinedXZ = false;
    % determine if partialcorr(x,z,...) or partialcorr(x,y,z,...)
    if length(varargin) > 1 && isnumeric(varargin{2}) % partialcorr(x,y,z,...)
        % combine separate x and y into a single matrix
        y = varargin{1};
%         if size(x,1)~=size(y,1)
%             error(message('stats:partialcorr:InputSizeMismatch'));
%         elseif ~ismatrix(y) || ~isnumeric(y)
%             error(message('stats:partialcorr:InputsMustBeMatrices'));
%         end
        crossCorr = true;
        dx = size(x,2); dy = size(y,2);
        sizeOut = [dx dy];
        x = [x y];

        z = varargin{2};
        varargin(1:2) = [];
    else % partialcorr(x,z,...)
        crossCorr = false;
        sizeOut = [d d];
        z = varargin{1};
        varargin(1) = [];
    end

%     if ~ismatrix(z) || ~isnumeric(z)
%         error(message('stats:partialcorr:InputsMustBeMatrices'));
%     elseif size(z,1) ~= n
%         error(message('stats:partialcorr:InputSizeMismatch'));
%     end

    outClass = superiorfloat(x,z);
else % partialcorr(x,...)
    combinedXZ = true;
    crossCorr = false;
    sizeOut = [d d];
    
    outClass = superiorfloat(x);
end

% pnames = {'type'  'rows' 'tail'};
% dflts  = {'p'     'a'    'both'};
% [type,rows,tail] = internal.stats.parseArgs(pnames,dflts,varargin{:});
% 
% % Validate the rows parameter.
% rows = internal.stats.getParamVal(rows,{'all' 'complete' 'pairwise'},'''Rows''');
% rows = rows(1);
% 
% % Validate the type parameter.
% try
%     type = internal.stats.getParamVal(type,{'pearson' 'kendall' 'spearman'},'''Type''');
% catch
%     error(message('stats:partialcorr:UnknownType'));
% end
% type = type(1);
% if type == 'k'
%     error(message('stats:partialcorr:Kendall'));
% end

type = 'p'; %'pearson'; %YAN Chao-Gan, 161001. For compatibility of MATLAB 2010.
rows = 'a';
tail = 'both';

% Validate the tail parameter.
tailChoices = {'left','both','right'};
if ischar(tail) && (size(tail,1)==1)
    i = find(strncmpi(tail,tailChoices,length(tail)));
    if isempty(i)
        i = find(strncmpi(tail,{'lt','ne','gt'},length(tail)));
    end
    if isscalar(i)
        tail = tailChoices{i}(1);
    elseif isempty(i)
        error(message('stats:partialcorr:UnknownTail'));
    end
else
    error(message('stats:partialcorr:UnknownTail'));
end

% Turn off rank deficiency warning from backslash, since a basic solution is
% perfectly fine for calculation of residuals.
savedWarnState = warning('off','MATLAB:rankDeficientMatrix');
cleanupObj = onCleanup(@() warning(savedWarnState));

if combinedXZ % 'all', 'complete', and 'pairwise
    % Compute correlations on each pair of columns in X, using X's remaining
    % columns as Z.  Since all columns of X will used for each pairwise
    % correlation, 'pairwise' row removal here is equivalent to 'complete'.
    if any(strcmp(rows,{'c','p'}))
        notnans = ~any(isnan(x),2);
        x = x(notnans,:);
        n = size(x,1);
    end
    % If there are any NaNs or +/-Infs left in x, then all computations
    % to compute partial correlation coefficients would generate NaN 
    % outputs. Thus we can immediately return NaNs.
    if ~all(all(isfinite(x))) 
        coef = NaN(sizeOut);
        if nargout > 1
            pval = coef;
        end
        return
    end
    
    if type == 's'
        x = tiedrank(x);
    end
    
    % 'dz' is the number of degrees of freedom consumed by regressing
    % on the not-i and not-j columns of x. If x is full column rank, then
    % dz is rank(x) -2.  If x is rank-deficient, and either column i
    % or column j is in the span of the remaining columns, the rank
    % of these remaining columns may be rank(x) or rank(x)-1. However,
    % in these cases, the (i,j)-th partial correlation coefficient
    % would be computed as NaN, since either or both of the residuals
    % would be zero.  The p-value, if requested, would be NaN as
    % well.  Thus in all the cases where we are going to compute a 
    % meaningful p-value, so that we care about degrees of freedom,
    % dz = rank(x)-2.
    dz = rank(x)-2;
    
    coef = zeros(sizeOut,outClass);
    for i = 1:d
        % Only do the lower triangle and diagonal.  Do the diagonal just to
        % get NaNs where we need them.
        j0 = 1; j1 = i;
        for j = j0:j1
            xx = x(:,[i j]);
            zz = x(:,setdiff(1:d,[i j]));
            nn = n;
            z1 = [ones(nn,1) zz];
            resid = xx - z1*(z1 \ xx);

            % Some of the X variables might be perfectly predictable from Z,
            % and the residuals should then be zero, but roundoff could throw
            % that off slightly.  If a column of residuals is effectively zero
            % relative to the original variable, then assume we've predicted
            % exactly.  This prevents computing spuriously valid correlations
            % when they really should be NaN.  In particular, on the diagonal
            % the two sets of residuals are always identical, but they may be
            % effectively zero, leading to a NaN instead of a 1.
            tol = max(nn,dz)*eps(class(xx))*sqrt(sum(abs(xx).^2,1));
            resid(:,sqrt(sum(abs(resid).^2,1)) < tol) = 0;

            coef(i,j) = sum(prod(resid,2)) ./ prod(sqrt(sum(abs(resid).^2,1)),2);
        end
    end
    
    % Force a one on the diagonal, but preserve NaNs.
    ii = find(~isnan(diag(coef)));
    coef((ii-1)*d+ii) = 1;

    % Reflect to lower triangle.
    coef = tril(coef) + tril(coef,-1)';
    
elseif any(strcmp(rows,{'a' 'c'})) % 'all' 'complete', except for combinedXZ 
    % Regress X on Z, and compute the correlation of the residuals.  Works
    % even when the full (unconditional) correlation matrix of [X Z] would be
    % indefinite due to pairwise missing data removal.
    if rows == 'c'
        notnans = ~any(isnan(x),2) & ~any(isnan(z),2);
        x = x(notnans,:);
        z = z(notnans,:);
        n = size(x,1);
    end
    
    % If there are any NaNs or +/-Infs left in z, then all computations
    % to compute partial correlation coefficients would generate NaN outputs.
    % Thus we can immediately return NaNs.
    if ~all(all(isfinite(z)))
        coef = NaN(sizeOut);
        if nargout > 1
            pval = coef;
        end
        return
    end

    if type == 's'
        x = tiedrank(x);
        z = tiedrank(z);
    end
    % 'dz' is the number of degrees of freedom consumed by regressing
    % on z.
    dz = rank(z);

    z1 = [ones(n,1) z];
    resid = x - z1*(z1 \ x);

    % See corresponding comment in previous case
    tol = max(n,dz)*eps(class(x))*sqrt(sum(abs(x).^2,1));
    resid(:,sqrt(sum(abs(resid).^2,1)) < tol) = 0;
    
    if crossCorr
        coef = corr(resid(:,1:dx),resid(:,dx+1:dx+dy),'type','pearson');
    else
        coef = corr(resid,'type','pearson');
    end
    
else % 'pairwise', except for combinedXZ
    % Compute correlations on each pair of columns in X, with pairwise
    % row removal.
    znotnans = ~any(isnan(z),2);
    x = x(znotnans,:);
    z = z(znotnans,:);
    
    % Below, z may have rows stripped because of NaNs in the x or y
    % input matrices (now combined, if y was supplied, in variable x).
    % Thus the rank of z may vary across pairings of x_i and y_j.
    % However, for pairings which introduce no row removals, z retains
    % its full rank, which is also the number of degrees of freedom
    % consumed by regressing on z.  We save that value here so that 
    % we don't need to recalcuate it below.
    if type == 's'
        baserankZ = rank(tiedrank(z));
    else
        baserankZ = rank(z);
    end
    coef = zeros(sizeOut,outClass);
    if crossCorr
        n = zeros(sizeOut(1),dx+dy);
        dz = baserankZ * ones(sizeOut(1),dx+dy,outClass);
    else
        n = zeros(sizeOut);
        dz = baserankZ * ones(sizeOut,outClass);
    end
    
    isnanx = isnan(x);
    for i = 1:d
        % For cross correlation, only do the x:y cross terms.  For
        % autocorrelation, do the lower triangle and diagonal.  Do the
        % diagonal just to get NaNs where we need them.
        if crossCorr
            j0 = dx+1; j1 = dx+dy;
        else
            j0 = 1; j1 = i;
        end
        for j = j0:j1
            notnans = ~(isnanx(:,i) | isnanx(:,j));
            xx = x(notnans,[i j]);
            zz = z(notnans,:);
            nn = size(xx,1);
            if type == 's'
                xx = tiedrank(xx);
                zz = tiedrank(zz);
            end
            z1 = [ones(nn,1) zz];
            resid = xx - z1*(z1 \ xx);
            
            % See corresponding comment in previous case
            tol = max(nn,baserankZ)*eps(class(xx))*sqrt(sum(abs(xx).^2,1));
            resid(:,sqrt(sum(abs(resid).^2,1)) < tol) = 0;

            coef(i,j) = sum(prod(resid,2)) ./ prod(sqrt(sum(abs(resid).^2,1)),2);
            n(i,j) = nn;
            
            % If there were row deletions because of missing values
            % (NaNs) in x or y, and if we calculated a finite
            % partial correlation coefficient, and if p-values
            % were requested, we calculate the rank of z, subject to
            % the row deletions.  The rank computation was delayed until
            % now to avoid the unnecessary cost when it would not be used.
            if nargout>1 && ~isnan(coef(i,j)) && ~all(notnans)
                dz(i,j) = rank(zz);
            end
        end
    end
    
    if ~crossCorr
        % Force a one on the diagonal, but preserve NaNs.
        ii = find(~isnan(diag(coef)));
        coef((ii-1)*d+ii) = 1;
        
        % Reflect to lower triangle.
        coef = tril(coef) + tril(coef,-1)';
        n = tril(n) + tril(n,-1)';
    else
        % Keep only the x:y cross term elements.
        coef = coef(1:dx,dx+1:dx+dy);
        n = n(1:dx,dx+1:dx+dy);
        dz = dz(1:dx,dx+1:dx+dy);
    end
    
end

if nargout > 1
    df = max(n - dz - 2,0); % this is a matrix for 'pairwise'
    t = sign(coef) .* Inf;
    k = (abs(coef) < 1);
    t(k) = coef(k) ./ sqrt(1-coef(k).^2);
    t = sqrt(df).*t;
    switch tail
    case 'b' % 'both or 'ne'
        pval = 2*tcdf(-abs(t),df);
    case 'r' % 'right' or 'gt'
        pval = tcdf(-t,df);
    case 'l' % 'left or 'lt'
        pval = tcdf(t,df);
    end
end

