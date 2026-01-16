"""
This  module  started  as  a  Julia  port of combinatorics and basic number
theory  functions  from  GAP.  See  comments  below  on  how it compares to
`Combinatorics.jl`. The only dependency is the `Primes` package.

The list of functions it exports are:

Classical enumerations:

[`combinations`](@ref),
[`arrangements`](@ref),
[`permutations`](@ref),
[`partitions`](@ref),
[`compositions`](@ref),
[`partition_tuples`](@ref),
[`multisets`](@ref)

the  first five of them  are implemented by iterators,  which have the same
name but capitalized. This allows to do itemwise computations on very large
enumerations without allocating memory:

[`Combinations`](@ref),
[`Arrangements`](@ref),
[`Permutations`](@ref),
[`Partitions`](@ref),
[`Compositions`](@ref),

functions to count enumerations without computing them:

`ncombinations`,
`narrangements`,
`npermutations`,
`npartitions`,
`ncompositions`,
`npartition_tuples`,
`nmultisets`

some functions on partitions and tableaux:

[`lcm_partitions`](@ref),
[`gcd_partitions`](@ref),
[`conjugate_partition`](@ref),
[`dominates`](@ref),
[`tableaux`](@ref),
[`semistandard_tableaux`](@ref),
[`robinson_schensted`](@ref)

counting functions:

[`bell`](@ref),
[`stirling1`](@ref),
[`stirling2`](@ref),
[`catalan`](@ref),
[`bernoulli`](@ref)

number theory

[`prime_residues`](@ref),
[`primitiveroot`](@ref),
[`moebius`](@ref)

some structural manipulations not (yet?) in Julia:

[`groupby`](@ref),
[`tally`](@ref),
[`tally_sorted`](@ref),
[`collectby`](@ref),
[`unique_sorted!`](@ref),
[`union_sorted`](@ref),
[`intersect_sorted`](@ref),
[`symdiff_sorted`](@ref)

matrix blocks:

[`blocks`](@ref),
[`diagblocks`](@ref)

Have  a  look  at  the  individual  docstrings  and  enjoy (any feedback is
welcome).  

After  writing  most  of  this  module,  I  became  aware  of  the  package
`Combinatorics`  which has a  considerable overlap. However  there are some
discrepancies  between these  two packages  which make  `Combinatorics` not
a suitable replacement:

  - I often  use sorting  in algorithms  where `Combinatorics` uses hashing.
    So  the algorithms do  not always apply  to the same  types (sorting is
    often  faster). For  some algorithms,  I have  a keyword which lets you
    choose  a hashing variant. Here  hashable refers to a  type which has a
    `hash` method and sortable to a type which has an `isless` method.

  - `Combinatorics.combinations` does not include the empty subset.

  - I use lower  case for functions  that return enumerations  as a list and
    camel  case  for  iterators.  Many  enumerations  have  both  variants.
    `Combinatorics` has only one variant for enumerations, which is often a
    lowercase iterator.

  - `Combinatorics` has fewer enumerations.

A    less   fundamental   discrepancy   concerns   names.   For   instance,
`Combinatorics.multiset_combinations`   and   `Combinatorics.powerset`  are
cases   of  `Combinat.combinations`;  `Combinatorics.multiexponents`  is  a
special case of `Combinat.compositions`; `Combinatorics.integer_partitions`
is  a case  of `Combinat.partitions`; `Combinatorics.multiset_permutations`
is `Combinat.arrangements`. I would welcome discussions with the authors of
`Combinatorics` to see if the two packages could be made more compatible in
this respect.
"""
module Combinat
export Combinations, combinations, ncombinations, 
  Arrangements, arrangements, narrangements, 
  Permutations, permutations, npermutations,
  Partitions, partitions, npartitions, partition_tuples, npartition_tuples, 
  Compositions, compositions, ncompositions, multisets, nmultisets, 
  lcm_partitions, gcd_partitions, conjugate_partition, dominates, tableaux,
  semistandard_tableaux,  robinson_schensted,
  bell, stirling1, stirling2, catalan, bernoulli,
  groupby, tally, tally_sorted, collectby, unique_sorted!, intersect_sorted,
  union_sorted, symdiff_sorted, blocks, diagblocks, prime_residues, 
  primitiveroot, moebius

#--------------------- Structural manipulations -------------------
"""
`groupby(v,l)`

return  a  `Dict`  grouping  elements  of  collection  `l` according to the
corresponding  values in the collection `v`,  which should have same length
as `l`, and whose elements must be hashable.

```julia-rep1
julia> groupby([31,28,31,30,31,30,31,31,30,31,30,31],
  [:Jan,:Feb,:Mar,:Apr,:May,:Jun,:Jul,:Aug,:Sep,:Oct,:Nov,:Dec])
Dict{Int64,Vector{Symbol}} with 3 entries:
  31 => Symbol[:Jan, :Mar, :May, :Jul, :Aug, :Oct, :Dec]
  28 => Symbol[:Feb]
  30 => Symbol[:Apr, :Jun, :Sep, :Nov]
```
"""
function groupby(v,l)
  res=Dict{eltype(v),Vector{eltype(l)}}()
  for (k,val) in zip(v,l) push!(get!(res,k,empty(l)),val) end
  res
end

"""
`groupby(f::Function,l)`

return a `Dict` grouping elements of collection `l` according to the values
taken by function `f` on them. The values of `f` must be hashable.

```julia-repl
julia> groupby(iseven,1:10)
Dict{Bool, Vector{Int64}} with 2 entries:
  0 => [1, 3, 5, 7, 9]
  1 => [2, 4, 6, 8, 10]
```
Note:  keys of the result will  have type `Any` if `l`  is empty since I do
not know how to access the return type of a function
"""
function groupby(f::Function,l)
  if isempty(l) return Dict{Any,eltype(l)}() end
  res=Dict(f(l[1])=>[l[1]])
  for val in l[2:end]
    push!(get!(res,f(val),empty(l)),val)
  end
  res
end

"""
`tally(v;dict=false)`

counts how many times each element of collection or iterable `v` occurs and
returns a sorted `Vector` of `elt=>count` (a variant of
StatsBase.countmap).  By default the  elements of `v`  must be sortable; if
they  are not but hashable, giving the keyword `dict=true` uses a `Dict` to
build (much slower) an unsorted result.

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
"""
function tally(v::AbstractArray;dict=false)
  if dict
    res=Dict{eltype(v),Int}()
    for n in v 
      if haskey(res,n) res[n]+=1
      else res[n]=1
      end
    end
    collect(res)
  else tally_sorted(issorted(v) ? v : sort(v))
  end
end

