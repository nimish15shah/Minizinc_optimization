
include "globals.mzn";

int: N;
int: n_CU;

set of int: NODES = 1..N;
array[NODES] of set of NODES: one_predecessors;
array[NODES] of set of NODES: predecessors;

array[NODES] of var 1..n_CU: done_CU; 
array[NODES] of var 0..n_CU: done_CU_active; 
array[NODES] of var 0..1: node_active; 

%array[1..n_CU] of var 0..(45): mapped_per_CU;
array[1..n_CU] of var 0..(N+1): mapped_per_CU;
array[1..n_CU] of var 0..(N+1): mapped_per_CU_active;

% intra-barrier constraint
constraint forall(n in NODES) (
      forall (p in one_predecessors[n]) (
        done_CU[p] == done_CU[n]
      )
  );

%constraint forall(n in NODES) (
%      if (forall (p in predecessors[n]) (done_CU[p] == done_CU[n])) then
%        %done_CU_active[n] = done_CU[n]
%        done_CU_active[n] = 1
%      else
%        done_CU_active[n] = 0
%      endif
%  );

constraint forall(n in NODES) (
  node_active[n] = forall (p in predecessors[n]) (done_CU[p] == done_CU[n] /\ done_CU_active[p] != 0)
);
constraint forall(n in NODES) (
  done_CU_active[n]= node_active[n] * done_CU[n]
);

% count mapped
constraint forall(cu in 1..n_CU) (
    mapped_per_CU[cu] = count(done_CU, cu)
  );

constraint forall(cu in 1..n_CU) (
    mapped_per_CU_active[cu] = count(done_CU_active, cu)
  );

% symmetry break
%constraint seq_precede_chain(done_CU);

var int: obj;
%constraint obj= sum(sort(mapped_per_CU)[1..32]);
constraint obj= min(mapped_per_CU_active);

ann: search_ann1;
search_ann1 = int_search(done_CU, first_fail, indomain_random);
%search_ann1 = int_search(done_CU, input_order, indomain_max);

solve :: seq_search ([search_ann1]) maximize obj;
%solve maximize obj;

output [ "obj = \(obj)\n",
      "done_CU= \(done_CU) \n",
      "mapped_per_CU= \(mapped_per_CU) \n",
      "mapped_per_CU_active= \(mapped_per_CU_active) \n",
    ];
