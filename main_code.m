clc
clear all
close all

%Loads Necessary Toolboxes
addpath ../../Code/FEAST
addpath ../../Code/MIToolbox
addpath ../../Server_Data/

% Create anon (calc error)and variables, select dataset and classifier
calc_error = @(x,y) sum(x~=y)/length(y); 
k_folds=5;
dataset = 'AmericanGutOV';
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

[data,labels,features] = load_data(dataset);

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
   
   [err(k),imp_feats{k}] = classifier_eval(classifier, data(idx_train,:), ...
   labels(idx_train), data(idx_test,:), labels(idx_test), opts);
   features{imp_feats{k}}
   
end
runtime = toc;

cv_error = mean(err);
disp(cv_error)

for i=1:size(data,2)
    MI(i) = mi(data(:,i),labels);
end
figure
hist(MI,20)
title('Histogram of Mutual Information')
xlabel('Distribution')
ylabel('Frequency')

[~,index]=sort(MI,'descend');
datanew = data(:,index([1:500]));
for i=1:size(datanew,2)
    for J=1:size(datanew,2)
     CMI(i,J) = cmi(datanew(:,i),datanew(:,J),labels);
     CMI(J,i) = CMI(i,J);
    end
end
figure(2)
pcolor(log(CMI))
shading interp
colorbar
title('Log Intensity Plot of Conditional Mutual Information')
xlabel('Features')
ylabel('Features')

save(['classification_',opts.classifier_type,'_cv',num2str(k_folds),...
    '_',dataset,'.mat']);