tally(v::AbstractRange;k...)=v.=>1

tally(v;k...)=tally(collect(v);k...) # for iterables

struct Tally_sorted{T}
  v::Vector{T}
end

Base.IteratorSize(::Type{Tally_sorted{T}}) where T=Base.SizeUnknown()
Base.eltype(::Type{Tally_sorted{T}}) where T=Pair{T,Int}

@inline function Base.iterate(t::Tally_sorted)
  for i in eachindex(t.v)
    if i==length(t.v) || t.v[i]!=t.v[i+1] return (t.v[i]=>i,i+1) end
  end
end
    
@inline function Base.iterate(t::Tally_sorted,j)
  for i in j:length(t.v)
    if i==length(t.v) || t.v[i]!=t.v[i+1] return (t.v[i]=>i-j+1,i+1) end
  end
end

"""
`tally_sorted(v)`

`tally_sorted`  is like `tally`  but works only  for a sorted iterable. The
point is that it is very fast.
```julia-repl
julia> tally_sorted("aabbbeee")
3-element Vector{Pair{Char, Int64}}:
 'a' => 2
 'b' => 3
 'e' => 3
```
"""
function tally_sorted(v)
  res=Pair{eltype(v),Int}[]
  fp=iterate(v)
  if isnothing(fp) return res end
  prev,state=fp
  c=1
  while true
    fp=iterate(v,state)
    if isnothing(fp)
      push!(res,prev=>c)
      return res
    end
    n,state=fp
    if n==prev c+=1
    else push!(res,prev=>c)
      prev=n
      c=1
    end
  end
  res
end

"""
`collectby(f,v)`

group  the elements of `v` in packets  (`Vector`s) where `f` takes the same
value.  The resulting `Vector{Vector}` is sorted  by the values of `f` (the
values  of  `f`  must  be  sortable;  otherwise  you  can  use  the  slower
`values(groupby(f,v))`).  Here `f` can  be a function  of one variable or a
collection of same length as `v`.

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

"""
function collectby(f,v)
  res=Vector{eltype(v)}[]
  if isempty(v) return res end
  l=f isa Function ? [(f(x),x) for x in v] : collect(zip(f,v))
  sort!(l,by=first)
  push!(res,[last(first(l))])
  for i in 2:length(l)
    if first(l[i])==first(l[i-1]) push!(res[end],last(l[i]))
    else push!(res,[last(l[i])])
    end
  end
  res
end

"`unique_sorted!(v::Vector)` many times faster than unique! for sorted `v`"
function unique_sorted!(v::Vector)
  i=1
@inbounds  for j in 2:length(v)
    if v[j]!=v[i] i+=1; v[i]=v[j] end
  end
  resize!(v,i)
end

"""
`intersect_sorted(a,b)` 

intersects   `a`  and   `b`  assumed   to  be   both  sorted   and  without
repetitions(and  their elements sortable).  This is many  times faster than
`intersect`.
"""
function intersect_sorted(a,b)
  if !issorted(a) || !issorted(b) error("arguments should be sorted") end
  res=promote_type(eltype(a),eltype(b))[]
  sa=iterate(a)
  sb=iterate(b)
  while sa!==nothing && sb!==nothing
    ai,stata=sa
    bi,statb=sb
    if isless(ai,bi) sa=iterate(a,stata)
    elseif ai==bi 
      if isempty(res)||ai!=res[end] push!(res,ai) end
      sa=iterate(a,stata)
      sb=iterate(b,statb)
    else   sb=iterate(b,statb)
    end
  end
  res
end

"""
`union_sorted(a,b)` 

computes  the union of  `a` and `b`  assumed to be  both sorted and without
repetitions  (and their  elements sortable).  The result  is sorted, so may
differ from `union`; this function is many times faster than `union`.
"""
function union_sorted(a,b)
  if !issorted(a) || !issorted(b) error("arguments should be sorted") end
  la=length(a)
  lb=length(b)
  res=empty(a)
  res=similar(a,la+lb)
  ai=bi=1
  ri=0
@inbounds while ai<=la || bi<=lb
  if     ai>la res[ri+=1]=b[bi]; bi+=1
  elseif bi>lb res[ri+=1]=a[ai]; ai+=1
    else c=cmp(a[ai],b[bi])
      if     c>0 res[ri+=1]=b[bi]; bi+=1
      elseif c<0 res[ri+=1]=a[ai]; ai+=1
      else res[ri+=1]=a[ai]; ai+=1; bi+=1
      end
    end
  end
  resize!(res,ri)
end

"""
`symdiff_sorted(a,b)` 

computes  the symmetric difference of `a` and `b` assumed to be both sorted
and  without  repetitions  (and  their  elements  sortable).  The result is
sorted,  so may differ  from `symdiff`; this  function is many times faster
than `symdiff`.
"""
function symdiff_sorted(a,b)
  if !issorted(a) || !issorted(b) error("arguments should be sorted") end
  la=length(a)
  lb=length(b)
  res=empty(a)
  res=similar(a,la+lb)
  ai=bi=1
  ri=0
@inbounds while ai<=la || bi<=lb
  if     ai>la res[ri+=1]=b[bi]; bi+=1
  elseif bi>lb res[ri+=1]=a[ai]; ai+=1
    else c=cmp(a[ai],b[bi])
      if     c>0 res[ri+=1]=b[bi]; bi+=1
      elseif c<0 res[ri+=1]=a[ai]; ai+=1
      else ai+=1; bi+=1
      end
    end
  end
  resize!(res,ri)
end

#--------------------- combinations -------------------

"""
`Combinations(s[,k];dict=false)`  is an  iterator which enumerates
the  combinations of  the multiset  `s` (with  `k` elements if `k`given) in
lexicographic order. The elements of `s` must be sortable. If they are not,
but  hashable, giving the  keyword `dict=true` will  give an iterator which
enumerates the combinations in an unspecified order.
```julia-repl
julia> a=Combinations(1:4);

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

julia> a=Combinations([1,2,2,3,4,4],3)
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
"""
struct Combinations{T}
  m::Vector{Int} # multiplicities of elements of mset
  k::Int
  s::Vector{T}  # unique elements of mset
end

@inline function Base.iterate(S::Combinations)
  (;m,k,s)=S
  n=sum(m)
  if k>n return nothing end
  v=fill(0,k)
  u=1
  j=0
  for l in 1:k
    if j<m[u] j+=1 
    else u+=1;j=1
    end
    v[l]=u
  end
  s[v], v
end

Base.eltype(x::Combinations{T}) where T=Vector{T}
Base.IteratorSize(::Type{Combinations{T}}) where T=Base.SizeUnknown()
Base.show(io::IO,x::Combinations)=print(io,"Combinations(",vcat(fill.(x.s,x.m)...),",",x.k,")")

