
%% Version 2019-03-03: Minor update
% *New network models*
%
% * navigation_wu.m: Navigation of connectivity length matrix guided by
%   nodal distance 
% * quasi_idempotence.m: Connection matrix quasi-idempotence
% 
% *Bug fixes and/or code improvements*
% * gateway_coef_sign.m: Bugfix, change in handling of weighted matrices.
% * search_information.m: Modified to make user directly specify
%                         weight-to-length transformations.
%
%% Version 2017-15-01: Major update
% *New network models*
%
% * generate_fc.m: Generation of synthetic functional connectivity matrices
%   based on structural network measures.
% * predict_fc.m: Prediction of functional connectivity matrices from
%   structural connectivity matrices.
% * mleme_constraint_model.m: Unbiased sampling of networks with soft
%   module and hub constraints (maximum-likelihood estimation of maximum
%   entropy networks).
%
% *New measures and demos*
%
% * clique_communities.m: Overlapping community structure via the clique
%   percolation method.
% * rentian_scaling_2d.m and rentian_scaling_3d.m: Updated rentian scaling
%   functions to replace rentian_scaling.m.
% * diffusion_efficiency.m:  Global mean and pair-wise effiency based on
%   a diffusion process.
% * distance_wei_floyd.m: All pairs shortest paths via the Floyd-Warshall
%   algorithm.
% * mean_first_passage_time.m: Mean first passage time.
% * path_transitivity.m: Transitivity based on shortest paths.
% * resource_efficiency_bin.m: Resource efficiency and shortest path
%   probability.
% * rout_efficiency.m: Mean, pair-wise and local routing efficiency.
% * retrieve_shortest_path.m: Retrieval of shortest path between source and
%   target nodes.
% * search_information.m: Search information based on shortest paths.
% * demo_efficiency_measures.m: Demonstration of efficiency measures.
%
% *Removed functions*
%
% * rentian_scaling.m: Replaced with rentian_scaling_2d.m and
%   rentian_scaling_3d.m.
%
% *Bug fixes and/or code improvements and/or documentation improvements*
%
% * efficiency_wei.m: Included a modified weighted variant of the local
%   efficiency. 
% * partition_distance.m: Generalized computation of distances to input
%   partition matrices. 
% * clustering_coef_wu_sign.m: Fixed computation of the denominator in the
%   Constantini and Perugini versions of the weighted clustering
%   coefficient.
% * modularity_dir.m and modularity_und.m: Updated documentation and
%   simplified code to clarify that these are deterministic algorithms.
% * weight_conversion.m: Corrected bug in weight autofix.
%
% *Cosmetic and MATLAB code analyzer (mlint) improvements to many other functions*
%
%% Version 2016-16-01: Major update
% *New network models*
%
% * generative_model.m: Implements more than 10 generative network models.
% * evaluate_generative_model.m: Implements and evaluates the accuracy of
% more than 10 generative network models.
% * demo_generative_models_geometric.m and
% demo_generative_models_neighbors.m: Demonstrate the capabilities of the
% new generative model functions.
%
% *New network measures*
%
% * clustering_coef_wu_sign.m: Multiple generalizations of the clustering
% coefficient for networks with positive and negative weights.
% * core_periphery_dir.m: Optimal core structure and core-ness statistic.
% * gateway_coef_sign.m: Gateway coefficient (a variant of the
% participation coefficient) for networks with positive and negative
% weights.
% * local_assortativity_sign.m: Local (nodal) assortativity for networks
% with positive and negative weights.
% * randmio_dir_signed.m: Random directed graph with preserved signed in-
% and out- degree distribution.
%
% *Removed network measures*
%
% * modularity_louvain_und_sign.m, modularity_finetune_und_sign.m: This
% functionality is now provided by community_louvain.m.
% * modularity_probtune_und_sign.m: Similar functionality is provided by
% consensus_und.m
%
% *Bug fixes and/or code improvements and/or documentation improvements*
%
% * charpath.m: Changed default behavior, such that infinitely long paths
% (i.e. paths between disconnected nodes) are now included in computations
% by default, but may be excluded manually.
% * community_louvain.m: Included generalization for negative weights,
% enforced binary network input for Potts-model Hamiltonian, streamlined
% code.
% * eigenvector_centrality_und.m: Ensured the use of leading eigenvector
% for computations of eigenvector centrality.
% * modularity_und.m, modularity_dir.m: Enforced single node moves during
% fine-tuning step.
% * null_model_und_sign.m and null_model_dir_sign.m: Fixed preservation
% of negative degrees in sparse networks with negative weights.
% * randmio_und_signed.m: Now allows unbiased exploration of all network
% configurations.
% * transitivity_bd.m, transitivity_wu.m, transitivity_wd.m: removed tests
% for absence of nodewise 3-cycles. Expanded documentation.
% * clustering_coef_wu.m, clustering_coef_wd.m: Expanded documentation.
% * motif3-m and motif4-m functions: Expanded documentation.
% * rich_club_wu.m, rich_club_wd.m. Expanded documentation.
%
% *Cosmetic and MATLAB code analyzer (mlint) improvements to many other functions*
%
%% Version 2015-25-01: Major update
% Includes two new community-detection scripts and multiple improvements
%
% * New community detection scripts: 1. community_louvain.m (supersedes
% modularity_louvain.m and modularity_finetune.m scripts); 2.
% link_communities.m.
% * added autofix flag to weight_conversion.m for fixing common weight
% problems.
% * other function improvements: participation_coef.m, charpath.m,
% reorder_mod.m.
% * bug fixes: modularity_finetune_und_sign.m,
% modularity_probtune_und_sign.m, threshold_proportional.m
% * changed help files: assortativity_wei.m, distance_wei.m
%
%
%% Version 2014-04-05: Minor update
%
% * consensus_und.m is now a self-contained function
% * headers in charpath.m and in threshold_proportional.m have been corrected
