
int: N;
int: n_CU;
%int: start_unmapped;
int: n_unmapped;

set of int: NODES = 1..N;
array[NODES] of set of NODES: predecessors;
set of NODES: mapped_set;
%set of NODES: unmapped_set;
array[1..n_unmapped] of NODES: unmapped_set;

array[NODES] of bool: done;
array[NODES] of var 0..n_CU: done_CU; % add constrints for already mapped nodes
array[1..n_unmapped] of var 0..n_CU: done_CU_curr_mapped= [done_CU[n] | n in unmapped_set]; % add constrints for already mapped nodes

array[NODES] of var bool: mapped;
array[NODES] of var 0..2: edge_cost;
array[1..n_CU] of var 0..(2*n_unmapped): out_edge_cost_per_CU;
array[1..n_CU] of var 0..(2*n_unmapped): in_edge_cost_per_CU;

%array[1..n_CU] of var 0..(n_unmapped +1): mapped_per_CU;
array[1..n_CU] of var 0..15: mapped_per_CU;
var int: max_workload= max(mapped_per_CU);
array[1..n_CU] of var 0..(n_unmapped +1): workload_cost;
constraint workload_cost= [max_workload - mapped_per_CU[cu] | cu in 1..n_CU];


% intra-barrier constraint
constraint forall(n in unmapped_set) (
    if (mapped[n]) then
      forall (p in predecessors[n]) (
        done[p] \/ (done_CU[p] == done_CU[n])
      )
    endif
  );
constraint forall(n in mapped_set) (
    mapped[n] = 0
  );
constraint forall(n in mapped_set) (
    done_CU[n] != 0
  );

constraint forall(n in mapped_set) (
    done[n] == 1
  );
constraint forall(n in unmapped_set) (
    done[n] == 0
  );


% edge_cost of edges crossing CUs
%constraint forall(n in unmapped_set) (
%    if (mapped[n]) then
%      edge_cost[n] == sum(p in predecessors[n]) (done_CU[n] != done_CU[p])
%    else
%      edge_cost[n] == 0
%    endif
%  );

% workload balancing
constraint forall(n in unmapped_set) (
    if (mapped[n]) then
      done_CU[n] != 0
    else
      done_CU[n] = 0
    endif
  );
constraint forall(cu in 1..n_CU) (
    mapped_per_CU[cu] = sum(n in unmapped_set) (done_CU[n] == cu)
  );


% init constraints
%constraint forall(n in 1..(start_unmapped-1)) (
%    mapped[n] == 0
%  );
%constraint forall(n in 1..(start_unmapped-1)) (
%    edge_cost[n] == 0
%  );

include "init_constraints_wilt.mzn";

% symmetry break
include "globals.mzn";
%constraint seq_precede_chain(mapped_per_CU);
constraint seq_precede_chain(done_CU_curr_mapped);
%constraint lex_lesseq(mapped_per_CU, reverse(mapped_per_CU));
%constraint decreasing(mapped_per_CU);

%constraint forall(cu in 1..n_CU) (
%    out_edge_cost_per_CU[cu] = sum([edge_cost[n] | n in unmapped_set where done_CU[n] == cu])
%  );

int: w_tot= 10;
int: w_balance= 5;
var int: obj;
constraint obj= sum(sort(mapped_per_CU)[1..5]);
%constraint obj= min(mapped_per_CU);
%constraint obj= w_tot*sum(mapped) - w_balance*(sum(workload_cost)) - sum(edge_cost);
%constraint obj > 0;
%constraint obj= w_tot*sum(mapped) - w_balance*(max(mapped_per_CU) - min(mapped_per_CU)) - sum(edge_cost);

%solve maximize w_tot*sum(mapped) - w_balance*(max(mapped_per_CU) - min(mapped_per_CU)) - sum(edge_cost);

ann: search_ann1;
%search_ann1 = int_search(done_CU, input_order, indomain_max);
search_ann1 = int_search(done_CU_curr_mapped, input_order, indomain_max);
solve :: seq_search ([search_ann1]) maximize obj;
%solve maximize obj;

output [ "obj = \(obj)\n",
      "edge_cost = \(edge_cost) \n",
      "done_CU_curr_mapped = \(done_CU_curr_mapped) \n",
      "sum_mapped = \(sum(mapped)) \n",
      "workload_cost = \(workload_cost) \n",
      "mapped_per_CU= \(mapped_per_CU) \n",
    ];