@inline function Base.iterate(S::Combinations,v)
  i=length(v)
  (;m,k,s)=S
  while i>0
    if (i==k && v[i]<length(m)) || (i<k && v[i]<v[i+1])
      u=v[i]+1
      j=0
      for l in i+1:k if v[l]==u j+=1 else break end end
      if j>=m[u] i-=1;continue end
      j=0
      for l in i:k
        if j<m[u] j+=1 
        else u+=1;j=1
        end
        v[l]=u
      end
      return s[v],v
      i=k;continue
    else i-=1;continue 
    end
  end
end

function Combinations(mset,k;kw...)
  t=tally(mset;kw...)
  Combinations(last.(t),k,first.(t))
end

function Combinations(mset,ll::AbstractVector=0:length(mset);kw...)
  tly=tally(mset;kw...)
  s=first.(tly)
  t=last.(tly)
  Iterators.flatten(Combinations(t,k,s) for k in ll)
end

"""
`combinations(mset[,k];dict=false)`,  `ncombinations(mset[,k];dict=false)`

`combinations`   returns  all  combinations  of   the  multiset  `mset`  (a
collection  or  iterable  with  possible  repetitions). If a second integer
argument  `k` is given, it returns  the combinations with `k` elements. `k`
may  also be a vector  of integers, then it  returns the combinations whose
number of elements is one of these integers.

`ncombinations` returns (faster) the number of combinations.

A  *combination* is an unordered subsequence.

By  default, the elements of `mset`  are assumed sortable and a combination
is  represented by a sorted `Vector`.  The combinations with a fixed number
`k`  of  elements  are  listed  in  lexicographic order. If the elements of
`mset`  are not sortable but hashable, the keyword `dict=true` can be given
and the (slightly slower) computation is done using a `Dict`.

If  `mset` has  no repetitions,  the list  of all  combinations is just the
*powerset* of `mset`.

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
The  combinations  are  implemented  by  an iterator [`Combinations`](@ref)
which can enumerate the combinations of a large multiset.
"""
combinations(x...;kw...)=collect(Combinations(x...;kw...))

@doc (@doc combinations) ncombinations
ncombinations(mset;kw...)=prod(1 .+last.(tally(mset;kw...)))

ncombinations(mset,k::AbstractVector)=sum(i->ncombinations(mset,i),k)

ncombinations(mset,k::Integer;kw...)=ncombinations2(sort(last.(tally(mset;kw...)),rev=true),k)

Base.length(S::Combinations)=ncombinations2(sort(S.m,rev=true),S.k)

function ncombinations2(mul,k)
  if k==0 return 1 end
  if isempty(mul) return 0 end
  if mul[1]==1 return binomial(length(mul),k) end
  res=0
  for i in 0:min(mul[1],k)
    res+=ncombinations2((@view mul[2:end]),k-i)
  end
  res
# sum(i->ncombinations2((@view mul[2:end]),k-i),0:min(mul[1],k)) # allocates
end

#--------------------- permutations -------------------
"""
`permutations(v::AbstractVector)`, `permutations(n::Int)`, `npermutations`

in  the first  form, the  elements of  `v` must  be sortable.  The function
returns  in lexicographic  order the  distinct permutations  of the  set or
multiset `v`.  This   is  the  same   as  `arrangements(v,length(v))`.  

The second form is the same as `permutations(1:n)`.

`permutations` is implemented by an iterator `Permutations`.

`npermutations` counts the permutations (fast) without computing them.

```julia-repl
julia> permutations(3)
6-element Vector{Vector{Int64}}:
 [1, 2, 3]
 [1, 3, 2]
 [2, 1, 3]
 [2, 3, 1]
 [3, 1, 2]
 [3, 2, 1]

julia> sum(first(p) for p in Permutations(5))
360

julia> permutations([:b,:b,:a,:a])
6-element Vector{Vector{Symbol}}:
 [:a, :a, :b, :b]
 [:a, :b, :a, :b]
 [:a, :b, :b, :a]
 [:b, :a, :a, :b]
 [:b, :a, :b, :a]
 [:b, :b, :a, :a]
 
julia> npermutations([:b,:b,:a,:a])
6
```
"""
permutations(v)=collect(Permutations(v))

"`Permutations` is an iterator for `permutations`"
struct Permutations{T}
  v::Vector{T}
  Permutations(v::AbstractVector{T};srt=true) where T =new{T}(srt ? sort(v) : v)
end

Permutations(n::Int)=Permutations(1:n)
Base.show(io::IO,x::Permutations)=print(io,"Permutations(",x.v,")")

function Base.length(p::Permutations)
  cnt=factorial(length(p.v))
  for (e,c) in Tally_sorted(p.v)
    cnt=div(cnt,factorial(c)) 
  end
  cnt
end

npermutations(v)=length(Permutations(v))
@doc (@doc permutations) npermutations

Base.eltype(::Type{Permutations{T}}) where T =Vector{T}

function Base.iterate(P::Permutations)
  (P.v,P.v)
end

@inline function Base.iterate(P::Permutations,p)
  n=length(p)
  p=copy(p)
  i=n-1;while i>0 && p[i]>=p[i+1] i-=1 end
  if i<=0 return end
  j=n;
  while p[i]>=p[j] j-=1 end
  p[i],p[j]=p[j],p[i]
  i+=1
  j=n
  while i<j
    p[i],p[j]=p[j],p[i]
    i+=1;j-=1
  end
  (p,p)
end
#--------------------- arrangements -------------------
"`Arrangements` is an iterator for `arrangements`"
Arrangements(mset,k)=(w for v in Combinations(mset,k) 
                        for w in Permutations(v;srt=false))

Arrangements(mset::AbstractVector)=(w for k in 0:length(mset) 
                                      for w in Arrangements(mset,k))

"""
`arrangements(mset[,k])`, `narrangements(mset[,k])`

`arrangements`  returns  the  arrangements  of  the  multiset `mset` (a not
necessarily  sorted  collection  with  possible  repetitions).  If a second
argument   `k`  is  given,  it  returns  arrangements  with  `k`  elements.
`narrangements` returns (faster) the number of arrangements.

An *arrangement* of `mset` with `k` elements is a subsequence of length `k`
taken in arbitrary order, representated as a `Vector`. When
`k==length(mset)` it is also called a permutation.

As  an example of arrangements  of a multiset, think  of the game Scrabble.
Suppose  you have the six  characters of the word  'settle' and you have to
make a two letter word. Then the possibilities are given by

```julia-repl
julia> narrangements("settle",2)
14
```
while all possible words (including the empty one) are:

```julia-repl
julia> narrangements("settle")
523
```
Here are the two-letter words:
```julia-repl
julia> String.(arrangements("settle",2))
14-element Vector{String}:
 "ee"
 "el"
 "le"
 "es"
 "se"
 "et"
 "te"
 "ls"
 "sl"
 "lt"
 "tl"
 "st"
 "ts"
 "tt"
```
The  arrangements are implemented  by an iterator  `Arrangements` which can
enumerate the arrangements of a large multiset.
"""
arrangements(mset,k)=collect(Arrangements(mset,k))

