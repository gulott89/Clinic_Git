function err = classifier_eval(type, data_train, labels_train, data_test, labels_test, opts)

calc_error = @(x,y) sum(x~=y)/length(y);

if (opts.RunSubset == 1)
    % subset selection
    imp_feats = feast(opts.Method,opts.numToSelect,data_train,labels_train);

    data_train = data_train(:,imp_feats);
    data_test = data_test(:, imp_feats);
end

switch type
    case 'tree'
        % do something
         tree = ClassificationTree.fit(data_train, labels_train);
         pred = predict(tree, data_test);
    case 'naivebayes'
        nb = NaiveBayes.fit(data_train, labels_train);
        pred = predict(nb, data_test);
    case 'knn'
        mdl = ClassificationKNN.fit(data_train, labels_train, 'NumNeighbors',...
            opts.NumNeighbors, 'Distance', opts.Distance);
        pred = predict(mdl, data_test);
    case 'svm'
        switch opts.kernel_function
            case 'polynomial'
                svm = svmtrain(data_train, labels_train, 'kernel_function',...
                    opts.kernel_function, 'polyorder', opts.polyorder,...
                    'boxconstraint', opts.boxconstraint);
            case 'rbf'
                svm = svmtrain(data_train, labels_train, 'kernel_function',...
                    opts.kernel_function, 'rbf_sigma', opts.rbf_sigma,...
                    'boxconstraint', opts.boxconstraint);
            otherwise
                error('unknown kernel!');
        end
        
        pred = svmclassify(svm, data_test);
         
    case 'adaboost'
       if length(unique([labels_test;labels_train])) >= 3
        ens = fitensemble(data_train,labels_train, ...
            'AdaBoostM2',opts.NLearn,opts.Learners);
       else
           ens = fitensemble(data_train,labels_train, ...
            'AdaBoostM1',opts.NLearn,opts.Learners);
       end
       pred = predict(ens, data_test);
       
    otherwise
        error('unknown classifier!')
end

err = calc_error(pred, labels_test);