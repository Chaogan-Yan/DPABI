
function bayesdata = yw_covbat(dat, batch, mod, parametric, pcs_mod, pcs_parametric, percent_var, npc)
%% function bayesdata = yw_covbat(dat, batch, mod, parametric, pcs_mod, pcs_parametric, percent_var, npc)
% 1.empirical bayesian harmonization of mean and variance
%   dat             -  p x m matrix, p represent participants and m
%                       represents features
%   batch           -  a vector of site labels e.g. [1 1 1 1 2 2 2 2],
%                       corresponding to the order of dat
%   mod             -  a matrix of covariates, each colomn is a covariate and each row
%                       is a participant, corresponding to the order of dat
%   parametric      -  1 - parametric, 0 - nonparametric
%
% 2.empirical bayesian harmonization of covariance
%   pcs_mod         -  whether to regress covariates during harmonizing
%                       covariance PC scores, mod or []
%   pcs_parametric  -  1 - parametric, 0 - nonparametric
%   percent_var     -  the percentage of variance to be harmonized,
%                       90% ~ 95% recommended in the original paper
%   npc             -  the number of PCs to be harmonized, default is null,
%                       once appointed, the set of percent_var will be
%                       useless
%___________________________________________________________________________
% Written by Wang Yu-Wei 220101. Based on Dr. Andrew Chen's R implementation: https://github.com/andy1764/CovBat_Harmonization
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% wangyw@psych.ac.cn
% Reference: Chen, A. A., Beer, J. C., Tustison, N. J., Cook, P. A., Shinohara, R. T., Shou, H., & Initiative, T. A. D. N. (2022). Mitigating site effects in covariance for machine learning in neuroimaging data. Human Brain Mapping, 43(4), 1179–1195. https://doi.org/10.1002/hbm.25688)

    [sds] = std(dat')';
    wh = find(sds==0);
    [ns,ms] = size(wh);
    if ns>0
        error('Error. There are rows with constant values across samples. Remove these rows and rerun ComBat.')
    end
	batchmod = categorical(batch);
    batchmod = dummyvar({batchmod});
	n_batch = size(batchmod,2);
	levels = unique(batch);
	fprintf('[covbat] Found %d batches\n', n_batch);

	batches = cell(0);
	for i=1:n_batch
		batches{i}=find(batch == levels(i));
    end
    % n_batches 存了属于每一个batch的index
	n_batches = cellfun(@length,batches);
    % n_array = n_sub
	n_array = sum(n_batches);

	% Creating design matrix and removing intercept:
	design = [batchmod mod];
	intercept = ones(1,n_array)';
	wh = cellfun(@(x) isequal(x,intercept),num2cell(design,1));
	bad = find(wh==1);
	design(:,bad)=[];


	fprintf('[covbat] Adjusting for %d covariate(s) of covariate level(s)\n',size(design,2)-size(batchmod,2));
	% Check if the design is confounded
	if rank(design)<size(design,2)
		nn = size(design,2);
	    if nn==(n_batch+1) 
	      error('Error. The covariate is confounded with batch. Remove the covariate and rerun ComBat.')
	    end
	    if nn>(n_batch+1)
	      temp = design(:,(n_batch+1):nn);
	      if rank(temp) < size(temp,2)
	        error('Error. The covariates are confounded. Please remove one or more of the covariates so the design is not confounded.');
	      else 
	        error('Error. At least one covariate is confounded with batch. Please remove confounded covariates and rerun ComBat.');
	      end
	    end
	 end


	fprintf('[covbat] Standardizing Data across features\n');
	B_hat = inv(design'*design)*design'*dat'; %最小二乘法拟合
	%Standarization Model
	grand_mean = (n_batches/n_array)*B_hat(1:n_batch,:); %站点加权平均
	var_pooled = ((dat-(design*B_hat)').^2)*repmat(1/n_array,n_array,1);
    sqrt_pooled = sqrt(var_pooled); %这里是最小二乘回归后的residual的sd，而不是对站点加权平均，所以省略了一部分的差异grand_mean-batchmod*B_hat(1:n_batch,:)
	stand_mean = grand_mean'*repmat(1,1,n_array);
    % Making sure pooled variances are not zero:
    wh = find(var_pooled==0);
    var_pooled_notzero = var_pooled;
    var_pooled_notzero(wh) = [];
    var_pooled(wh) = median(var_pooled_notzero);

	if not(isempty(design))
		tmp = design;
		tmp(:,1:n_batch) = 0;
		stand_mean = stand_mean+(tmp*B_hat)'; %站点加权平均加上covariates
	end	
	s_data = (dat-stand_mean)./(sqrt(var_pooled)*repmat(1,1,n_array)); %但这里是包含站点均值差异的standardization

    %---------------------------------------------------------------------    
    %Get regression batch effect parameters
	fprintf('[covbat] Fitting L/S model and finding priors\n')
	batch_design = design(:,1:n_batch);
	gamma_hat = inv(batch_design'*batch_design)*batch_design'*s_data';
	delta_hat = [];
	for i=1:n_batch
		indices = batches{i};
		delta_hat = [delta_hat; var(s_data(:,indices)')];
	end

	%Find parametric priors:
	gamma_bar = mean(gamma_hat');
	t2 = var(gamma_hat');
	delta_hat_cell = num2cell(delta_hat,2);
	a_prior=[]; b_prior=[];
	for i=1:n_batch
		a_prior=[a_prior aprior(delta_hat_cell{i})];
		b_prior=[b_prior bprior(delta_hat_cell{i})];
    end
	
	if parametric
        fprintf('[covbat] Finding parametric adjustments\n')
        gamma_star =[]; delta_star=[];
        for i=1:n_batch
            indices = batches{i};
            temp = itSol(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:),gamma_bar(i),t2(i),a_prior(i),b_prior(i), 0.001);
            gamma_star = [gamma_star; temp(1,:)];
            delta_star = [delta_star; temp(2,:)];
        end
    end
	    
    if (1-parametric)
        gamma_star =[]; delta_star=[];
        fprintf('[covbat] Finding non-parametric adjustments\n')
        for i=1:n_batch
            indices = batches{i};
            temp = inteprior(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:));
            gamma_star = [gamma_star; temp(1,:)];
            delta_star = [delta_star; temp(2,:)];
        end
    end
	    
	fprintf('[covbat] Adjusting the Data\n')
	bayesdata = s_data;
	j = 1;
	for i=1:n_batch
		indices = batches{i};
		bayesdata(:,indices) = (bayesdata(:,indices)-(batch_design(indices,:)*gamma_star)')./(sqrt(delta_star(j,:))'*repmat(1,1,n_batches(i)));
		j = j+1;
	end
	%bayesdata = (bayesdata.*(sqrt(var_pooled)*repmat(1,1,n_array)))+stand_mean;
% this part can be output by combat
    
    %---------------------------------------------------------------------
    % Covariance Harmonization
    %
    
    % 1. project bayesdata into covariance
    cov_mat = bayesdata.*(sqrt(var_pooled)*repmat(1,1,n_array));
    
    % mean centered by col
    M = mean(cov_mat');
    centered = bsxfun(@minus,cov_mat',M);
    
    % scaled by col
    S = std(cov_mat');
    scaled = bsxfun(@rdivide,centered, S);  
    
    % 2. PCA, centered at 0, no scaling
    [coeff,score,latent,~,explained,mu] = pca(scaled); 

    % 3. find the corresponding number of PCs based on explained variance or
    % user-assignment
    idx = 0;
    if isempty(npc)
        sum_explained = 0;
        while sum_explained < percent_var*100
            idx = idx + 1;
            sum_explained = sum_explained + explained(idx);
        end
        fprintf('[covbat] %d principal components explain %f2 precentage variances of covariance. \n',idx,sum_explained);
    else
        idx = npc;
        fprintf('[covbat] Harmonize the first %d principal components of covariance. \n',idx);
    end
    
    % 4. ComBat the first n PCs of score
    rot_scaled = scaled*coeff;
    fprintf('\n[covbat-combat] Combat covariance... \n');
    combat_idx_score = combat_eb(rot_scaled(:,1:idx)',batch,pcs_mod,pcs_parametric,0)';
    
    rot_scaled(:,1:idx) = combat_idx_score;
    
    % 5. project back to residual space
    cov_bayesdata = rot_scaled*coeff'.*repmat(S,length(batch),1) + repmat(M,length(batch),1);
   
	% 6.    
    bayesdata = cov_bayesdata + stand_mean';
    bayesdata = bayesdata';


end

%% 
% This Combat 
function bayesdata = combat_eb(dat, batch, mod, parametric,eb)
    [sds] = std(dat')';
    wh = find(sds==0);
    [ns,ms] = size(wh);
    if ns>0
        error('Error. There are rows with constant values across samples. Remove these rows and rerun ComBat.')
    end
	batchmod = dummyvar(batch);
	n_batch = size(batchmod,2);
	levels = unique(batch);
	fprintf('[combat] Found %d batches\n', n_batch);

	batches = cell(0);
	for i=1:n_batch
		batches{i}=find(batch == levels(i));
	end
	n_batches = cellfun(@length,batches);
	n_array = sum(n_batches);

	% Creating design matrix and removing intercept:
	design = [batchmod mod];
	intercept = ones(1,n_array)';
	wh = cellfun(@(x) isequal(x,intercept),num2cell(design,1));
	bad = find(wh==1);
	design(:,bad)=[];


	fprintf('[combat] Adjusting for %d covariate(s) of covariate level(s)\n',size(design,2)-size(batchmod,2));
	% Check if the design is confounded
	if rank(design)<size(design,2)
		nn = size(design,2);
	    if nn==(n_batch+1) 
	      error('Error. The covariate is confounded with batch. Remove the covariate and rerun ComBat.')
	    end
	    if nn>(n_batch+1)
	      temp = design(:,(n_batch+1):nn);
	      if rank(temp) < size(temp,2)
	        error('Error. The covariates are confounded. Please remove one or more of the covariates so the design is not confounded.')
	      else 
	        error('Error. At least one covariate is confounded with batch. Please remove confounded covariates and rerun ComBat.')
	      end
	    end
	 end


	fprintf('[combat] Standardizing Data across features\n')
	B_hat = inv(design'*design)*design'*dat';
	%Standarization Model
	grand_mean = (n_batches/n_array)*B_hat(1:n_batch,:);
	var_pooled = ((dat-(design*B_hat)').^2)*repmat(1/n_array,n_array,1);
	stand_mean = grand_mean'*repmat(1,1,n_array);

	if not(isempty(design))
		tmp = design;
		tmp(:,1:n_batch) = 0;
		stand_mean = stand_mean+(tmp*B_hat)';
	end	
	s_data = (dat-stand_mean)./(sqrt(var_pooled)*repmat(1,1,n_array));

	%Get regression batch effect parameters
	fprintf('[combat] Fitting L/S model and finding priors\n')
	batch_design = design(:,1:n_batch);
	gamma_hat = inv(batch_design'*batch_design)*batch_design'*s_data';
	delta_hat = [];
	for i=1:n_batch
		indices = batches{i};
		delta_hat = [delta_hat; var(s_data(:,indices)')];
	end

	%Find parametric priors:
	gamma_bar = mean(gamma_hat');
	t2 = var(gamma_hat');
	delta_hat_cell = num2cell(delta_hat,2);
	a_prior=[]; b_prior=[];
	for i=1:n_batch
		a_prior=[a_prior aprior(delta_hat_cell{i})];
		b_prior=[b_prior bprior(delta_hat_cell{i})];
	end

	
	if parametric
        fprintf('[combat] Finding parametric adjustments\n')
        gamma_star =[]; delta_star=[];
        for i=1:n_batch
            indices = batches{i};
            temp = itSol(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:),gamma_bar(i),t2(i),a_prior(i),b_prior(i), 0.001);
            gamma_star = [gamma_star; temp(1,:)];
            delta_star = [delta_star; temp(2,:)];
        end
    end
	    
    if (1-parametric)
        gamma_star =[]; delta_star=[];
        fprintf('[combat] Finding non-parametric adjustments\n')
        for i=1:n_batch
            indices = batches{i};
            temp = inteprior(s_data(:,indices),gamma_hat(i,:),delta_hat(i,:));
            gamma_star = [gamma_star; temp(1,:)];
            delta_star = [delta_star; temp(2,:)];
        end
    end
	    
	fprintf('[combat] Adjusting the Data\n')
	bayesdata = s_data;
	j = 1;
	for i=1:n_batch
		indices = batches{i};
        if eb == 1
            bayesdata(:,indices) = (bayesdata(:,indices)-(batch_design(indices,:)*gamma_star)')./(sqrt(delta_star(j,:))'*repmat(1,1,n_batches(i)));
        else
            bayesdata(:,indices) = (bayesdata(:,indices)-(batch_design(indices,:)*gamma_hat)')./(sqrt(delta_hat(j,:))'*repmat(1,1,n_batches(i)));
        end
        j = j+1;
    end
    
    bayesdata = (bayesdata.*(sqrt(var_pooled)*repmat(1,1,n_array)))+stand_mean;
    
end

%------------------------------------utils----------------------------------------

function y = aprior(gamma_hat)
	m = mean(gamma_hat);
  	s2 = var(gamma_hat);
  	y=(2*s2+m^2)/s2;
end

function y = bprior(gamma_hat)
	m = mean(gamma_hat);
  	s2 = var(gamma_hat);
  	y=(m*s2+m^3)/s2;
end

function adjust = inteprior(sdat, ghat, dhat)
    gstar = [];
    dstar = [];
    r = size(sdat,1);
    for i = 1:r
        g = ghat;
        d = dhat;
        g(i)=[];
        d(i)=[];
        x = sdat(i,:);
        n = size(x,2);
        j = repmat(1,1,size(x,2));
        dat = repmat(x,size(g,2),1);
        resid2 = (dat-repmat(g',1,size(dat,2))).^2;
        sum2 = resid2 * j';
        LH = 1./(2*pi*d).^(n/2).*exp(-sum2'./(2.*d));
        gstar = [gstar sum(g.*LH)./sum(LH)];
        dstar = [dstar sum(d.*LH)./sum(LH)];
    end
    adjust = [gstar; dstar];
end

function adjust = itSol(sdat,g_hat,d_hat,g_bar,t2,a,b, conv)
  g_old = g_hat;
  d_old = d_hat;
  change = 1;
  count = 0;
  n = size(sdat,2);
  while change>conv 
    g_new = postmean(g_hat,g_bar,n,d_old,t2);
    sum2  = sum(((sdat-g_new'*repmat(1,1,size(sdat,2))).^2)');
    d_new = postvar(sum2,n,a,b);

    change = max(max(abs(g_new-g_old)./g_old), max(abs(d_new-d_old)./d_old));
    g_old = g_new;
    d_old = d_new;
    count = count+1;
  end
  adjust = [g_new; d_new];
end

function y = postmean(g_hat ,g_bar, n,d_star, t2)
	y=(t2*n.*g_hat+d_star.*g_bar)./(t2*n+d_star);
end

function y = postvar(sum2,n,a,b)
	y=(.5.*sum2+b)./(n/2+a-1);
end