arrangements(mset)=collect(Arrangements(mset))

# narrangements from the decreasing list of multiplicities tt
function narr(tt,k::Int)::Union{Int,BigInt}
  if k<=0 return 1 end
  n=sum(tt)
  if n>20 n=big(n) end
  if k>n 0 
  elseif k==n div(factorial(n),prod(factorial(i) for i in tt))
  elseif all(==(1),tt) prod(n-k+1:n)
  else sum(binomial(k,i)*narr(Iterators.drop(tt,1),k-i) for i in 0:first(tt))
  end
end

@doc (@doc arrangements) narrangements
function narrangements(mset,k)
  tt=sort!(last.(tally(mset)),rev=true)
  narr(tt,k)
end
  
function narrangements(mset)
  tt=sort!(last.(tally(mset)),rev=true)
  sum(narr(tt,k) for k in 0:length(mset))
end
#--------------------- partitions -------------------
"""
`Partitions(n[,k])` is an iterator which enumerates the partitions
of `n` (with `k` parts if `k`given) in lexicographic order.
```julia-repl
julia> a=Partitions(5)
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

julia> a=Partitions(10,3)
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
"""
struct Partitions{T<:Integer}
  n::T
end

Base.eltype(x::Partitions{T}) where T =Vector{T}
Base.IteratorSize(::Type{Partitions{T}}) where T=Base.SizeUnknown()
Base.show(io::IO,x::Partitions)=print(io,"Partitions(",x.n,")")

function Base.iterate(s::Partitions{T})where T
  v=fill(one(T),s.n)
  copy(v),v
end

@inline function Base.iterate(s::Partitions,v)
  ss=0
  for i in length(v):-1:1
    if ss>0 && (i==1 || v[i]<v[i-1])
       v[i]+=1
       for j in i+1:i+ss-1 v[j]=1 end
       for j in i+ss:length(v) v[j]=0 end
       return v[1:i+ss-1],v
    else ss+=v[i]
    end
  end
end

struct PartitionsK
  n::Int
  k::Int
end

Partitions(n,k)=PartitionsK(n,k)
Base.eltype(x::PartitionsK)=Vector{Int}
Base.IteratorSize(::Type{PartitionsK})=Base.SizeUnknown()
Base.show(io::IO,x::PartitionsK)=print(io,"Partitions(",x.n,",",x.k,")")

function Base.iterate(s::PartitionsK)
  if s.k>s.n || s.k<=0 return nothing end
  q,r=divrem(s.n,s.k)
  v=fill(q,s.k)
  for i in 1:r v[i]=q+1 end
  copy(v),v
end

@inline function Base.iterate(s::PartitionsK,v)
  ss=0
  for i in s.k:-1:1
    if ss>s.k-i && (i==1 || v[i]<v[i-1])
       v[i]+=1
       q,r=divrem(ss-1,s.k-i)
       for j in i+1:i+r v[j]=q+1 end
       for j in i+r+1:s.k v[j]=q end
       return copy(v),v
    else ss+=v[i]
    end
  end
end

"""
`partitions(n::Integer[,k])`, `npartitions(n::Integer[,k])`

`partitions`  returns in lexicographic order the partitions (with `k` parts
if  `k`  is  given)  of  the  positive  integer `n` . `npartitions` returns
(faster) the number of partitions.

There are approximately `exp(π√(2n/3))/(4√3 n)` partitions of `n`.

A   *partition*  is   a  decomposition   `n=p₁+p₂+…+pₖ`  in  integers  with
`p₁≥p₂≥…≥pₖ>0`, and is represented by the vector `p=[p₁,p₂,…,pₖ]`. We write
`p⊢n` to say that `p` is a partition of `n`.

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

The  partitions are implemented by an iterator `Partitions(n[,k])`
which can be used to enumerate the partitions of a large number.
"""
partitions(n::Integer)=collect(Partitions(n))
partitions(n::Integer,k::Integer)=collect(Partitions(n,k))

@doc (@doc partitions) npartitions
function npartitions(n)
  s=one(n)
  p=fill(s,n+1)
  for m in 1:n
    s=zero(n)
    k=1
    l=1
    while 0<=m-(l+k)
      s-=(-1)^k*(p[m-l+1]+p[m-(l+k)+1])
      k+=1
      l+=3*k-2
    end
    if l<=m s-=(-1)^k*p[m-l+1] end
    p[m+1]=s
  end
  s
end

function npartitions(n,k)
  if n==k return 1
  elseif n<k || k==0 return 0
  end
  p=fill(1,n)
  for l  in 2:k
    for m  in l+1:n-l+1 p[m]+=p[m-l] end
  end
  p[n-k+1]
end

"""
`partitions(n::Integer,set::AbstractVector[,k])`, `npartitions(n::Integer,set::AbstractVector[,k])`   

returns  the list  of partitions  of `n`  (with `k`  parts if `k` is given)
restricted  to have parts in `set`. `npartitions` gives (faster) the number
of such partitions.

Let  us show how many ways there are to pay 17 cents using coins of 2,5 and
10 cents.
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
"""
partitions(n::Integer,set::AbstractVector)=partitions(n,sort(set),length(set),Int[],1)

function partitions(n::Integer,set::AbstractVector,m,part,i)
  if n==0 return [part] end
  if mod(n,set[1])==0 parts=[part]
  else parts=Vector{Int}[]
  end
  for l in 2:m
    if set[l]<=n
      if length(part)<i push!(part,set[l]) else part[i]=set[l] end
      append!(parts,partitions(n-set[l],set,l,copy(part),i+1))
    end
  end
  if mod(n,set[1])==0
    for l in i:length(part) part[l]=set[1] end
    append!(part,fill(set[1],i+div(n,set[1])-length(part)-1))
  end
  parts
end

function partitions(n::Integer,set::AbstractVector,k)
  if n==0
    k==0 ? [Int[]] : Vector{Int}[]
  else
    if k==0 Vector{Int}[]
    else partitions(n,sort(set),length(set),k,Int[],1)
    end
  end
