function Cost = compute_cost_matrix(num_classes, useSAMME, costsAlpha, costsBeta, ~)

if useSAMME
  Cost = ones(num_classes,num_classes) - diag(ones(num_classes,1));
else
  PosCosts = ones(num_classes-1, num_classes-1) - diag(ones(num_classes-1, 1));
  Cost = [[0             costsAlpha*ones(1,num_classes-1)]; ...
         [costsBeta*ones(num_classes-1,1)  PosCosts]];
end
