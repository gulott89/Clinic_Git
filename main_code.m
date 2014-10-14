% subset selection with opts
% gavin brown paper..do feature subset selection on labels and data train
% do this inside classifier eval..obs in rows, feat columns

clc
clear
close all

%Loads the FEAST Toolbox
addpath ../../Code/FEAST
addpath ../../Code/MIToolbox

% Create anon (calc error)and variables
% and select dataset and classifier
calc_error = @(x,y) sum(x~=y)/length(y); 
k_folds=5;
dataset = 'ionosphere';
classifier = 'naivebayes';

data_opts.MU = {[1,1] [-1,-1]};
data_opts.SIGMA = {eye(2), eye(2)};
data_opts.classes = 2;
data_opts.samples = [100,100];
data_opts.plot = true;

% opts.classifier_type = 'tree';

% specific to naivebayes
 opts.classifier_type = 'naivebayes';

% Specific to KNN
% opts.NumNeighbors=5;
% opts.Distance='euclidean';
% opts.classifier_type = 'knn';

% Specific to SVM (poly)
% opts.classifier_type = 'svm';
% opts.kernel_function = 'polynomial';
% opts.polyorder = 6;
% opts.boxconstraint = 1;

% Specific to SVM (rbf)
% opts.classifier_type = 'svm';
% opts.kernel_function = 'rbf';
% opts.rbf_sigma = 2;
% opts.boxconstraint = 1;

% Specific to Subset Selection
opts.Method = 'jmi';
opts.numToSelect = 3;
opts.RunSubset = 1;

[data,labels] = load_data(dataset);

% perm the data and labels
idx = randperm(length(labels)); 
data = data(idx,:);
labels = labels(idx);

%%%%%%%%%%

% create a tree
%tree = ClassificationTree.fit(data,labels);
% view(tree, 'mode', 'graph')

%pred = predict(tree, data);

%split data/labels in k-folds
% for k...
% train a tree (check)
% test a tree (check)
% calc error
cv = cvpartition(length(labels), 'k', k_folds);
err = zeros(k_folds,1);

tic;
for k = 1:k_folds
   idx_train = cv.training(k);
   idx_test = cv.test(k);
   
   err(k) = classifier_eval(classifier, data(idx_train,:), ...
   labels(idx_train), data(idx_test,:), labels(idx_test), opts);
   
end
runtime = toc;

cv_error = mean(err);
disp(cv_error)
save(['classification_',opts.classifier_type,'_cv',num2str(k_folds),...
    '_',dataset,'.mat']);