end

#  'partitions(n,set,m,k,part,i)'   returns   the   set   of  all
#  partitions  of 'n+sum(part[1:i-1])' that contain only elements of `set`,
#  that have length 'k+i-1', and that begin with 'part[1:i-1]'. To do so it
#  finds  all elements of `set`  that can go at  'part[i]' and calls itself
#  recursively  for each candidate.  `m` is the  position of `part[i-1]` in
#  `set`,  so the candidates  for `part[i]` are  the elements of `set[1:m]`
#  that   are  less  than  `n`,  since   we  require  that  partitions  are
#  nonincreasing.
function partitions(n::Integer,set::AbstractVector,m,k,part,i)
  if k==1
    if n in set part=copy(part)
      if length(part)<i push!(part,n) else part[i]=n end
      parts=[part]
    else parts=Vector{Int}[]
    end
  else
    part=copy(part)
    parts=Vector{Int}[]
    for l in 1:m
      if set[l]+(k-1)*set[1]<= n && n<=k*set[l]
        if length(part)<i push!(part,set[l]) else part[i]=set[l] end
        part[i]=set[l]
        append!(parts,partitions(n-set[l],set,l,k-1,part,i+1))
      end
    end
  end
  parts
end

function npartitions(n::Integer,set::AbstractVector)
  p=map(m->Int(iszero(mod(m-1,set[1]))),1:n+1)
  for l in set[2:end], m in l+1:n+1 p[m]+=p[m-l] end
  p[n+1]
end

function npartitions(n::Integer,set::AbstractVector,k)
  if n==0 && k==0  1
  elseif n<k || k==0 0
  else npartitions(n,sort(set),length(set),k,fill(0,n),1)
  end
end

function npartitions(n::Integer,set::AbstractVector,m,k,part,i)
  if k==1 return n in set end
  parts=0
  for l in 1:m
    if set[l]+(k-1)*set[1]<=n && n<=k*set[l]
      part[i]=set[l]
      parts+=npartitions(n-set[l],set,l,k-1,copy(part),i+1)
    end
  end
  parts
end

"""
`partitions(set::AbstractVector[,k])`, `npartitions(set::AbstractVector[,k])`

the  set of all unordered  partitions (in `k` sets  if `k` is given) of the
set  `set` (a  collection without  repetitions). `npartitions`  returns the
number of unordered partitions.

An *unordered partition* of `set` is a set of pairwise disjoints sets whose
union is equal to `set`, and is represented by a Vector of Vectors.

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
Note  that `unique(sort.(partitions(mset[,k])))`  is a  version which works
for a multiset `mset`.
"""
function partitions(set::AbstractVector,k)
  res=Vector{Vector{eltype(set)}}[]
  if length(set)<k return res end
  if k==1 return [[collect(set)]] end
  for p in partitions(set[1:end-1],k-1) push!(res,vcat(p,[[set[end]]])) end
  for p in partitions(set[1:end-1],k)
    for i in eachindex(p)
      u=copy(p)
      u[i]=vcat(u[i],[set[end]])
      push!(res,u)
    end
  end
  res
end

function partitions(set::AbstractVector)
  vcat((partitions(set,i) for i in eachindex(set))...)
end

"""
`stirling1(n,k)`

the  *Stirling  numbers  of  the  first  kind*  `S₁(n,k)`  are  defined  by
`S₁(0,0)=1,   S₁(n,0)=S₁(0,k)=0`   if   `n,   k!=0`   and   the  recurrence
`S₁(n,k)=(n-1)S₁(n-1,k)+S₁(n-1,k-1)`.

`S₁(n,k)`  is the  number of  permutations of  `n` points  with `k` cycles.
They   are   also   given   by   the   generating  function  ``n!{x\\choose
n}=\\sum_{k=0}^n(S₁(n,k) x^k)``. Note the similarity to ``x^n=\\sum_{k=0}^n
S₂(n,k)k!{x\\choose k}`` (see  `stirling2`).  Also  the  definition of `S₁`
implies  `S₁(n,k)=S₂(-k,-n)` if  `n,k<0`. There  are many formulae relating
Stirling  numbers of the first kind to Stirling numbers of the second kind,
Bell numbers, and Binomial numbers.

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
"""
function stirling1(n,k)
  if n<k return 0
  elseif n==k return 1
  elseif n<0 && k<0 return stirling2(-k,-n)
  elseif k<=0 return 0
  else
    sti=fill(zero(k),n-k+1)
    for i in 1:k
      sti[1]=1
      for j in 2:n-k+1 sti[j]=(i+j-2)*sti[j-1]+sti[j] end
    end
    sti[n-k+1]
  end
end

"""
`stirling2(n,k)`

the  *Stirling  numbers  of  the  second  kind* are defined by `S₂(0,0)=1`,
`S₂(n,0)=S₂(0,k)=0` if `n, k!=0` and `S₂(n,k)=k S₂(n-1,k)+S₂(n-1,k-1)`, and
also as coefficients of the generating function
``x^n=\\sum_{k=0}^{n}S₂(n,k) k!{x\\choose k}``.

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
"""
function stirling2( n, k )
  if n<k return 0
  elseif n==k return 1
  elseif n<0 && k<0 return stirling1(-k,-n)
  elseif k<=0 return 0
  end
  bin,sti,fib=1,0,1
  for i in 1:k
    bin=div(bin*(k-i+1),i)
    sti=bin*i^n-sti
    fib*=i
  end
  div(sti,fib)
end

npartitions(set::AbstractVector,k)=stirling2(length(set),k)

"""
'bell(n)'

The  Bell numbers are  defined by `bell(0)=1`  and ``bell(n+1)=∑_{k=0}^n {n
\\choose  k}bell(k)``, or by the fact  that `bell(n)/n!` is the coefficient
of `xⁿ` in the formal series `e^(eˣ-1)`.

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
Also, `bell(n)` is the number of unordered partitions of a set of size `n`.
"""
function bell(n)
  bell_=[one(n)]
  for i in 1:n-1
    push!(bell_,bell_[1])
    for k in 0:i-1 bell_[i-k]+=bell_[i-k+1] end
  end
  bell_[1]
end

npartitions(set::AbstractVector)=bell(length(set))

#------------------------ partition tuples ---------------------------
# add to list partitions_tuples(n,r) using l[i] list of partitions of i
function partition_tuples(list,n,r,l)
  k=length(list[end])
  start=true
  for i in (r==1 ? n : 0):n, p in l[i+1]
    if !start push!(list,list[end][1:k]) end
    start=false
    push!(list[end],p)
    if r>1 partition_tuples(list,n-i,r-1,l) end
  end
end

