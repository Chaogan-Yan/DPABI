function [b,r,SSE,SSR, T, TF_ForContrast] = y_regress_ss(y,X,Contrast,TF_Flag)
% [b,r,SSE,SSR, T, TF_ForContrast] = y_regress_ss(y,X,Contrast,TF_Flag)
% Perform regression.
% Revised from MATLAB's regress in order to speed up the calculation.
% Input:
%   y - Independent variable.
%   X - Dependent variable.
%   Contrast [optional] - Contrast for T-test for F-test. 1*ncolX matrix.
%   TF_Flag [optional] - 'T' or 'F'. Specify if T-test or F-test need to be performed for the contrast
% Output:
%   b - beta of regression model.
%   r - residual.
%   SSE - The sum of squares of error.
%   SSR - The sum of squares of regression.
%   T - T value for each beta.
%   TF_ForContrast - T or F value (depends on TF_Flag) for the contrast.
%   
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962; 
% Child Mind Institute, 445 Park Avenue, New York, NY 10022; 
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 120519. Also output T value for each beta. Referenced from regstats.m
% Revised by YAN Chao-Gan 121220. Also support T-test or F-test for a given contrast.

[n,ncolX] = size(X);
[Q,R,perm] = qr(X,0);
p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)));
if p < ncolX,
    R = R(1:p,1:p);
    Q = Q(:,1:p);
    perm = perm(1:p);
end
b = zeros(ncolX,1);
b(perm) = R \ (Q'*y);

if nargout >= 2
    yhat = X*b;                     % Predicted responses at each data point.
    r = y-yhat;                     % Residuals.
    if nargout >= 3
        SSE=sum(r.^2);
        if nargout >= 4
            SSR=sum((yhat-mean(y)).^2);
            
            if nargout >= 5
                %Also output T value for each beta. Referenced from regstats.m
                [Q,R] = qr(X,0);
                ri = R\eye(ncolX);
                T = b./sqrt(diag(ri*ri' * (SSE/(n-ncolX))));
                
                if nargout >= 6
                    %YAN Chao-Gan 121220. Also support T-test or F-test for a given contrast.
                    % Have contrast
                    if strcmpi(TF_Flag,'T')
                        std_e = sqrt(SSE/(n-ncolX));        % Standard deviation of the noise
                        d = sqrt(Contrast*(X'*X)^(-1)*Contrast');
                        TF_ForContrast = (Contrast*b)./(std_e*d);           % T-test
                        
                    elseif strcmpi(TF_Flag,'F')
                        X0 = X(:,~Contrast);
                        ncolX0 = size(X0,2);
                        if ncolX0>0
                            b0 = (X0'*X0)^(-1)*X0'*y; % Regression coefficients (restricted model)
                            r0 = y-X0*b0;
                            SSE0 = sum(r0.^2); % Estimate of the residual sum-of-square of the restricted model (SSE0)
                        else
                            SSE0 = sum(y.^2,1);
                        end
                        TF_ForContrast = ((SSE0-SSE)/(ncolX-ncolX0))./(SSE/(n-ncolX)); % F-Test
                        
                    end
                end
                
            end
            
        end
    end
end
