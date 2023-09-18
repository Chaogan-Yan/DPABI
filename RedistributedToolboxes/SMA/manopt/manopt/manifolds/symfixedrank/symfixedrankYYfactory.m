function M = symfixedrankYYfactory(n, k)
% Manifold of n-by-n symmetric positive semidefinite matrices of rank k.
%
% function M = symfixedrankYYfactory(n, k)
%
% A point X on the manifold is parameterized as YY^T where Y is a matrix of
% size nxk. As such, X is symmetric, positive semidefinite. We restrict to
% full-rank Y's, such that X has rank exactly k. The point X is numerically
% represented by Y (this is more efficient than working with X, which may
% be big). Tangent vectors are represented as matrices of the same size as
% Y, call them Ydot, so that Xdot = Y Ydot' + Ydot Y. The metric is the
% canonical Euclidean metric on Y.
% 
% Since for any orthogonal Q of size k, it holds that (YQ)(YQ)' = YY',
% we "group" all matrices of the form YQ in an equivalence class. The set
% of equivalence classes is a Riemannian quotient manifold, implemented
% here.
%
% Notice that this manifold is not complete: if optimization leads Y to be
% rank-deficient, the geometry will break down. Hence, this geometry should
% only be used if it is expected that the points of interest will have rank
% exactly k. Reduce k if that is not the case.
% 
% An alternative, complete, geometry for positive semidefinite matrices of
% rank k is described in Bonnabel and Sepulchre 2009, "Riemannian Metric
% and Geometric Mean for Positive Semidefinite Matrices of Fixed Rank",
% SIAM Journal on Matrix Analysis and Applications.
%
%
% The geometry here implemented is the simplest case of the 2010 paper:
% M. Journee, P.-A. Absil, F. Bach and R. Sepulchre,
% "Low-Rank Optimization on the Cone of Positive Semidefinite Matrices".
% Paper link: http://www.di.ens.fr/~fbach/journee2010_sdp.pdf
% 
% 
% Please cite the Manopt paper as well as the research paper:
%     @Article{journee2010low,
%       Title   = {Low-rank optimization on the cone of positive semidefinite matrices},
%       Author  = {Journ{\'e}e, M. and Bach, F. and Absil, P.-A. and Sepulchre, R.},
%       Journal = {SIAM Journal on Optimization},
%       Year    = {2010},
%       Number  = {5},
%       Pages   = {2327--2351},
%       Volume  = {20},
%       Doi     = {10.1137/080731359}
%     }
%
% See also: elliptopefactory spectrahedronfactory

% This file is part of Manopt: www.manopt.org.
% Original author: Bamdev Mishra, Dec. 30, 2012.
% Contributors:
% Change log:
%
%  July 10, 2013 (NB):
%       Added vec, mat, tangent, tangent2ambient ;
%       Correction for the dimension of the manifold.
%
%   April 2, 2015 (NB):
%       Replaced trace(A'*B) by A(:)'*B(:) (equivalent but faster).


	M.name = @() sprintf('YY'' quotient manifold of %dx%d psd matrices of rank %d', n, k);

	M.dim = @() k*n - k*(k-1)/2;

	% Euclidean metric on the total space
	M.inner = @(Y, eta, zeta) eta(:)'*zeta(:);

	M.norm = @(Y, eta) sqrt(M.inner(Y, eta, eta));

	M.dist = @(Y, Z) error('symfixedrankYYfactory.dist not implemented yet.');

	M.typicaldist = @() 10*k;

	M.proj = @projection;
	function etaproj = projection(Y, eta)
		% Projection onto the horizontal space
		YtY = Y'*Y;
		SS = YtY;
		AS = Y'*eta - eta'*Y;
		Omega = lyap(SS, -AS);
		etaproj = eta - Y*Omega;
	end

	M.tangent = M.proj;
	M.tangent2ambient = @(Y, eta) eta;

	M.retr = @retraction;
	function Ynew = retraction(Y, eta, t)
		if nargin < 3
			t = 1.0;
		end
		Ynew = Y + t*eta;
	end


	M.egrad2rgrad = @(Y, eta) eta;
	M.ehess2rhess = @(Y, egrad, ehess, U) M.proj(Y, ehess);

	M.exp = @exponential;
	function Ynew = exponential(Y, eta, t)
		if nargin < 3
			t = 1.0;
		end
		
		Ynew = retraction(Y, eta, t);
		warning('manopt:symfixedrankYYfactory:exp', ...
			['Exponential for symmetric, fixed-rank ' ...
			'manifold not implemented yet. Used retraction instead.']);
	end

	% Notice that the hash of two equivalent points will be different...
	M.hash = @(Y) ['z' hashmd5(Y(:))];

	M.rand = @random;
	function Y = random()
		Y = randn(n, k);
	end

	M.randvec = @randomvec;
	function eta = randomvec(Y)
		eta = randn(n, k);
		eta = projection(Y, eta);
		nrm = M.norm(Y, eta);
		eta = eta / nrm;
	end

	M.lincomb = @matrixlincomb;

	M.zerovec = @(Y) zeros(n, k);

	M.transp = @(Y1, Y2, d) projection(Y2, d);
		
	M.vec = @(Y, u_mat) u_mat(:);
	M.mat = @(Y, u_vec) reshape(u_vec, [n, k]);
	M.vecmatareisometries = @() true;

end
