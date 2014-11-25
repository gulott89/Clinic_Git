function [data, labels,features] = load_data(dataset, opts)

features={};
addpath ../../Server_Data/

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
        
     case 'AmericanGutOV'
         M = importdata('ag_g_d_oveg.data');
         N = importdata('ag_g_d_oveg.label');
         Q = importdata('ag_g_d_oveg.features');
         features = Q;
         
         data = zeros(size(M));
  for i = 1:size(M,2)
    [nel,nce] = hist(M(:,i), floor(sqrt(size(M,2))));
    [bincounts,ind]= histc(M(:,i), nce);
    data(:,i) = ind+1;
  end
  
  remove = find(sum(M)<size(M,1)*.1);
  M(:,remove) = [];
  Q(remove) = [];
         
         [~,~,labels] = unique(N);
        
      case 'AmericanGutSex'
         M = importdata('ag_g_sex.data');
         N = importdata('ag_g_sex.label');
         Q = importdata('ag_g_sex.features');
         features = Q;
         
         data = zeros(size(M));
  for i = 1:size(M,2)
    [nel,nce] = hist(M(:,i), floor(sqrt(size(M,2))));
    [bincounts,ind]= histc(M(:,i), nce);
    data(:,i) = ind+1;
  end
  
  remove = find(sum(M)<size(M,1)*.1);
  M(:,remove) = [];
  Q(remove) = [];
         
         [~,~,labels] = unique(N);
        
            
    otherwise
        error('unknown data!')
end