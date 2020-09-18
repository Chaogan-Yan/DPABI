function palm_plot(Y,X,I,Z,res,F,opt)
% Take a vector of data, a design, a constrast, then
% plots. If the code detects that what the contrasts
% is testing is an interaction, it constructs
% interaction plots.
%
% Usage:
%
% palm_plot(data,design,contrast,res,F,opt)
%
% - Y        : Data.
% - X        : Main effects (up to 3 colums, of which
%              no more than 2 can be continuous.
% - I        : The interaction term, 1 column. Leave
%              empty or NaN if not an interaction.
% - Z        : Nuisance. It should not include the
%              interaction that is to be plotted,
%              otherwise the effect of the interaction
%              is washed out.
% - res      : Resolution of meshes (for 2-way
%              interactions between continuous
%              variables).
% - F        : (Optional) A struct with fields 'title',
%              'xlabel', 'ylabel' and 'zlabel', to be
%              applied to the plot.
% - opt      : (Optional) Use 'poly22' for a curvy plot
%              (it won't match the GLM, so don't use).
%
% _____________________________________
% Anderson M. Winkler
% National Institutes of Health
% Nov/2018
% http://brainder.org

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% PALM -- Permutation Analysis of Linear Models
% Copyright (C) 2015 Anderson M. Winkler
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Check sanity of inputs
if size(Y,2) > 1
    error('Input data must have just 1 column.');
end
if size(I,2) ~= 1
    error('The interaction term must have just 1 column.');
end
if size(X,2) < 1 || size(X,2) > 3
    error('Input data must have between 1 and 3 columns (inclusive).');
end
if      size(Y,1) ~= size(X,1) || ...
        size(Y,1) ~= size(Z,1) || ...
        size(Y,1) ~= size(I,1)
    error('Input variables must all have the same number of rows.');
else
    N = size(Y,1);
end
if exist('F','var') && ~isstruct(F) && ~isempty(F) && ~isnan(F)
    error('F must be a struct.')
end

% Model fitting
b = [I X Z]\Y;

% Residual forming matrix without interaction and without main effects
Rz = eye(N) - Z*pinv(Z);
J = size(X,2);
switch J
    
    case 1
        % This is not an interaction
        figure
        scatter(Rz*X,Rz*Y);
        if exist('F','var') && isstruct(F)
            title(F.title);
            xlabel(F.xlabel);
            ylabel(F.ylabel);
        end
        
    case 2
        % This is an interaction of 2 variables
        rY = Rz*Y;
        A = X(:,1);
        B = X(:,2);
        uA = unique(A);
        uB = unique(B);
        if     numel(uA) == 2 && numel(uB)  > 2
            % If A has 2 categories and B is continuous
            rB = Rz*B;
            figure
            for u = 1:numel(uA)
                idx = A == uA(u);
                scatter(rB(idx),rY(idx),'.');
                hold('on')
            end
            hold('off');
            if exist('F','var') && isstruct(F)
                title(F.title);
                xlabel(F.xlabel);
                ylabel(F.ylabel);
            end
            
        elseif numel(uA)  > 2 && numel(uB) == 2
            % If A is continuous and B has 2 categories
            rA = Rz*A;
            figure
            for u = 1:numel(uB)
                idx = B == uB(u);
                scatter(rA(idx),rY(idx),'.');
                hold('on')
            end
            hold('off');
            if exist('F','var') && isstruct(F)
                title(F.title);
                xlabel(F.xlabel);
                ylabel(F.ylabel);
            end
            
        elseif numel(uA) == 2 && numel(uB) == 2
            % If both A and B have 2 categories
            X = zeros(2,2);
            for ua = 1:numel(uA)
                for ub = 1:numel(uB)
                    idx = A == uA(ua) & B == uB(ub);
                    X(ua,ub) = mean(rY(idx));
                end
            end
            figure
            bar(X);
            if exist('F','var') && isstruct(F)
                title(F.title);
                xlabel(F.xlabel);
                ylabel(F.ylabel);
            end
            
        else
            % if A and B are continuous
            rA = Rz*A;
            rB = Rz*B;
            figure
            if isnumeric(opt)
                [xg,yg] = meshgrid(linspace(min(rA),max(rA),res),linspace(min(rB),max(rB),res));
                mesh(xg,yg,xg.*yg*b(1)*opt);
                hold('on')
                scatter3(rA,rB,rY,'.');
            elseif ischar(opt) && strcmpi(opt,'poly22')
                surfit = fit([rA rB],rY,'poly22');
                plot(surfit,[rA,rB],rY);
            end
            if exist('F','var') && isstruct(F)
                title(F.title);
                xlabel(F.xlabel);
                ylabel(F.ylabel);
                zlabel(F.zlabel);
            end
            hold('off')
        end
    case 3
        % This is an interaction of 3 variables
        U  = cell(J,1);
        nU = zeros(J,1);
        for j = 1:J
            U{j}  = unique(X(:,j));
            nU(j) = numel(U{j});
        end
        idxU = find(nU == 2,1,'last');
        C = X(:,idxU);
        X(:,idxU) = [];
        U = U{idxU};
        for u = 1:numel(U)
            if isnumeric(opt)
                optu = sign(U(u));
            else
                optu = opt;
            end
            Yu = Y(C == U(u),:);
            Iu = I(C == U(u),:);
            Xu = X(C == U(u),:);
            Xu(:,any(abs(corr(Iu,Xu)) > 1-10*eps,1)) = [];
            Zu = Z(C == U(u),:);
            Zu(:,any(abs(corr([Iu Xu],Zu)) > 1-10*eps,1)) = [];
            Zu(:,any(triu(abs(corr(Zu)))-eye(size(Zu,2)) > 1-10*eps,2)) = [];
            palm_plot(Yu,Iu,Xu,Zu,res,F,optu);
        end
end
