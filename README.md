
<a id='Combinat'></a>

<a id='Combinat-1'></a>

# Combinat

- [Combinat](index.md#Combinat)

<a id='Combinat' href='#Combinat'>#</a>
**`Combinat`** &mdash; *Module*.



This  module is  a Julia  port of  some GAP  combinatorics and basic number theory. The only dependency is the package `Primes`.

The list of functions it exports are:

Classical enumerations:

`combinations, arrangements, partitions, partition_tuples,  compositions, multisets`

functions to count them without computing them:

`ncombinations, narrangements, npartitions, npartition_tuples,   ncompositions, nmultisets`

some functions on partitions and permutations:

`lcm_partitions, gcd_partitions, conjugate_partition, dominates, tableaux,  robinson_schensted`

counting functions:

`bell, stirling1, stirling2, catalan`

number theory

`divisors, prime_residues, primitiveroot, bernoulli`

some structural manipulations not yet in Julia:

`groupby, tally, tally_sorted, collectby, unique_sorted!`

matrix blocks:

`blocks, diagblocks`

Have  a  look  at  the  individual  docstrings  and  enjoy (any feedback is welcome).  

After   writing  most  of  this  module  I  became  aware  of  the  package `Combinatorics`  which has a  considerable overlap. However  there are some fundamental   disagreements   between   these   two  packages  which  makes `Combinatorics` not easily usable for me:

  * often I  use sorting  in algorithms  when `Combinatorics`  use hashing. Thus  the algorithms cannot be applied to the same objects (and sorting is  often  faster).  I  provide  optionally  a  hashing variant of some algorithms.
  * `Combinatorics.combinations` does not include the empty set.
  * I use lower case for functions and Camel case for structs (Iterators). `Combinatorics`  does not have functions for classical enumerations but only (lowercase) iterators.

Some  less fundamental  disagreements is  disagreement on  names. However I would  welcome discussions  with the  authors of  `Combinatorics` to see if both packages could be made more compatible.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1-L60' class='documenter-source'>source</a><br>

<a id='Combinat.combinations' href='#Combinat.combinations'>#</a>
**`Combinat.combinations`** &mdash; *Function*.



`combinations(mset[,k];dict=false)`

`ncombinations(mset[,k];dict=false)`

`combinations`   returns  all  combinations  of   the  multiset  `mset`  (a collection  or  iterable  with  possible  repetitions). If a second integer argument  `k` is given, it returns  the combinations with `k` elements. `k` may  also be a vector  of integers, then it  returns the combinations whose number of elements is one of these integers.

`ncombinations` returns the number of combinations.

A  *combination* is an unordered subsequence.

By  default, the elements of `mset`  are assumed sortable and a combination is  represented by a sorted `Vector`.  The combinations with a fixed number `k`  of  elements  are  listed  in  lexicographic order. If the elements of `mset`  are not sortable but hashable, the keyword `dict=true` can be given and the (slightly slower) computation is done using a `Dict`.

If  `mset` has  no repetitions,  the list  of all  combinations is just the *powerset* of `mset`.

```julia-repl
julia> ncombinations([1,2,2,3])
12

julia> combinations([1,2,2,3])
12-element Vector{Vector{Int64}}:
 []
 [1]
 [2]
 [3]
 [1, 2]
 [1, 3]
 [2, 2]
 [2, 3]
 [1, 2, 2]
 [1, 2, 3]
 [2, 2, 3]
 [1, 2, 2, 3]
```

The  combinations  are  implemented  by an iterator `Combinat.Combinations` which can enumerate the combinations of a large multiset.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L370-L415' class='documenter-source'>source</a><br>

<a id='Combinat.Combinations' href='#Combinat.Combinations'>#</a>
**`Combinat.Combinations`** &mdash; *Type*.



`Combinat.Combinations(s[,k])`   is  an   iterator  which   enumerates  the combinations  of  the  multiset  `s`  (with  `k`  elements  if `k`given) in lexicographic  order. The elements of `s` must be sortable. If they are not but  hashable giving  the keyword  `dict=true` will  give an iterator for a non-sorted result.

```julia-repl
julia> a=Combinat.Combinations(1:4);

julia> collect(a)
16-element Vector{Vector{Int64}}:
 []
 [1]
 [2]
 [3]
 [4]
 [1, 2]
 [1, 3]
 [1, 4]
 [2, 3]
 [2, 4]
 [3, 4]
 [1, 2, 3]
 [1, 2, 4]
 [1, 3, 4]
 [2, 3, 4]
 [1, 2, 3, 4]

julia> a=Combinat.Combinations([1,2,2,3,4,4],3)
Combinations([1, 2, 2, 3, 4, 4],3)

julia> collect(a)
10-element Vector{Vector{Int64}}:
 [1, 2, 2]
 [1, 2, 3]
 [1, 2, 4]
 [1, 3, 4]
 [1, 4, 4]
 [2, 2, 3]
 [2, 2, 4]
 [2, 3, 4]
 [2, 4, 4]
 [3, 4, 4]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L261-L305' class='documenter-source'>source</a><br>

<a id='Combinat.arrangements' href='#Combinat.arrangements'>#</a>
**`Combinat.arrangements`** &mdash; *Function*.



`arrangements(mset[,k])`

`narrangements(mset[,k])`

`arrangements`  returns  the  arrangements  of  the  multiset `mset` (a not necessarily  sorted  collection  with  possible  repetitions).  If a second argument   `k`  is  given,  it  returns  arrangements  with  `k`  elements. `narrangements` returns the number of arrangements.

An  *arrangement*  of  `mset`  is  a  subsequence taken in arbitrary order, representated as a `Vector`. It is also called a permutation.

As  an example of arrangements  of a multiset, think  of the game Scrabble. Suppose  you have the six  characters of the word  'settle' and you have to make a four letter word. Then the possibilities are given by

```julia-repl
julia> narrangements(collect("settle"),4)
102
```

while all possible words (including the empty one) are:

```julia-repl
julia> narrangements(collect("settle"))
523
```

The  result returned  by 'arrangements'  is sorted  (the elements of `mset` must  be sortable), which means in  this example that the possibilities are listed  in the same  order as they  appear in the  dictionary. Here are the two-letter words:

```julia-repl
julia> String.(arrangements(collect("settle"),2))
14-element Vector{String}:
 "ee"
 "el"
 "es"
 "et"
 "le"
 "ls"
 "lt"
 "se"
 "sl"
 "st"
 "te"
 "tl"
 "ts"
 "tt"
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L435-L485' class='documenter-source'>source</a><br>

<a id='Combinat.partitions' href='#Combinat.partitions'>#</a>
**`Combinat.partitions`** &mdash; *Function*.



`partitions(n::Integer[,k])`

`npartitions(n::Integer[,k])`

`partitions`  returns in lexicographic order the partitions (with `k` parts if  `k`  is  given)  of  the  positive  integer `n` . `npartitions` returns (faster) the number of partitions.

There are approximately `exp(π√(2n/3))/(4√3 n)` partitions of `n`.

A   *partition*  is   a  decomposition   `n=p₁+p₂+…+pₖ`  in  integers  with `p₁≥p₂≥…≥pₖ>0`, and is represented by the vector `p=[p₁,p₂,…,pₖ]`. We write `p⊢n`.

```julia-repl
julia> npartitions(7)
15

julia> partitions(7)
15-element Vector{Vector{Int64}}:
 [1, 1, 1, 1, 1, 1, 1]
 [2, 1, 1, 1, 1, 1]
 [2, 2, 1, 1, 1]
 [2, 2, 2, 1]
 [3, 1, 1, 1, 1]
 [3, 2, 1, 1]
 [3, 2, 2]
 [3, 3, 1]
 [4, 1, 1, 1]
 [4, 2, 1]
 [4, 3]
 [5, 1, 1]
 [5, 2]
 [6, 1]
 [7]

julia> npartitions(7,3)
4

julia> partitions(7,3)
4-element Vector{Vector{Int64}}:
 [3, 2, 2]
 [3, 3, 1]
 [4, 2, 1]
 [5, 1, 1]
```

The partitions are implemented by an iterator `Combinat.Partitions` which can be used to enumerate the partitions of a large number.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L658-L708' class='documenter-source'>source</a><br>


`partitions(n::Integer,set::AbstractVector[,k])`   

`npartitions(n::Integer,set::AbstractVector[,k])`   

returns  the list  of partitions  of `n`  (with `k`  parts if `k` is given) restricted  to have parts in `set`. `npartitions` gives (faster) the number of such partitions.

Let  us show how many ways there are to pay 17 cents using coins of 2,5 and 10 cents.

```julia-repl
julia> npartitions(17,[10,5,2])
3

julia> partitions(17,[10,5,2])
3-element Vector{Vector{Int64}}:
 [5, 2, 2, 2, 2, 2, 2]
 [5, 5, 5, 2]
 [10, 5, 2]

julia> npartitions(17,[10,5,2],3) # pay with 3 coins
1

julia> partitions(17,[10,5,2],3) 
1-element Vector{Vector{Int64}}:
 [10, 5, 2]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L742-L770' class='documenter-source'>source</a><br>


`partitions(set::AbstractVector[,k])`

`npartitions(set::AbstractVector[,k])`

the  set of all unordered  partitions (in `k` sets  if `k` is given) of the set  `set` (a  collection without  repetitions). `npartitions`  returns the number of unordered partitions.

An *unordered partition* of `set` is a set of pairwise disjoints sets whose union is equal to `set`, and is represented by a Vector of Vectors.

```julia-repl
julia> npartitions(1:3)
5

julia> partitions(1:3)
5-element Vector{Vector{Vector{Int64}}}:
 [[1, 2, 3]]
 [[1, 2], [3]]
 [[1, 3], [2]]
 [[1], [2, 3]]
 [[1], [2], [3]]

julia> npartitions(1:4,2)
7

julia> partitions(1:4,2)
7-element Vector{Vector{Vector{Int64}}}:
 [[1, 2, 3], [4]]
 [[1, 2, 4], [3]]
 [[1, 2], [3, 4]]
 [[1, 3, 4], [2]]
 [[1, 3], [2, 4]]
 [[1, 4], [2, 3]]
 [[1], [2, 3, 4]]
```

Note  that there is currently no ordered or multiset counterpart.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L855-L893' class='documenter-source'>source</a><br>

<a id='Combinat.Partitions' href='#Combinat.Partitions'>#</a>
**`Combinat.Partitions`** &mdash; *Type*.



`Combinat.Partitions(n[,k])` is an iterator which enumerates the partitions of `n` (with `k`part if `k`given) in lexicographic order.

```julia-repl
julia> a=Combinat.Partitions(5)
Partitions(5)

julia> collect(a)
7-element Vector{Vector{Int64}}:
 [1, 1, 1, 1, 1]
 [2, 1, 1, 1]
 [2, 2, 1]
 [3, 1, 1]
 [3, 2]
 [4, 1]
 [5]

julia> a=Combinat.Partitions(10,3)
Partitions(10,3)

julia> collect(a)
8-element Vector{Vector{Int64}}:
 [4, 3, 3]
 [4, 4, 2]
 [5, 3, 2]
 [5, 4, 1]
 [6, 2, 2]
 [6, 3, 1]
 [7, 2, 1]
 [8, 1, 1]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L567-L598' class='documenter-source'>source</a><br>

<a id='Combinat.partition_tuples' href='#Combinat.partition_tuples'>#</a>
**`Combinat.partition_tuples`** &mdash; *Function*.



`partition_tuples(n,r)`

`npartition_tuples(n,r)`

the `r`-tuples of partitions that together partition `n`. `npartition_tuples` is the number of partition tuples.

```julia-repl
julia> npartition_tuples(3,2)
10

julia> partition_tuples(3,2)
10-element Vector{Vector{Vector{Int64}}}:
 [[1, 1, 1], []]
 [[1, 1], [1]]
 [[1], [1, 1]]
 [[], [1, 1, 1]]
 [[2, 1], []]
 [[1], [2]]
 [[2], [1]]
 [[], [2, 1]]
 [[3], []]
 [[], [3]]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1074-L1099' class='documenter-source'>source</a><br>

<a id='Combinat.compositions' href='#Combinat.compositions'>#</a>
**`Combinat.compositions`** &mdash; *Function*.



`compositions(n[,k];min=1)`

`ncompositions(n[,k])`

This  function returns the compositions of  `n` (the compositions of length `k`  if a second argument `k` is given), where a composition of the integer `n`  is a decomposition `n=p₁+…+pₖ` in  integers `≥min`, represented as the vector  `[p₁,…,pₖ]`. Unless  `k` is  given, `min`  must be  `>0`. There are $2^{n-1}$  compositions of `n` in  integers `≥1`, and `binomial(n-1,k-1)` compositions  of `n` in  `k` parts `≥1`.  Compositions are sometimes called ordered   partitions.  `ncompositions`  returns   (faster)  the  number  of compositions but is implemented only in the case `min=1`.

```julia-repl
julia> ncompositions(4)
8

julia> compositions(4)
8-element Vector{Vector{Int64}}:
 [1, 1, 1, 1]
 [2, 1, 1]
 [1, 2, 1]
 [3, 1]
 [1, 1, 2]
 [2, 2]
 [1, 3]
 [4]

julia> ncompositions(4,2)
3

julia> compositions(4,2)
3-element Vector{Vector{Int64}}:
 [3, 1]
 [2, 2]
 [1, 3]

julia> compositions(4,2;min=0)
5-element Vector{Vector{Int64}}:
 [4, 0]
 [3, 1]
 [2, 2]
 [1, 3]
 [0, 4]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1145-L1191' class='documenter-source'>source</a><br>

<a id='Combinat.multisets' href='#Combinat.multisets'>#</a>
**`Combinat.multisets`** &mdash; *Function*.



`multisets(set,k)`

`nmultisets(set,k)`

`multisets`  returns  the  set  of  all  multisets of length `k` made of elements   of   the   set   `set`   (a   collection  without  repetitions). `nmultisets` returns the number of multisets.

An  *multiset* of length `k` is  an unordered selection with repetitions of length  `k` from `set` and is represented  by a sorted vector of length `k` made  of elements  from `set`  (it is  also sometimes called a "combination with replacement").

```julia-repl
julia> multisets(1:4,3)
20-element Vector{Vector{Int64}}:
 [1, 1, 1]
 [1, 1, 2]
 [1, 1, 3]
 [1, 1, 4]
 [1, 2, 2]
 [1, 2, 3]
 [1, 2, 4]
 [1, 3, 3]
 [1, 3, 4]
 [1, 4, 4]
 [2, 2, 2]
 [2, 2, 3]
 [2, 2, 4]
 [2, 3, 3]
 [2, 3, 4]
 [2, 4, 4]
 [3, 3, 3]
 [3, 3, 4]
 [3, 4, 4]
 [4, 4, 4]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1207-L1245' class='documenter-source'>source</a><br>

<a id='Combinat.lcm_partitions' href='#Combinat.lcm_partitions'>#</a>
**`Combinat.lcm_partitions`** &mdash; *Function*.



`lcm_partitions(p1,…,pn)`

each  argument is  a partition  of the  same set  `S`, given  as a  list of disjoint  vectors whose  union is  `S`. Equivalently  each argument  can be interpreted as an equivalence relation on `S`.

The result is the finest partition of `S` such that each argument partition refines it. It represents the 'or' of the equivalence relations represented by the arguments.

```julia-repl
julia> lcm_partitions([[1,2],[3,4],[5,6]],[[1],[2,5],[3],[4],[6]])
2-element Vector{Vector{Int64}}:
 [1, 2, 5, 6]
 [3, 4]      
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1297-L1314' class='documenter-source'>source</a><br>

<a id='Combinat.gcd_partitions' href='#Combinat.gcd_partitions'>#</a>
**`Combinat.gcd_partitions`** &mdash; *Function*.



`gcd_partitions(p1,…,pn)`

Each  argument is  a partition  of the  same set  `S`, given  as a  list of disjoint  vectors whose  union is  `S`. Equivalently  each argument  can be interpreted as an equivalence relation on `S`.

The result is the coarsest partition which refines all argument partitions. It  represents the  'and' of  the equivalence  relations represented by the arguments.

```julia-repl
julia> gcd_partitions([[1,2],[3,4],[5,6]],[[1],[2,5],[3],[4],[6]])
6-element Vector{Vector{Int64}}:
 [1]
 [2]
 [3]
 [4]
 [5]
 [6]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1330-L1351' class='documenter-source'>source</a><br>

<a id='Combinat.conjugate_partition' href='#Combinat.conjugate_partition'>#</a>
**`Combinat.conjugate_partition`** &mdash; *Function*.



`conjugate_partition(λ)`

returns  the  conjugate  partition  of  the  partition  `λ`,  that  is, the partition having the transposed of the Young diagram of `λ`.

```julia-repl
julia> conjugate_partition([4,2,1])
4-element Vector{Int64}:
 3
 2
 1
 1

julia> conjugate_partition([6])
6-element Vector{Int64}:
 1
 1
 1
 1
 1
 1
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1478-L1501' class='documenter-source'>source</a><br>

<a id='Combinat.dominates' href='#Combinat.dominates'>#</a>
**`Combinat.dominates`** &mdash; *Function*.



`dominates(λ,μ)`

The  dominance  order  on  partitions  is  an  important  partial  order in representation theory. `λ` dominates `μ` if and only if for all `i` we have `sum(λ[1:i])≥sum(μ[1:i])`.

```julia-repl
julia> dominates([5,4],[4,4,1])
true
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1509-L1520' class='documenter-source'>source</a><br>

<a id='Combinat.tableaux' href='#Combinat.tableaux'>#</a>
**`Combinat.tableaux`** &mdash; *Function*.



`tableaux(S)`

if  `S`  is  a  partition  tuple,  returns  the  list  of standard tableaux associated  to the partition tuple `S`, that is a filling of the associated young  diagrams  with  the  numbers  `1:sum(sum,S)`  such  that the numbers increase across the rows and down the columns.

If  `S` is a single partition, the standard tableaux for that partition are returned.

```julia-repl
julia> tableaux([[2,1],[1]])
8-element Vector{Vector{Vector{Vector{Int64}}}}:
 [[[1, 2], [3]], [[4]]]
 [[[1, 2], [4]], [[3]]]
 [[[1, 3], [2]], [[4]]]
 [[[1, 3], [4]], [[2]]]
 [[[1, 4], [2]], [[3]]]
 [[[1, 4], [3]], [[2]]]
 [[[2, 3], [4]], [[1]]]
 [[[2, 4], [3]], [[1]]]

julia> tableaux([2,2])
2-element Vector{Vector{Vector{Int64}}}:
 [[1, 2], [3, 4]]
 [[1, 3], [2, 4]]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1529-L1557' class='documenter-source'>source</a><br>

<a id='Combinat.robinson_schensted' href='#Combinat.robinson_schensted'>#</a>
**`Combinat.robinson_schensted`** &mdash; *Function*.



`robinson_schensted(p::AbstractVector{<:Integer})`

returns  the pair of standard tableaux associated to the permutation `p` by the Robinson-Schensted correspondence.

```julia-repl
julia> robinson_schensted([2,3,4,1])
([[1, 3, 4], [2]], [[1, 2, 3], [4]])
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1574-L1584' class='documenter-source'>source</a><br>

<a id='Combinat.bell' href='#Combinat.bell'>#</a>
**`Combinat.bell`** &mdash; *Function*.



'bell(n)'

The  Bell numbers are  defined by `bell(0)=1`  and $bell(n+1)=∑_{k=0}^n {n \choose  k}bell(k)$, or by the fact  that `bell(n)/n!` is the coefficient of `xⁿ` in the formal series `e^(eˣ-1)`.

```julia-repl
julia> bell.(0:6)
7-element Vector{Int64}:
   1
   1
   2
   5
  15
  52
 203

julia> bell(14)
190899322

julia> bell(big(30))
846749014511809332450147
```

julia-repl


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1014-L1038' class='documenter-source'>source</a><br>

<a id='Combinat.stirling1' href='#Combinat.stirling1'>#</a>
**`Combinat.stirling1`** &mdash; *Function*.



`stirling1(n,k)`

the  *Stirling  numbers  of  the  first  kind*  `S₁(n,k)`  are  defined  by `S₁(0,0)=1,   S₁(n,0)=S₁(0,k)=0`   if   `n,   k!=0`   and   the  recurrence `S₁(n,k)=(n-1)S₁(n-1,k)+S₁(n-1,k-1)`.

`S₁(n,k)`  is the  number of  permutations of  `n` points  with `k` cycles. They   are   also   given   by   the   generating  function  $n!{x\choose n}=\sum_{k=0}^n(S₁(n,k) x^k)$. Note the similarity to $x^n=\sum_{k=0}^n S₂(n,k)k!{x\choosek}$  (see  `stirling2`).  Also  the  definition of `S₁` implies  `S₁(n,k)=S₂(-k,-n)` if  `n,k<0`. There  are many formulae relating Stirling  numbers of the first kind to Stirling numbers of the second kind, Bell numbers, and Binomial numbers.

```julia-repl
julia> stirling1.(4,0:4) # Knuth calls this the trademark of S₁
5-element Vector{Int64}:
  0
  6
 11
  6
  1

julia> [stirling1(n,k) for n in 0:6, k in 0:6] # similar to Pascal's triangle
7×7 Matrix{Int64}:
 1    0    0    0   0   0  0
 0    1    0    0   0   0  0
 0    1    1    0   0   0  0
 0    2    3    1   0   0  0
 0    6   11    6   1   0  0
 0   24   50   35  10   1  0
 0  120  274  225  85  15  1

julia> stirling1(50,big(10)) # give `big` second argument to avoid overflow
101623020926367490059043797119309944043405505380503665627365376
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L913-L950' class='documenter-source'>source</a><br>

<a id='Combinat.stirling2' href='#Combinat.stirling2'>#</a>
**`Combinat.stirling2`** &mdash; *Function*.



`stirling2(n,k)`

the  *Stirling  numbers  of  the  second  kind* are defined by `S₂(0,0)=1`, `S₂(n,0)=S₂(0,k)=0` if `n, k!=0` and `S₂(n,k)=k S₂(n-1,k)+S₂(n-1,k-1)`, and also as coefficients of the generating function $x^n=\sum_{k=0}^{n}S₂(n,k) k!{x\choose k}$.

```julia-repl
julia> stirling2.(4,0:4)  # Knuth calls this the trademark of S₂
5-element Vector{Int64}:
 0
 1
 7
 6
 1

julia> [stirling2(i,j) for i in 0:6, j in 0:6] # similar to Pascal's triangle
7×7 Matrix{Int64}:
 1  0   0   0   0   0  0 
 0  1   0   0   0   0  0
 0  1   1   0   0   0  0
 0  1   3   1   0   0  0
 0  1   7   6   1   0  0
 0  1  15  25  10   1  0
 0  1  31  90  65  15  1

julia> stirling2(50,big(10)) # give `big` second argument to avoid overflow
26154716515862881292012777396577993781727011
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L966-L996' class='documenter-source'>source</a><br>

<a id='Combinat.catalan-Tuple{Integer}' href='#Combinat.catalan-Tuple{Integer}'>#</a>
**`Combinat.catalan`** &mdash; *Method*.



`Catalan(n)` `n`-th Catalan Number

```julia-repl
julia> catalan(8)
1430

julia> catalan(big(50))
1978261657756160653623774456
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1359-L1369' class='documenter-source'>source</a><br>

<a id='Combinat.groupby' href='#Combinat.groupby'>#</a>
**`Combinat.groupby`** &mdash; *Function*.



`groupby(v,l)`

group  elements of collection `l` according  to the corresponding values in the collection `v` (which should have same length as `l`).

```julia-rep1
julia> groupby([31,28,31,30,31,30,31,31,30,31,30,31],
  [:Jan,:Feb,:Mar,:Apr,:May,:Jun,:Jul,:Aug,:Sep,:Oct,:Nov,:Dec])
Dict{Int64,Vector{Symbol}} with 3 entries:
  31 => Symbol[:Jan, :Mar, :May, :Jul, :Aug, :Oct, :Dec]
  28 => Symbol[:Feb]
  30 => Symbol[:Apr, :Jun, :Sep, :Nov]
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L74-L88' class='documenter-source'>source</a><br>


`groupby(f::Function,l)`

group  elements of collection `l` according to the values taken by function `f` on them. The values of `f` must be hashable.

```julia-repl
julia> groupby(iseven,1:10)
Dict{Bool, Vector{Int64}} with 2 entries:
  0 => [1, 3, 5, 7, 9]
  1 => [2, 4, 6, 8, 10]
```

Note:  keys of the result will  have type `Any` if `l`  is empty since I do not know how to access the return type of a function


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L95-L109' class='documenter-source'>source</a><br>

<a id='Combinat.tally' href='#Combinat.tally'>#</a>
**`Combinat.tally`** &mdash; *Function*.



`tally(v;dict=false)`

counts how many times each element of collection or iterable `v` occurs and returns a sorted `Vector` of `elt=>count` (a variation on StatsBase.countmap).  By default the  elements of `v`  must be sortable; if they  are not but hashable, giving the keyword `dict=true` uses a `Dict` to build (slightly slower) a non sorted result.

```julia-repl
julia> tally("a tally test")
7-element Vector{Pair{Char, Int64}}:
 ' ' => 2
 'a' => 2
 'e' => 1
 'l' => 2
 's' => 1
 't' => 3
 'y' => 1
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L157-L177' class='documenter-source'>source</a><br>

<a id='Combinat.tally_sorted' href='#Combinat.tally_sorted'>#</a>
**`Combinat.tally_sorted`** &mdash; *Function*.



`tally_sorted(v)`

`tally_sorted`  is like `tally`  but works only  for a sorted iterable. The point is that it is *very* fast.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L119-L124' class='documenter-source'>source</a><br>

<a id='Combinat.collectby' href='#Combinat.collectby'>#</a>
**`Combinat.collectby`** &mdash; *Function*.



`collectby(f,v)`

group  the elements of `v` in packets  (`Vector`s) where `f` takes the same value.  The resulting `Vector{Vector}` is sorted  by the values of `f` (the values  of  `f`  must  be  sortable;  otherwise  you  can  use  the  slower `values(groupby(f,v))`).  Here `f` can  be a function  of one variable or a collection of same length as `v`.

```julia-repl
julia> l=[:Jan,:Feb,:Mar,:Apr,:May,:Jun,:Jul,:Aug,:Sep,:Oct,:Nov,:Dec];

julia> collectby(x->first(string(x)),l)
8-element Vector{Vector{Symbol}}:
 [:Apr, :Aug]
 [:Dec]
 [:Feb]
 [:Jan, :Jun, :Jul]
 [:Mar, :May]
 [:Nov]
 [:Oct]
 [:Sep]

julia> collectby("JFMAMJJASOND",l)
8-element Vector{Vector{Symbol}}:
 [:Apr, :Aug]
 [:Dec]
 [:Feb]
 [:Jan, :Jun, :Jul]
 [:Mar, :May]
 [:Nov]
 [:Oct]
 [:Sep]
```

julia-repl


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L186-L221' class='documenter-source'>source</a><br>

<a id='Combinat.unique_sorted!' href='#Combinat.unique_sorted!'>#</a>
**`Combinat.unique_sorted!`** &mdash; *Function*.



faster than unique! for sorted vectors


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L247' class='documenter-source'>source</a><br>

<a id='Combinat.diagblocks' href='#Combinat.diagblocks'>#</a>
**`Combinat.diagblocks`** &mdash; *Function*.



`diagblocks(M::Matrix)`

`M`  should  be  a  square  matrix.  Define  a  graph  `G`  with vertices `1:size(M,1)` and with an edge between `i`  and `j` if either `M[i,j]` or `M[j,i]` is not zero or `false`. `diagblocks` returns a vector of vectors `I`  such that  `I[1]`,`I[2]`, etc..  are the  vertices in each connected component  of `G`.  In other  words, `M[I[1],I[1]]`,`M[I[2],I[2]]`,etc... are diagonal blocks of `M`.

```julia-repl
julia> m=[0 0 0 1;0 0 1 0;0 1 0 0;1 0 0 0]
4×4 Matrix{Int64}:
 0  0  0  1
 0  0  1  0
 0  1  0  0
 1  0  0  0

julia> diagblocks(m)
2-element Vector{Vector{Int64}}:
 [1, 4]
 [2, 3]

julia> m[[1,4],[1,4]]
2×2 Matrix{Int64}:
 0  1
 1  0
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1372-L1400' class='documenter-source'>source</a><br>

<a id='Combinat.blocks-Tuple{AbstractMatrix}' href='#Combinat.blocks-Tuple{AbstractMatrix}'>#</a>
**`Combinat.blocks`** &mdash; *Method*.



`blocks(M:AbstractMatrix)`

Finds  if the  matrix  `M` admits a block decomposition.

Define  a bipartite  graph `G`  with vertices  `axes(M,1)`, `axes(M,2)` and with an edge between `i` and `j` if `M[i,j]` is not zero. BlocksMat returns a  list of pairs of  lists `I` such that  `I[i]`, etc.. are the vertices in the `i`-th connected component of `G`. In other words, `M[I[1][1],I[1][2]], M[I[2][1],I[2][2]]`,etc... are blocks of `M`.

This  function may  also be  applied to  boolean matrices.

```julia-repl
julia> m=[1 0 0 0;0 1 0 0;1 0 1 0;0 0 0 1;0 0 1 0]
5×4 Matrix{Int64}:
 1  0  0  0
 0  1  0  0
 1  0  1  0
 0  0  0  1
 0  0  1  0

julia> blocks(m)
3-element Vector{Tuple{Vector{Int64}, Vector{Int64}}}:
 ([1, 3, 5], [1, 3])
 ([2], [2])
 ([4], [4])

julia> m[[1,3,5,2,4],[1,3,2,4]]
5×4 Matrix{Int64}:
 1  0  0  0
 1  1  0  0
 0  1  0  0
 0  0  1  0
 0  0  0  1
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1417-L1453' class='documenter-source'>source</a><br>

<a id='Combinat.bernoulli' href='#Combinat.bernoulli'>#</a>
**`Combinat.bernoulli`** &mdash; *Function*.



`bernoulli(n)` the `n`-th *Bernoulli number*  `Bₙ` as a `Rational{BigInt}`

`Bₙ` is defined by $B₀=1, B_n=-\sum_{k=0}^{n-1}((n+1\choose k)B_k)/(n+1)$. `Bₙ/n!` is the coefficient of  `xⁿ` in the power series of  `x/(eˣ-1)`. Except for `B₁=-1/2`  the Bernoulli numbers for odd indices are zero.

```julia_repl
julia> Combinat.bernoulli(4)
-1//30

julia> Combinat.bernoulli(10)
5//66

julia> Combinat.bernoulli(12) # there is no simple pattern in Bernoulli numbers
-691//2730

julia> Combinat.bernoulli(50) # and they grow fairly fast
495057205241079648212477525//66
```


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1659-L1679' class='documenter-source'>source</a><br>

<a id='Combinat.prime_residues' href='#Combinat.prime_residues'>#</a>
**`Combinat.prime_residues`** &mdash; *Function*.



`prime_residues(n)` the numbers less than `n` and prime to `n` 


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1622' class='documenter-source'>source</a><br>

<a id='Combinat.primitiveroot' href='#Combinat.primitiveroot'>#</a>
**`Combinat.primitiveroot`** &mdash; *Function*.



`primitiveroot(m::Integer)` a primitive root `mod. m`,   that is generating multiplicatively `prime_residues(m)`.   It exists if `m` is of the form `4`, `2p^a` or `p^a` for `p` prime>2.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1638-L1642' class='documenter-source'>source</a><br>

<a id='Combinat.divisors' href='#Combinat.divisors'>#</a>
**`Combinat.divisors`** &mdash; *Function*.



`divisors(n)` the increasing list of divisors of `n`.


<a target='_blank' href='https://github.com/jmichel7/Combinat.jl/blob/dc0e205c187d61a8fac6f6168994c1371f3cc1ce/src/Combinat.jl#L1632' class='documenter-source'>source</a><br>

