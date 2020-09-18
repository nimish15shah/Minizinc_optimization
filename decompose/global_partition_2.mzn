
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

array [1..E] of var 0..(D-1): alu_cost_per_edge;
array [1..E] of var 0..(D-1): alu_cost_per_edge_multiplied;
array [1..E] of var 0..(D-1): input_cost_per_edge;
array [VERTICES] of var 0..5: effective_succ_in_same_T; 
array [VERTICES] of var 1..5: cost_multiplier_per_v;
var int: tot_cost= sum(alu_cost_per_edge_multiplied) + sum(cost_multiplier_per_v) +
sum(input_cost_per_edge); % here cost_multiplier_per_v also represents the
                          % alu cost of actually executing v

array [VERTICES] of var bool: top;
array [VERTICES] of var bool: bottom;

array [1..TMAX] of var 0..NMAX: sum_top;
%array [1..TMAX] of var set of VERTICES: t_to_v;

% pipeline hazard constraint
constraint forall(v in 1..V) (
      forall (s in successors[v]) (
%         (T[s] = T[v]) \/ (T[s] > T[v] + PIPESTAGES)
         (T[s] >= T[v]) /\ (T[s] <= T[v] + SLACK_DICT[v])
%         (T[s] >= T[v]) 
      )
    );

% level constraint
constraint forall(e in 1..E) (
    if (T[edges[e, 1]] = T[edges[e, 2]]) then 
      L[edges[e, 2]] >= L[edges[e, 1]] + 1
    endif
  );

constraint forall(v in 1..V) (
    bottom[v] -> L[v] = 1
  );
% top constraint
constraint forall(v in 1..V) (
    top[v] = forall(s in successors[v]) (T[s] > T[v])
  );

constraint forall(v in 1..V) (
    bottom[v] = forall(p in predecessors[v]) (T[p] < T[v])
  );


% Cost
constraint forall(v in 1..V) (
    effective_succ_in_same_T[v] = sum([cost_multiplier_per_v[s] | s in successors[v] where T[s] = T[v]])
  );

constraint forall(v in 1..V) (
    if (effective_succ_in_same_T[v] <= 1) then
      cost_multiplier_per_v[v] = 1
    else
      cost_multiplier_per_v[v] = effective_succ_in_same_T[v]
    endif
  );
constraint forall(e in 1..E) (
    if (T[edges[e, 1]] = T[edges[e, 2]]) then
      (alu_cost_per_edge[e] = (L[edges[e,2]] - L[edges[e,1]] -1)) /\
      (input_cost_per_edge[e] = 0)
    else
      (alu_cost_per_edge[e] = (L[edges[e,2]]- 1)) /\
      (input_cost_per_edge[e] = cost_multiplier_per_v[edges[e, 2]])
    endif
  );


constraint forall(e in 1..E) (
    alu_cost_per_edge_multiplied[e] = alu_cost_per_edge[e] *
    cost_multiplier_per_v[edges[e, 2]]
  );

% sum constraint
%constraint forall(t in 1..TMAX) (
%    sum_top[t] = sum([ L[v] | v in VERTICES where T[v] = t])
%    sum_top[t] = sum([power_func[L[v]] | v in VERTICES where (T[v] = t) /\
%    top[v]])
%    sum_top[t] = sum(v in t_to_v[t] where top[v]) (power_func[L[v]])
%  );

% channeling constraint
%include "int_set_channel.mzn";
%constraint int_set_channel(T, t_to_v);

% global constraints
%include "partition_set.mzn";
%constraint partition_set(t_to_v, VERTICES);

% set sizes cannot increse beyond a given value
%constraint forall (t in 1..TMAX) (
%    card(t_to_v[t]) <= NMAX
%  );

%include "cumulative.mzn";
%constraint cumulative(T, [1 | v in 1..V], [1 | v in 1..V], NMAX);

%include "at_most_int.mzn";
%constraint forall(t in 1..TMAX) (at_most_int(NMAX, T, t));

solve minimize tot_cost;
%solve minimize max(T);
%solve  :: int_search(L, anti_first_fail, indomain_min, complete) minimize sum_pow_L;

output ["approx_blocks = \((sum(alu_cost_per_edge) +
sum(cost_multiplier_per_v))/NMAX) \n",
  "tot_cost = \(tot_cost)\n",
  "T = \(T)\n",
  "L = \(L)\n",
  "alu_cost_per_edge= \(alu_cost_per_edge)\n",
  "effective_succ_in_same_T = \(effective_succ_in_same_T)\n",
  "input_cost_per_edge = \(input_cost_per_edge)\n",
  "cost_multiplier_per_v = \(cost_multiplier_per_v)\n",
  ];


