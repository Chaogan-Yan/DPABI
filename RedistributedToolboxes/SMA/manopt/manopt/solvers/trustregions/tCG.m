function [eta, Heta, inner_it, stop_tCG] ...
                 = tCG(problem, x, grad, eta, Delta, options, storedb, key)
% tCG - Truncated (Steihaug-Toint) Conjugate-Gradient method
% minimize <eta,grad> + .5*<eta,Hess(eta)>
% subject to <eta,eta>_[inverse precon] <= Delta^2
%
% See also: trustregions

% This file is part of Manopt: www.manopt.org.
% This code is an adaptation to Manopt of the original GenRTR code:
% RTR - Riemannian Trust-Region
% (c) 2004-2007, P.-A. Absil, C. G. Baker, K. A. Gallivan
% Florida State University
% School of Computational Science
% (http://www.math.fsu.edu/~cbaker/GenRTR/?page=download)
% See accompanying license file.
% The adaptation was executed by Nicolas Boumal.
%
% Change log:
%
%   NB Feb. 12, 2013:
%       We do not project r back to the tangent space anymore: it was not
%       necessary, and as of Manopt 1.0.1, the proj operator does not
%       coincide with this notion anymore.
%
%   NB April 3, 2013:
%       tCG now also returns Heta, the Hessian at x along eta. Additional
%       esthetic modifications.
%
%   NB Dec. 2, 2013:
%       If options.useRand is activated, we now make sure the preconditio-
%       ner is not used, as was originally intended in GenRTR. In time, we
%       may want to investigate whether useRand can be modifed to work well
%       with preconditioning too.
%
%   NB Jan. 9, 2014:
%       Now checking explicitly for model decrease at each iteration. The
%       first iteration is a Cauchy point, which necessarily realizes a
%       decrease of the model cost. If a model increase is witnessed
%       (which is theoretically impossible if a linear operator is used for
%       the Hessian approximation), then we return the previous eta. This
%       ensures we always achieve at least the Cauchy decrease, which
%       should be sufficient for convergence.
%
%   NB Feb. 17, 2015:
%       The previous update was in effect verifying that the current eta
%       performed at least as well as the first eta (the Cauchy step) with
%       respect to the model cost. While this is an acceptable strategy,
%       the documentation (and the original intent) was to ensure a
%       monotonic decrease of the model cost at each new eta. This is now
%       the case, with the added line: "model_value = new_model_value;".
%
%   NB April 3, 2015:
%       Works with the new StoreDB class system.


% All terms involving the trust-region radius will use an inner product
% w.r.t. the preconditioner; this is because the iterates grow in
% length w.r.t. the preconditioner, guaranteeing that we will not
% re-enter the trust-region.
%
% The following recurrences for Prec-based norms and inner
% products come from [CGT2000], pg. 205, first edition.
% Below, P is the preconditioner.
%
% <eta_k,P*delta_k> = 
%          beta_k-1 * ( <eta_k-1,P*delta_k-1> + alpha_k-1 |delta_k-1|^2_P )
% |delta_k|^2_P = <r_k,z_k> + beta_k-1^2 |delta_k-1|^2_P
%
% therefore, we need to keep track of
% 1)   |delta_k|^2_P
% 2)   <eta_k,P*delta_k> = <eta_k,delta_k>_P
% 3)   |eta_k  |^2_P
%
% initial values are given by:
%    |delta_0|_P = <r,z>
%    |eta_0|_P   = 0
%    <eta_0,delta_0>_P = 0
% because we take eta_0 = 0 (if useRand = false).
%
% [CGT2000] Conn, Gould and Toint: Trust-region methods, 2000.

inner = problem.M.inner;
lincomb = problem.M.lincomb;

theta = options.theta;
kappa = options.kappa;

if ~options.useRand % and therefore, eta == 0
    Heta = problem.M.zerovec(x);
    r = grad;
    e_Pe = 0;
else % and therefore, no preconditioner
    % eta (presumably) ~= 0 was provided by the caller.
    Heta = getHessian(problem, x, eta, storedb, key);
    r = lincomb(x, 1, grad, 1, Heta);
    e_Pe = inner(x, eta, eta);
end
r_r = inner(x, r, r);
norm_r = sqrt(r_r);
norm_r0 = norm_r;

% Precondition the residual.
if ~options.useRand
    z = getPrecon(problem, x, r, storedb, key);
else
    z = r;
end

% Compute z'*r.
z_r = inner(x, z, r);
d_Pd = z_r;

% Initial search direction.
delta  = lincomb(x, -1, z);
if ~options.useRand % and therefore, eta == 0
    e_Pd = 0;
else % and therefore, no preconditioner
    e_Pd = inner(x, eta, delta);
end

% If the Hessian or a linear Hessian approximation is in use, it is
% theoretically guaranteed that the model value decreases strictly
% with each iteration of tCG. Hence, there is no need to monitor the model
% value. But, when a nonlinear Hessian approximation is used (such as the
% built-in finite-difference approximation for example), the model may
% increase. It is then important to terminate the tCG iterations and return
% the previous (the best-so-far) iterate. The variable below will hold the
% model value.
model_fun = @(eta, Heta) inner(x, eta, grad) + .5*inner(x, eta, Heta);
if ~options.useRand
    model_value = 0;
