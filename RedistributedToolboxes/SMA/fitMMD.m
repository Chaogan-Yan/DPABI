function[slope,intercept] = fitMMD(datasource,datatarget,calpvalue)
%% function[slope,intercept,pvalue] = fitMMD(datasource,datatarget,calpvalue)
%% Inputs: datasource and datatarget are related to the one dimension measurement of interest; if calpvalue=1, return pvalue, else, return 2.
%% Outputs: slope, intercept for the transformation and pvalue. 
%% This function depends on an open source code manopt for optimization.
%% Optimization_fun provides objective function and gradient function.
%% Hypothesis_testing is required for the hypothesis testing.
global Xsource Xtarget XA bA XB sigma2 transXA
Xsource = datasource;
Xtarget = datatarget;

%% Optimization is nonconvex, this three iterations help to find a good solution.
Max_iter = 3;
Max_intercept_iter = 3;
Max_slope_iter = 6;

Matdist=dist2(Xtarget,Xtarget);
sigma2=median(Matdist(Matdist~=0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Optimization %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The initial of slope and intercept.
slope = std(Xtarget)/std(Xsource);
intercept = mean(Xtarget)-std(Xtarget)/std(Xsource)*mean(Xsource); 

for total_iter = 1:Max_iter 
    %% Optimize intercept.
    XB = Xtarget;
    if Max_intercept_iter>0
        transXA = Xsource*slope;
        problem.M = euclideanfactory(1,1);
        problem.cost = @Fintercept;
        problem.egrad = @dFintercept;
        options.maxiter = Max_intercept_iter;
        options.verbosity = 0;
        intercept = conjugategradient(problem,intercept,options);  
    end

    %% Optimize slope.
    XA = Xsource; bA = intercept;   
    problem.M = euclideanfactory(1,1);
    problem.cost = @F;
    problem.egrad = @dF;
    options.maxiter = Max_slope_iter;
    options.verbosity = 0;
    slope = conjugategradient(problem,slope,options); %It can be replaced by steepestdescent%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hypothesis testing %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bootstrap testing.
%%pvalue = 2;
%%if calpvalue
%%    fvalue = F(slope);
%%    n2 = size(Xtarget,1);
%%    n1 = size(Xsource,1);
%%    shufflepos = randi(n2,[1,n1+n2]);%get n1+n2 samples from 1:n2 n2 is bigger than n1, otherwise bootY will get n1 sample from target,who only has n2 samples
%%    bootX = Xtarget(shufflepos(1:n2),:);
%%    bootY = Xtarget(shufflepos((n2+1):(n2+n1)),:);
%%    shufflenum = 1000;
%%    pvalue = mmdTestBoot(bootX,bootY,shufflenum,fvalue);
%%end


