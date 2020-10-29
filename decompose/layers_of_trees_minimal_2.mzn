
int : PIPESTAGES= 0;
int: TMAX;
int: V;
set of int: VERTICES= 1..V;

int: D= 3;
int: NMAX= 32;

array[VERTICES] of set of VERTICES: successors;
array[VERTICES] of int: SLACK_DICT;
array[VERTICES] of set of VERTICES: predecessors;
int :E;
array[1..E, 1..2] of 1..V: edges;

% variables
array [VERTICES] of var 1..TMAX: T;
array [VERTICES] of var 1..D: L;


array [1..E] of var bool: edge_in_same_T = [(T[edges[e,1]] == T[edges[e,2]]) | e in 1..E];
array [1..E] of var 0..(D-1): alu_cost_per_edge;
array [1..E] of var 0..(D-1): input_cost_per_edge;
array [VERTICES] of var bool: output_cost_per_v;
array [VERTICES] of var 0..1: effective_succ_in_same_T; 

array [VERTICES] of var bool: bottom;

var int: tot_cost= 
  sum(alu_cost_per_edge) + 
  sum(output_cost_per_v) + 
  sum(input_cost_per_edge); % here cost_multiplier_per_v also represents the
                          % alu cost of actually executing v
    % top indicates number of outputs

% pipeline hazard constraint
constraint forall(v in 1..V) (
      forall (s in successors[v]) (
         (T[s] >= T[v]) /\ (T[s] <= T[v] + SLACK_DICT[v] + 5)
      )
    );

% level constraint
constraint forall(e in 1..E) (
%    if (T[edges[e, 1]] = T[edges[e, 2]]) then 
%      L[edges[e, 2]] >= L[edges[e, 1]] + 1
%    endif
    L[edges[e, 2]] >= ((edge_in_same_T[e])*L[edges[e, 1]] + 1)
  );

constraint forall(v in 1..V) (
    bottom[v] == (L[v] == 1)
  );
% top constraint
constraint forall(v in 1..V) (
%    top[v] = exist(s in successors[v]) (T[s] > T[v])
    output_cost_per_v[v] == (1 - (forall(s in successors[v]) (T[s] = T[v])))
  );

constraint forall(v in 1..V) (
    bottom[v] = forall(p in predecessors[v]) (T[p] < T[v])
  );

% at max 1 successor in same T
constraint forall(v in 1..V) (
    effective_succ_in_same_T[v] = sum(s in successors[v]) (T[s] == T[v]) 
  );

% fix the final node
constraint T[V] == TMAX;

% Cost
constraint forall(e in 1..E) (
  input_cost_per_edge[e] =
  (1-edge_in_same_T[e])
);
constraint forall(e in 1..E) (
  alu_cost_per_edge[e] == (L[edges[e,2]] - (edge_in_same_T[e] * L[edges[e,1]])
  -1)
);


solve minimize tot_cost;
%solve minimize max(T);
%solve  :: int_search(L, anti_first_fail, indomain_min, complete) minimize sum_pow_L;

output [
%"approx_blocks = \((sum(alu_cost_per_edge) +
%sum(cost_multiplier_per_v))/NMAX) \n",
  "tot_cost = \(tot_cost)\n",
  "T[root] = \(T[V])\n",
%  "T = \(T)\n",
%  "L = \(L)\n",
%  "alu_cost_per_edge= \(alu_cost_per_edge)\n",
%  "effective_succ_in_same_T = \(effective_succ_in_same_T)\n",
%  "input_cost_per_edge = \(input_cost_per_edge)\n",
%  "cost_multiplier_per_v = \(cost_multiplier_per_v)\n",
  ];

%output ["approx_blocks = \(L_count/NMAX) \n",
%    "\(count(L,3)), \(count(L,2)), \(count(L,1)) \n"
%  ];