else
    model_value = model_fun(eta, Heta);
end

% Pre-assume termination because j == end.
stop_tCG = 5;

% Begin inner/tCG loop.
j = 0;
for j = 1 : options.maxinner
    
    % This call is the computationally expensive step.
    Hdelta = getHessian(problem, x, delta, storedb, key);
    
    % Compute curvature (often called kappa).
    d_Hd = inner(x, delta, Hdelta);
    
    
    % Note that if d_Hd == 0, we will exit at the next "if" anyway.
    alpha = z_r/d_Hd;
    % <neweta,neweta>_P =
    % <eta,eta>_P + 2*alpha*<eta,delta>_P + alpha*alpha*<delta,delta>_P
    e_Pe_new = e_Pe + 2.0*alpha*e_Pd + alpha*alpha*d_Pd;
    
    if options.debug > 2,
        fprintf('DBG:   (r,r)  : %e\n', r_r);
        fprintf('DBG:   (d,Hd) : %e\n', d_Hd);
        fprintf('DBG:   alpha  : %e\n', alpha);
    end
    
    % Check against negative curvature and trust-region radius violation.
    % If either condition triggers, we bail out.
    if d_Hd <= 0 || e_Pe_new >= Delta^2,
        % want
        %  ee = <eta,eta>_prec,x
        %  ed = <eta,delta>_prec,x
        %  dd = <delta,delta>_prec,x
        tau = (-e_Pd + sqrt(e_Pd*e_Pd + d_Pd*(Delta^2-e_Pe))) / d_Pd;
        if options.debug > 2,
            fprintf('DBG:     tau  : %e\n', tau);
        end
        eta  = lincomb(x, 1,  eta, tau,  delta);
        
        % If only a nonlinear Hessian approximation is available, this is
        % only approximately correct, but saves an additional Hessian call.
        Heta = lincomb(x, 1, Heta, tau, Hdelta);
        
        % Technically, we may want to verify that this new eta is indeed
        % better than the previous eta before returning it (this is always
        % the case if the Hessian approximation is linear, but I am unsure
        % whether it is the case or not for nonlinear approximations.)
        % At any rate, the impact should be limited, so in the interest of
        % code conciseness (if we can still hope for that), we omit this.
        
        if d_Hd <= 0,
            stop_tCG = 1;     % negative curvature
        else
            stop_tCG = 2;     % exceeded trust region
        end
        break;
    end
    
    % No negative curvature and eta_prop inside TR: accept it.
    e_Pe = e_Pe_new;
    new_eta  = lincomb(x, 1,  eta, alpha,  delta);
    
    % If only a nonlinear Hessian approximation is available, this is
    % only approximately correct, but saves an additional Hessian call.
    new_Heta = lincomb(x, 1, Heta, alpha, Hdelta);
    
    % Verify that the model cost decreased in going from eta to new_eta. If
    % it did not (which can only occur if the Hessian approximation is
    % nonlinear or because of numerical errors), then we return the
    % previous eta (which necessarily is the best reached so far, according
    % to the model cost). Otherwise, we accept the new eta and go on.
    new_model_value = model_fun(new_eta, new_Heta);
    if new_model_value >= model_value
        stop_tCG = 6;
        break;
    end
    
    eta = new_eta;
    Heta = new_Heta;
    model_value = new_model_value; %% added Feb. 17, 2015
    
    % Update the residual.
    r = lincomb(x, 1, r, alpha, Hdelta);
    
    % Compute new norm of r.
    r_r = inner(x, r, r);
    norm_r = sqrt(r_r);
    
    % Check kappa/theta stopping criterion.
    % Note that it is somewhat arbitrary whether to check this stopping
    % criterion on the r's (the gradients) or on the z's (the
    % preconditioned gradients). [CGT2000], page 206, mentions both as
    % acceptable criteria.
    if j >= options.mininner && norm_r <= norm_r0*min(norm_r0^theta, kappa)
        % Residual is small enough to quit
        if kappa < norm_r0^theta,
            stop_tCG = 3;  % linear convergence
        else
            stop_tCG = 4;  % superlinear convergence
        end
        break;
    end
    
    % Precondition the residual.
    if ~options.useRand
        z = getPrecon(problem, x, r, storedb, key);
    else
        z = r;
    end
    
    % Save the old z'*r.
    zold_rold = z_r;
    % Compute new z'*r.
    z_r = inner(x, z, r);
    
    % Compute new search direction.
    beta = z_r/zold_rold;
    delta = lincomb(x, -1, z, beta, delta);
    
    % Update new P-norms and P-dots [CGT2000, eq. 7.5.6 & 7.5.7].
    e_Pd = beta*(e_Pd + alpha*d_Pd);
    d_Pd = z_r + beta*beta*d_Pd;
    
end  % of tCG loop
inner_it = j;

end
