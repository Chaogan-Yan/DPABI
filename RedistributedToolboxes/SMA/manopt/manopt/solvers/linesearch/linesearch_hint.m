function [stepsize, newx, newkey, lsstats] = ...
             linesearch_hint(problem, x, d, f0, df0, options, storedb, key)
% Armijo line-search based on the line-search hint in the problem structure.
%
% function [stepsize, newx, newkey, lsstats] = 
%            linesearch_hint(problem, x, d, f0, df0, options, storedb, key)
%
% Base line-search algorithm for descent methods, based on a simple
% backtracking method. The search direction provided has to be a descent
% direction, as indicated by a negative df0 = directional derivative of f
% at x along d.
%
% The algorithm obtains an initial step size candidate from the problem
% structure, typically through the problem.linesearch function. If that
% step does not fulfill the Armijo sufficient decrease criterion, that step
% size is reduced geometrically until a satisfactory step size is obtained
% or until a failure criterion triggers. If the problem structure does not
% provide an initial alpha, then alpha = 1 is tried first.
% 
% Below, the step is constructed as alpha*d, and the step size is the norm
% of that vector, thus: stepsize = alpha*norm_d. The step is executed by
% retracting the vector alpha*d from the current point x, giving newx.
%
% Inputs/Outputs : see help for linesearch
%
% See also: steepestdescent conjugategradients linesearch

% This file is part of Manopt: www.manopt.org.
% Original author: Nicolas Boumal, July 17, 2014.
% Contributors: 
% Change log: 
%
%   April 3, 2015 (NB):
%       Works with the new StoreDB class system.
%
%   April 8, 2015 (NB):
%       Got rid of lsmem input/output.
%
%   July 20, 2017 (NB):
%       Now using alpha = 1 by default.
%
%   Aug. 28, 2017 (NB):
%       Adding two options: ls_backtrack and ls_force_decrease, both true
%       by default. Setting them to false can disable parts of the line
%       search that, respectively, execute an Armijo backtracking and
%       reject a cost increasing step.


    % Allow omission of the key, and even of storedb.
    if ~exist('key', 'var')
        if ~exist('storedb', 'var')
            storedb = StoreDB();
        end
        key = storedb.getNewKey();
    end

    % Backtracking default parameters. These can be overwritten in the
    % options structure which is passed to the solver.
    default_options.ls_contraction_factor = .5;
    default_options.ls_suff_decr = 1e-4;
    default_options.ls_max_steps = 25;
    default_options.ls_backtrack = true;
    default_options.ls_force_decrease = true;
    
    if ~exist('options', 'var') || isempty(options)
        options = struct();
    end
    options = mergeOptions(default_options, options);
    
    contraction_factor = options.ls_contraction_factor;
    suff_decr = options.ls_suff_decr;
    max_ls_steps = options.ls_max_steps;
    
    % Obtain an initial guess at alpha from the problem structure. It is
    % assumed that the present line-search is only called when the problem
    % structure provides enough information for the call here to work.
    if canGetLinesearch(problem)
        alpha = getLinesearch(problem, x, d, storedb, key);
    else
        alpha = 1;
    end
    
    % Make the chosen step and compute the cost there.
    newx = problem.M.retr(x, d, alpha);
    newkey = storedb.getNewKey();
    newf = getCost(problem, newx, storedb, newkey);
    cost_evaluations = 1;
    
    % Backtrack while the Armijo criterion is not satisfied
    while options.ls_backtrack && newf > f0 + suff_decr*alpha*df0
        
        % Reduce the step size,
        alpha = contraction_factor * alpha;
        
        % and look closer down the line
        newx = problem.M.retr(x, d, alpha);
        newkey = storedb.getNewKey();
        newf = getCost(problem, newx, storedb, newkey);
        cost_evaluations = cost_evaluations + 1;
        
        % Make sure we don't run out of budget
        if cost_evaluations >= max_ls_steps
            break;
        end
        
    end
    
    % If we got here without obtaining a decrease, we reject the step.
    if options.ls_force_decrease && newf > f0
        alpha = 0;
        newx = x;
        newkey = key;
        newf = f0; %#ok<NASGU>
    end
    
    % As seen outside this function, stepsize is the size of the vector we
    % retract to make the step from x to newx. Since the step is alpha*d:
    norm_d = problem.M.norm(x, d);
    stepsize = alpha * norm_d;
    
    % Return some statistics also, for possible analysis.
    lsstats.costevals = cost_evaluations;
    lsstats.stepsize = stepsize;
    lsstats.alpha = alpha;
    
end