# decent implementation
function partition_tuples2(n,r)
  if r==1 return map(x->[x],partitions(n)) end
  list=[Vector{Int}[]]
  if iszero(r) return  n>0 ? empty(list) : list end
  partition_tuples(list,n,r,partitions.(0:n))
  list
end

# bad implementation but which is ordered as GAP3; needed for
# compatibility with Chevie data library (specially type B2)
"""
`partition_tuples(n,r)`, `npartition_tuples(n,r)`

the `r`-tuples of partitions that together partition `n`.
`npartition_tuples` is the number of partition tuples.

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
"""
function partition_tuples(n, r)
   if n==0 return [fill(Int[],r)] end
   empty=(tup=[Int[] for i in 1:r], pos=fill(1,n-1))
   pm=[typeof(empty)[] for i in 1:n-1]
   for m in 1:div(n,2)
      for i in 1:r # the m-cycle in all possible places.
        t=map(copy,empty)
        t.tup[i]=[m]
        t.pos[m]=i
        push!(pm[m],t)
      end
       # add the m-cycle to everything you know.
      for k in m+1:n-m, t in pm[k-m], i in t.pos[m]:r
        t1=map(copy,t)
        t1.tup[i]=copy(t1.tup[i])
        pushfirst!(t1.tup[i],m)
        t1.pos[m]=i
        push!(pm[k], t1)
      end
   end
   res= Vector{Vector{Int}}[]
   for k in 1:n-1, t in pm[n-k], i in t.pos[k]:r # collect
     s=copy(t.tup)
     s[i]=copy(s[i])
     pushfirst!(s[i],k)
     push!(res,s)
   end
   for i in 1:r
     s=copy(empty.tup)
     s[i]=[n]
     push!(res,s)
   end
   res
end

@doc (@doc partition_tuples) npartition_tuples
function npartition_tuples(n,k)
  res=0
  for l in 1:min(n,k)
    r=binomial(k,l)
    res+=r*sum(a->narrangements(a,l)*prod(npartitions.(a)),partitions(n,l))
  end
  res
end
#---------------------- compositions --------------------------------
"`Compositions` is an iterator for `compositions`"
struct Compositions{T<:Integer}
  n::T
  k::Int
  min::T
end

Compositions(n,k;min=1)=Compositions(n,k,min)

Base.eltype(::Type{Compositions{T}}) where T=Vector{T}

function Base.length(c::Compositions)
  t=c.n+c.k-1-c.k*c.min
  t<0 ? 0 : binomial(t,c.k-1)
end

function Base.iterate(c::Compositions)
  s=c.n-c.k*c.min 
  if s<0 return nothing end
  u=fill(c.min,c.k);u[end]=s+c.min
  u,copy(u)
end

@inline function Base.iterate(c::Compositions,u)
  for i in length(u):-1:2
    s=sum(@view u[i:end])-1-(length(u)-i)*c.min
    if s>=c.min 
      u[i-1]+=1;u[end]=s;u[i:end-1].=c.min
      return u,copy(u)
    end
  end
end

Compositions(n::T;min=1) where T<:Integer=(c for k in 1:div(n,min) for c in Compositions(n,k;min))

"""
`compositions(n[,k];min=1)`, `ncompositions(n[,k];min=1)`

This  function returns the compositions of  `n` (the compositions of length
`k`  if a second argument `k` is given), where a composition of the integer
`n`  is a decomposition `n=p₁+…+pₖ` in  integers `≥min`, represented as the
vector  `[p₁,…,pₖ]`. Unless `k` is given,  `min` must be `>0`. Compositions
are sometimes called ordered partitions.

`ncompositions`  returns  (faster)  the  number  of compositions. There are
``2^{n-1}``  compositions of `n` in  integers `≥1`, and `binomial(n-1,k-1)`
compositions of `n` in `k` parts `≥1`.

```julia-repl
julia> ncompositions(4)
8

julia> compositions(4)
8-element Vector{Vector{Int64}}:
 [4]
 [1, 3]
 [2, 2]
 [3, 1]
 [1, 1, 2]
 [1, 2, 1]
 [2, 1, 1]
 [1, 1, 1, 1]

julia> ncompositions(4,2)
3

julia> compositions(4,2)
3-element Vector{Vector{Int64}}:
 [1, 3]
 [2, 2]
 [3, 1]

julia> ncompositions(4,2;min=0)
5

julia> compositions(4,2;min=0)
5-element Vector{Vector{Int64}}:
 [0, 4]
 [1, 3]
 [2, 2]
 [3, 1]
 [4, 0]
```
The compositions are implemented by an iterator `Compositions(n[,k];min=1)`
which can be used to enumerate the compositions of a large number.
"""
compositions(n::T,k::Integer;min=1)where T<:Integer=collect(Compositions(n,k;min))

compositions(n::T;min=1) where T<:Integer=collect(Compositions(n;min))

ncompositions(n,k;min=1)=length(Compositions(n,k;min))

ncompositions(n;min=1)=min==1 ? (n==0 ? 1 : 2^(n-1)) : 
  sum(k->ncompositions(n,k;min),1:div(n,min))

@doc (@doc compositions) ncompositions
#------------------------ multisets ---------------------------------
"""
`multisets(set,k)`, `nmultisets(set,k)`

`multisets`  returns  the  set  of  all  multisets of length `k` made of
elements   of   the   set   `set`   (a   collection  without  repetitions).
`nmultisets` returns the number of multisets.

An  *multiset* of length `k` is  an unordered selection with repetitions of
length  `k` from `set` and is represented  by a sorted vector of length `k`
made  of elements  from `set`  (it is  also sometimes called a "combination
with replacement").

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
"""
function multisets(A,i)
  res=[Vector{eltype(A)}(undef,i)]
  multisets(res,A,i,1)
  res
end

function multisets(res,A,i,j)
  if i==0 return end
  for k in j:length(A)
    if k>j push!(res,copy(res[end])) end
    res[end][end+1-i]=A[k]
    multisets(res,A,i-1,k)
  end
end
    
@doc (@doc multisets) nmultisets
nmultisets(set,k)=binomial(length(set)+k-1,k)

#--------------------------- unexported functions ------------------------
# symmetric difference of sorted multisets
function symdiffmset(a,b)
  res=eltype(a)[]
  la=length(a)
  lb=length(b)
  ai=bi=1
  ri=0
  while ai<=la || bi<=lb
    if     ai>la res[ri+=1]=b[bi]; bi+=1
    elseif bi>lb res[ri+=1]=a[ai]; ai+=1
    else c=cmp(a[ai],b[bi])
      if     c>0 res[ri+=1]=b[bi]; bi+=1
      elseif c<0 res[ri+=1]=a[ai]; ai+=1
      else
        ai+=1; bi+=1
      end
    end
  end
  res
