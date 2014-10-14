function [data, labels] = load_data(dataset, opts)
% [data,labels] = load_data(dataset, opts)

addpath ./FEAST

% Loads the data
switch dataset
    case 'iris'
        load fisheriris
        [~,~,labels] = unique(species);
        data=meas;
    case 'wine'
       load wine_dataset;
       [~,~,labels] = unique(wineTargets', 'rows');
       data = wineInputs';
    case 'ionosphere'
        load ionosphere;
        data= X;
        data(:,[1,2]) = [];
        [~,~,labels] = unique(Y);
    case 'gaussian'
        data = [];
        labels = [];
        
        % data_opts.plot = true;
        plt_types = {'rp','bo','ks','g^'};
        if opts.plot
            figure;
            hold on;
            box on;
            grid on;
        end
        
        for c = 1:opts.classes
            data_c = mvnrnd(opts.MU{c}, opts.SIGMA{c}, opts.samples(c));
            data = [data; data_c];
            labels = [labels; c*ones(opts.samples(c),1)];
            if opts.plot
                plot(data_c(:, 1), data_c(:, 2), plt_types{c})
                axis tight;
            end
        end
            
    otherwise
        error('unknown data!')
end