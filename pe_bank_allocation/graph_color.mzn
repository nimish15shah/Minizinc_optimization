
int: N;
enum NODES;
int :E;
array[1..E, 1..2] of NODES: edges;

int: MAX_R; % the last MAX_R value is for dummy reg
set of int: REG = 1..MAX_R;
array[NODES] of var REG: reg_map:: outdomain_max;

var 0..20: total_unallocated = count(r in reg_map)(r = MAX_R);
array[REG] of var 0..N: allocation_cnt;

constraint forall(e in 1..E) (
              reg_map[edges[e,1]] = MAX_R \/ (reg_map[edges[e,1]] !=
              reg_map[edges[e,2]])
            ) :: outdomain_max;

constraint forall(r in REG) (
              allocation_cnt[r] = count(r1 in reg_map) (r1= r)
          );

ann: search_ann;
search_ann = int_search(reg_map, first_fail, indomain_random);

%annotation outdomain_max(reg_map);

%solve :: search_ann minimize 10*total_unallocated + max(allocation_cnt);            
%solve :: search_ann minimize total_unallocated;            

solve ::  seq_search ( [search_ann,
        int_search(allocation_cnt, first_fail, indomain_random),
    ] ) 
    minimize total_unallocated;            

output [ 
    "total_unallocated = \(total_unallocated) \n",
    "allocation_cnt= \(allocation_cnt)"
  ];