end

# difference of sorted multisets
function msetdiff(a,b)
  res=eltype(a)[]
  la=length(a)
  lb=length(b)
  ai=bi=1
  ri=0
  while ai<=la || bi<=lb
    if     ai>la break
    elseif bi>lb push!(res,a[ai]); ai+=1
    else c=cmp(a[ai],b[bi])
      if     c>0 bi+=1
      elseif c<0 push!(res,a[ai]); ai+=1
      else
        ai+=1; bi+=1
      end
    end
  end
  res
end

function pushcopy!(v,i) # faster than push!(copy(v),i)
  res=copyto!(similar(v,length(v)+1),v)
  res[end]=i
  res
end

#--------------------------- functions on partitions ------------------------
"""
`lcm_partitions(p1,…,pn)`

each  argument is  a partition  of the  same set  `S`, given  as a  list of
disjoint  vectors whose  union is  `S`. Equivalently  each argument  can be
interpreted as an equivalence relation on `S`.

The result is the finest partition of `S` such that each argument partition
refines it. It represents the 'or' of the equivalence relations represented
by the arguments.

```julia-repl
julia> lcm_partitions([[1,2],[3,4],[5,6]],[[1],[2,5],[3],[4],[6]])
2-element Vector{Vector{Int64}}:
 [1, 2, 5, 6]
 [3, 4]      
```
"""
function lcm_partitions(arg...)
  function lcm2(a,b)
    res = Set(Vector{Int}[])
    for p in b
     push!(res, sort(union(filter(x->!isempty(intersect(x, p)),a)...)))
    end
    b = Set(Vector{Int}[])
    for p in res
     push!(b, sort(union(filter(x->!isempty(intersect(x, p)),res)...)))
    end
    b
  end
  sort(collect(reduce(lcm2,arg)))
end

"""
`gcd_partitions(p1,…,pn)`

Each  argument is  a partition  of the  same set  `S`, given  as a  list of
disjoint  vectors whose  union is  `S`. Equivalently  each argument  can be
interpreted as an equivalence relation on `S`.

The result is the coarsest partition which refines all argument partitions.
It  represents the  'and' of  the equivalence  relations represented by the
arguments.

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
"""
function gcd_partitions(arg...)
  sort(collect(reduce(arg)do a,b
    res = map(x->map(y->intersect(x, y), b), a)
    sort(unique(filter(!isempty,reduce(vcat,res))))
  end))
end

"""
`Catalan(n)` `n`-th Catalan Number

```julia-repl
julia> catalan(8)
1430

julia> catalan(big(50))
1978261657756160653623774456
```
"""
catalan(n::Integer)=div(binomial(2n,n),n+1)

"""
`diagblocks(M::Matrix)`

`M`  should  be  a  square  matrix.  Define  a  graph  `G`  with vertices
`1:size(M,1)` and with an edge between `i`  and `j` if either `M[i,j]` or
`M[j,i]` is not zero or `false`. `diagblocks` returns a vector of vectors
`I`  such that  `I[1]`,`I[2]`, etc..  are the  vertices in each connected
component  of `G`.  In other  words, `M[I[1],I[1]]`,`M[I[2],I[2]]`,etc...
are diagonal blocks of `M`.

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

julia> m[[1,4,2,3],[1,4,2,3]]
4×4 Matrix{Int64}:
 0  1  0  0
 1  0  0  0
 0  0  0  1
 0  0  1  0
```
"""
function diagblocks(M::AbstractMatrix)::Vector{Vector{Int}}
  l=size(M,1)
  if l==0 return Vector{Int}[] end
  cc=collect(1:l) # cc[i]: in which block is i, initialized to different blocks
  for i in 1:l, j in i+1:l
    # if new relation i~j then merge components:
    if !(iszero(M[i,j]) && iszero(M[j,i])) && cc[i]!=cc[j]
      cj=cc[j]
      for k in 1:l
         if cc[k]==cj cc[k]=cc[i] end
      end
    end
  end
  sort(collectby(cc,collect(1:l)))
end

"""
`blocks(M:AbstractMatrix)`

Finds  if the  matrix  `M` admits a block decomposition.

Define  a bipartite  graph `G`  with vertices  `axes(M,1)`, `axes(M,2)` and
with an edge between `i` and `j` if `M[i,j]` is not zero. BlocksMat returns
a  list of pairs of  lists `I` such that  `I[i]`, etc.. are the vertices in
the `i`-th connected component of `G`. In other words, `M[I[1][1],I[1][2]],
M[I[2][1],I[2][2]]`,etc... are blocks of `M`.

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
"""
function blocks(M::AbstractMatrix)
  comps=Tuple{Vector{Int},Vector{Int}}[]
  for l in axes(M,1), c in axes(M,2)
    if !iszero(M[l,c])
      p=findfirst(x->l in x[1],comps)
      q=findfirst(x->c in x[2],comps)
      if p===nothing
        if q===nothing  push!(comps, ([l], [c]))
        else union!(comps[q][1], l)
        end
      elseif q===nothing union!(comps[p][2], c)
      elseif p==q 
        union!(comps[p][1], l)
        union!(comps[p][2], c)
      else 
        union!(comps[p][1],comps[q][1])
        union!(comps[p][2],comps[q][2])
        deleteat!(comps,q)
      end
    end
  end
  sort!(comps)
end

"""
`conjugate_partition(λ)`

returns  the  conjugate  partition  of  the  partition  `λ`,  that  is, the
partition having the transposed of the Young diagram of `λ`.

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
"""
function conjugate_partition(p)
  res=zeros(eltype(p),maximum(p;init=0))
  for i in p, j in 1:i res[j]+=1 end
  res
end

"""
`dominates(λ,μ)`

The  dominance  order  on  partitions  is  an  important  partial  order in
representation theory. `λ` dominates `μ` if and only if for all `i` we have
`sum(λ[1:i])≥sum(μ[1:i])`.

```julia-repl
julia> dominates([5,4],[4,4,1])
true
```
"""
function dominates(λ,μ)
  sλ=sμ=0
  for (l,m) in zip(λ,μ)
    if (sλ+=l)<(sμ+=m) return false end
  end
  true
end

