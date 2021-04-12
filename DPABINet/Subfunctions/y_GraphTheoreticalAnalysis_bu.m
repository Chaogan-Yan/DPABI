function [GTA] = y_GraphTheoreticalAnalysis_bu(G,RandomTimes)

% function [GTA] = y_GraphTheoreticalAnalysis_bu(G,RandomTimes)
% Perform graph theoretical analysis based on Brain-Connectivity-Toolbox (BCT, http://www.brain-connectivity-toolbox.net) 

% Input:   G  -  The binary undirected connection matrix
%          RandomTimes  -  The number of random matrix for calculation of Gamma, Lambda and Sigma
% Output:  GTA  -  A structure of results

%[Cp, Lp, Gamma, Lambda, Sigma, Eloc, Eglob, Assortativity, NO!!Hierarchy, NO!!Synchronization, Modularity]
%[Degree, NodalEfficiency, Betweenness, ClusteringCoefficient, ParticipantCoefficient, NO!!NormalizedParticipantCoefficient, SubgraphCentrality, EigenvectorCentrality, PageRankCentrality]


%__________________________________________________________________________
% Written by YAN Chao-Gan 121115.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

G = double(G);
N = size(G,1);

GTA.ClusteringCoefficient = clustering_coef_bu(G);
GTA.Cp = mean(GTA.ClusteringCoefficient);


D=distance_bin(G);
D(find(eye(size(D)))) = Inf; % Put the length from one node to itself to Inf
GTA.Lp = 1/(sum(sum(1./D))/(N*(N-1))); %Harmonic mean

if exist('RandomTimes','var') && RandomTimes>0
    Cp_Rand = zeros(RandomTimes,1);
    Lp_Rand = zeros(RandomTimes,1);
    for iRand = 1:RandomTimes
        [R]=randmio_und(G, 4); % ITER set to 4 as the default value in Maslov's program: http://www.cmth.bnl.gov/~maslov/sym_generate_srand.m
        ClusteringCoefficient = clustering_coef_bu(R);
        Cp_Rand(iRand) = mean(ClusteringCoefficient);
        D=distance_bin(R);
        D(find(eye(size(D)))) = Inf; % Put the length from one node to itself to Inf
        Lp_Rand(iRand) = 1/(sum(sum(1./D))/(N*(N-1))); %Harmonic mean
        fprintf('.');
    end
    fprintf('\n');
    GTA.Gamma = GTA.Cp/mean(Cp_Rand);
    GTA.Lambda = GTA.Lp/mean(Lp_Rand);
    GTA.Sigma = GTA.Gamma/GTA.Lambda;
    %YAN Chao-Gan, 160519. Record the Cp_Rand and Lp_Rand
    GTA.Cp_Rand=Cp_Rand;
    GTA.Lp_Rand=Lp_Rand;
end

GTA.Eglob = efficiency_bin(G);
GTA.NodalEfficiency = efficiency_bin(G,1);
GTA.Eloc = mean(GTA.NodalEfficiency);

GTA.Assortativity = assortativity_bin(G,0);

[Ci Q]=modularity_und(G);
GTA.Modularity = Q;
GTA.ParticipantCoefficient = participation_coef(G,Ci);


GTA.Degree = sum(G)';

GTA.Betweenness = betweenness_bin(G)';

GTA.SubgraphCentrality = subgraph_centrality(G);
GTA.EigenvectorCentrality = eigenvector_centrality_und(G);
GTA.PageRankCentrality = pagerank_centrality(G, 0.85); %A common value for the damping factor is d = 0.85.



