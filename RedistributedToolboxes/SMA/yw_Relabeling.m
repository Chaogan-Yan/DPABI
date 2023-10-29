% clear;clc;
% load('/Users/dianewang/Desktop/RfMRIHarmonization/scanner_harmonization/data_results/FCP/archived/600_subinfo.mat');
% r = Relabeling(Age,[21,40],3,Sex,0,2);

function labels = yw_Relabeling(varargin)
%% labels = Relabeling(varargin)
%Input
%   vars - continuous variable, e.x age, education years, etc. numerical
%           vectors n samples x 1 column. And the next is the cutoffs,for
%           example Relabeling([34,24,35,63,12],[21,40])
fprintf('Inputting %d variables... \n',nargin/2);
t=[];
tc=[];
nar = 1:2:nargin;
for i_cut = 1:length(nar)
    n = nar(i_cut);
    fprintf('variable %d is relabeling... \n',i_cut);
    
    if n~=nargin-1  % not the last variable
        if varargin{n+1}~=0  % continuous variable
            relabeled= zeros(size(varargin{n},1),1);
            vec = varargin{n};
            if iscell(vec)
                vec = cell2mat(vec);
            end
            nsample = length(vec);
            cut = varargin{n+1};
            n_category = length(cut)+1;
            
            if n_category == 2 % two categories
                relabeled(vec<=cut)=0;
                relabeled(vec>cut)=1;
            elseif n_category >= 2 % more than 2 categories
                num = [0:1:length(cut)];
                dummy = zeros(nsample,length(cut)+1);
                for k = 1:length(cut)+1
                    if k==1
                        dummy(:,k) = vec<=cut(k);
                    elseif k>1 && k<length(cut)+1
                        dummy(:,k) = vec<=cut(k) & vec>=cut(k-1) ;
                    else
                        dummy(:,k) = vec>cut(k-1);
                    end
                end
                relabeled =dummy*num';
            end
        else %varargin{n+1}==0 % category variable:
            % considering change into only latter requirement
            fprintf('Checking whether variable %d is start with 1.\n',i_cut);
            category = varargin{n};
            [relabeled,n_category] = encode_data(category,0);

        end
    elseif n==nargin-1 & varargin{n+1}==0 % variable is categorical
        fprintf('Checking whether variable %d is start with 1.\n',i_cut);
        category = varargin{n};
        [relabeled,n_category] = encode_data(category,1);

        disp('The labeling is finished.');
        
    elseif n==nargin-1 & varargin{n+1}~=0  %last variable is numerical
        vec = varargin{n};
        if iscell(vec)
            vec = cell2mat(vec);
        end
        nsample = length(vec);
        cut = varargin{n+1};
        n_category = length(cut)+1;
        if n_category == 2 % two categories
            relabeled(vec<=cut,1)=1;
            relabeled(vec>cut,1)=2;
        elseif n_category >= 2
            num = [1:1:length(cut)+1];
            dummy = zeros(nsample,length(cut)+1);
            for k = 1:length(cut)+1
                if k==1
                    dummy(:,k) = vec<=cut(k);
                elseif k>1 && k<length(cut)+1
                    dummy(:,k) = vec<=cut(k) & vec>=cut(k-1) ;
                else
                    dummy(:,k) = vec>cut(k-1);
                end
            end
            relabeled =dummy*num';
            disp('The labeling is finished.');
        end
    end
    if length(unique(relabeled))< n_category
        error('Variable %d got classes less than pointed.\n',i_cut);
    end
    t = [t,relabeled];
    tc = [tc,n_category];
    if size(t,1)~=length(relabeled)
        error('check data size of variable %s and make sure it equals to the sample number.',i_cut);
    end
end
labels=zeros(size(t,1),1);
for j =  1:size(t,2)
    labels = labels+t(:,j)*prod(tc(j+1:end));
end
end


function cellstring = all2cellstring(array)
if ~iscell(array)
    if isnumeric(array)
        cellstring = cellstr(num2str(array));
    elseif isstring(array)
        cellstring = cellstr(array);
    end
else
    cellstring = array;
    where_is_num_cell = cell2mat(cellfun(@isnumeric,cellstring,...
        'UniformOutput',false));
    if any(where_is_num_cell)
        num_str= num2str(cell2mat(array(find(where_is_num_cell))));
        cellstring(find(where_is_num_cell)) = cellstr(num_str);
    end
end
end

function [encoded_data,n_category] = encode_data(input_data,current_code)
% Check if the input data is a cell and contains numeric or character data
if iscell(input_data) && ~isempty(input_data)
    % Convert cell to a single array if it contains numeric data
    input_data = cell2mat(input_data);
end

% Find unique categories in the input data
unique_categories = unique(input_data);
n_category = length(unique_categories);
% Initialize the encoded data arrayss
encoded_data = zeros(size(input_data));

% Encode the data
%current_code = 0;
for i = 1:length(unique_categories)
    category = unique_categories(i);
    encoded_data(input_data == category) = current_code;
    current_code = current_code + 1;
end
end