"""
`tableaux(S)`

if  `S`  is  a  partition  tuple,  returns  the  list  of standard tableaux
associated  with  the  partition  tuple  `S`,  that  is  a  filling  of the
associated  young diagrams  with the  numbers `1:sum(sum,S)`  such that the
numbers increase across the rows and down the columns.

If  `S` is a single partition, the standard tableaux for that partition are
returned.

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
"""
tableaux(S)=inner_tableaux(copy.(S))
function inner_tableaux(S)
  w=sum(sum,S)
  if iszero(w) return [map(x->map(y->Int[],x),S)] end
  res=Vector{Vector{Vector{Int}}}[]
  for i in eachindex(S), p in eachindex(S[i])
    if iszero(S[i][p]) || (p<length(S[i]) && S[i][p+1]==S[i][p]) continue end
    S[i][p]-=1; tt=inner_tableaux(S); S[i][p]+=1
    for t in tt push!(t[i][p], w) end
    append!(res,tt)
  end
  sort(res)
end

tableaux(S::Vector{<:Integer})=first.(tableaux([S]))

"""
`semistandard_tableaux(λ,c)`

`c`  should be  a non-decreasing  list and  `λ` a partition of `length(c)`.
Returns  the list of semi_standard tableaux with shape `λ` and content `c`,
that is a filling of the young diagram of `λ` with the elements of `c` such
that they increase down the columns and do not decrease across the rows.
```julia-repl
julia> semistandard_tableaux([3,2,1],[1,2,2,3,4,5])
8-element Vector{Vector{Vector{Int64}}}:
 [[1, 2, 2], [3, 4], [5]]
 [[1, 2, 2], [3, 5], [4]]
 [[1, 2, 3], [2, 4], [5]]
 [[1, 2, 3], [2, 5], [4]]
 [[1, 2, 4], [2, 3], [5]]
 [[1, 2, 5], [2, 3], [4]]
 [[1, 2, 4], [2, 5], [3]]
 [[1, 2, 5], [2, 4], [3]]
```
"""
function semistandard_tableaux(shape,content,front=nothing)
  if isnothing(front) 
    front=fill(1,length(shape))
  end
  if isempty(content) return [[fill(0,s) for s in shape]] end
  e=content[1]
  res=Vector{Vector{Int}}[]
  for (row,col) in enumerate(front)
    if col>shape[row] || (row>1 && front[row-1]<=col) continue end
    front[row]+=1
    for t in semistandard_tableaux(shape,content[2:end],front)
       if row==length(shape) || col>shape[row+1] || e<t[row+1][col]
          t[row][col]=e
          push!(res,t)
       end
    end
    front[row]-=1
  end
  unique!(res)
end

"""
`robinson_schensted(p::AbstractVector{<:Integer})`

returns  the pair of standard tableaux  associated with the permutation `p`
by the Robinson-Schensted correspondence.

```julia-repl
julia> robinson_schensted([2,3,4,1])
([[1, 3, 4], [2]], [[1, 2, 3], [4]])
```
"""
function robinson_schensted(p::AbstractVector{<:Integer})
  P=Vector{Int}[]
  Q=Vector{Int}[]
  for (i,j) in enumerate(p)
    z=1
    while true
      if z>length(P)
        push!(P,[j])
        push!(Q,[i])
        break
      else
        pos=findfirst(>=(j),P[z])
        if isnothing(pos)
          push!(P[z],j)
          push!(Q[z],i)
          break
        else
          (P[z][pos],j)=(j,P[z][pos])
          z+=1
        end
      end
    end
  end
  (P,Q)
end

#----------------------- Number theory ---------------------------
using Primes: eachfactor, factor, totient

"""
`prime_residues(n)` the numbers in `1:n` prime to `n`
```julia-repl
julia> [prime_residues(24)]
1-element Vector{Vector{Int64}}:
 [1, 5, 7, 11, 13, 17, 19, 23]
```
"""
function prime_residues(n)
  if n==1 return [0] end
  pp=trues(n) # use a sieve to go fast
  for (p,np) in eachfactor(n)
    pp[p:p:n].=false
  end
  (1:n)[pp]
end

"""
`primitiveroot(m::Integer)`   a   primitive   root,   that   is  generating
multiplicatively  `mod.  m`  the  `prime_residues(m)`. The function returns
`nothing` if there is no primitive root `mod. m`.

A  primitive root exists if `m` is equal to `4` or `p^a` or `2p^a` for `p`
prime>2.

```julia-repl
julia> primitiveroot(23)
5
```
"""
function primitiveroot(m::Integer)
  if m==2 return 1
  elseif m==4 return 3
  end
  f=factor(m)
  nf=length(keys(f))
  if nf>2 return nothing end
  if nf>1 && (!(2 in keys(f)) || f[2]>1) return nothing end
  if nf==1 && (2 in keys(f)) && f[2]>2 return nothing end
  p=totient(m) # the Euler φ
  1+findfirst(x->powermod(x,p,m)==1 && 
     all(d->powermod(x,div(p,d),m)!=1,keys(factor(p))),2:m-1)::Int
end

"""
`moebius(n::Integer)`

The  classical  Möbius  function  is  the  Möbius  function of the poset of
integers for divisibility. It is zero outside square-free integers, and for
square-free integers is `(-1)ⁿ' where n is the number of prime factors.
```julia-repl
julia> moebius.(1:6)
6-element Vector{Int64}:
  1
 -1
 -1
  0
 -1
  1
```
"""
function moebius(n::Integer)
  m(p,e)=p==0 ? 0 : e==1 ? -1 : 0
  reduce(*, m(p, e) for (p, e) in eachfactor(n) if p ≥ 0; init=1)
end

const bern=Rational{BigInt}[-1//2]

"""
`bernoulli(n)` the `n`-th *Bernoulli number*  `Bₙ` as a `Rational{BigInt}`

`Bₙ`    is    defined    by   ``B₀=1,   B_n=-\\sum_{k=0}^{n-1}({n+1\\choose
k}B_k)/(n+1)``.  `Bₙ/n!` is the coefficient of  `xⁿ` in the power series of
`x/(eˣ-1)`.  Except for `B₁=-1/2` the Bernoulli numbers for odd indices are
zero.

```julia-repl 
julia> bernoulli(4)
-1//30

julia> bernoulli(10)
5//66

julia> bernoulli(12) # there is no simple pattern in Bernoulli numbers
-691//2730

julia> bernoulli(50) # and they grow fairly fast
495057205241079648212477525//66
```
"""
function bernoulli(n::Integer)
  if n<0 error("bernoulli: $n must be ≥0")
  elseif n==0 return 1//1
  end
  for i in length(bern)+1:n
    if isodd(i) push!(bern,0)
    else
      bin=1
      brn=1
      for j in 1:i-1
        bin=(i+2-j)//j*bin
        brn+=bin*bern[j]
      end
      push!(bern,-brn//(i+1))
    end
  end
  return bern[n]
end

end
