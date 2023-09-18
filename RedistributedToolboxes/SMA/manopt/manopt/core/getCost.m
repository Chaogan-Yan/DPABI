function cost = getCost(problem, x, storedb, key)
% Computes the cost function at x.
%
% function cost = getCost(problem, x)
% function cost = getCost(problem, x, storedb)
% function cost = getCost(problem, x, storedb, key)
%
% Returns the value at x of the cost function described in the problem
% structure.
%
% storedb is a StoreDB object, key is the StoreDB key to point x.
%
% See also: canGetCost

% This file is part of Manopt: www.manopt.org.
% Original author: Nicolas Boumal, Dec. 30, 2012.
% Contributors: 
% Change log: 
%
%   April 3, 2015 (NB):
%       Works with the new StoreDB class system.

    % Allow omission of the key, and even of storedb.
    if ~exist('key', 'var')
        if ~exist('storedb', 'var')
            storedb = StoreDB();
        end
        key = storedb.getNewKey();
    end


    if isfield(problem, 'cost')
    %% Compute the cost function using cost.
	
        % Check whether this function wants to deal with storedb or not.
        switch nargin(problem.cost)
            case 1
                cost = problem.cost(x);
            case 2
                % Obtain, pass along, and save the store for x.
                store = storedb.getWithShared(key);
                [cost, store] = problem.cost(x, store);
                storedb.setWithShared(store, key);
            case 3
                % Pass along the whole storedb (by reference), with key.
                cost = problem.cost(x, storedb, key);
            otherwise
                up = MException('manopt:getCost:badcost', ...
                    'cost should accept 1, 2 or 3 inputs.');
                throw(up);
        end
        
    elseif isfield(problem, 'costgrad')
    %% Compute the cost function using costgrad.
	
        % Check whether this function wants to deal with storedb or not.
        switch nargin(problem.costgrad)
            case 1
                cost = problem.costgrad(x);
            case 2
                % Obtain, pass along, and save the store for x.
                store = storedb.getWithShared(key);
                [cost, grad, store] = problem.costgrad(x, store); %#ok
                storedb.setWithShared(store, key);
            case 3
                % Pass along the whole storedb (by reference), with key.
                cost = problem.costgrad(x, storedb, key);
            otherwise
                up = MException('manopt:getCost:badcostgrad', ...
                    'costgrad should accept 1, 2 or 3 inputs.');
                throw(up);
        end

    else
    %% Abandon computing the cost function.

        up = MException('manopt:getCost:fail', ...
            ['The problem description is not explicit enough to ' ...
             'compute the cost.']);
        throw(up);
        
    end
    
end
