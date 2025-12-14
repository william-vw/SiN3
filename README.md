# SiN3: Sparql in N3

# Online Demo

We provide an online demo for testing query translation and execution:
[https://editor.notation3.org/spin3/s/oG7qKAqN](https://editor.notation3.org/spin3/s/oG7qKAqN). 

The demo is pre-loaded with Zika experiment queries and example data. 
After clicking "execute", the query results and translated files (SPIN, N3) are shown.

# Experiment results

The [`exp/`](exp/) folder includes the detailed experiment results, together with a summary and discussion. For reproducibility, all datasets and queries referenced below are either included in this repository or linked from publicly accessible sources.

# Run experiments

SiN3 requires the installation of the eye reasoner: 
https://github.com/eyereasoner/eye/tags (note that we used [v10.24.10](https://github.com/eyereasoner/eye/releases/tag/v10.24.10))

To run SiN3, change your working directory to [`run/`](run/) and use the following command:
```
./sin3.sh [-s <sparql>] [-d <data>] [-m <mode>(bwd|fwd)] ([-q <query>]) (-v) ([-r <result>])"
```
- `-v` will print output.
- `-d` can be a comma-separated list of paths.
- `-q` is only needed in case of backward reasoning.
- `<mode>` specifies the reasoning direction: fwd for forward chaining, bwd for backward chaining.
- `<result>` (optional) stores the reasoning output to the specified file.

For examples, see the experiments below.

The systems used for comparison in the paper can be found here:
- SPIN: https://github.com/spinrdf/spinrdf
- recSPARQL: https://adriansoto.cl/RecSPARQL/

## Linked Movie Database (LMDB)

This use case was found in Reutter et al. [1] and downloaded from https://adriansoto.cl/RecSPARQL/.
We converted the queries, which used the recSPARQL syntax, into recursive SPARQL CONSTRUCT queries.

To run this use case, you will need to separately [download](https://files.catbox.moe/vpg5uy.zip) the `lmdb.nt` dataset and copy it into the [`exp/lmdb`](exp/lmdb) folder.

```
run % ./sin3.sh -s ../exp/lmdb/sparql/lmdb1.sparql -d ../exp/lmdb/lmdb.nt -m fwd -v
run % ./sin3.sh -s ../exp/lmdb/sparql/lmdb2.sparql -d ../exp/lmdb/lmdb.nt -m fwd -v
run % ./sin3.sh -s ../exp/lmdb/sparql/lmdb3.sparql -d ../exp/lmdb/lmdb.nt -m fwd -v
```

## YAGO

This use case was also found in Reutter et al. [1] and downloaded from https://adriansoto.cl/RecSPARQL/.
As before, we converted the queries, which used the recSPARQL syntax, into recursive SPARQL CONSTRUCT queries.

To run this use case, you will need to separately [download](https://files.catbox.moe/06n7mv.zip) the `yagoFacts.nt` dataset and copy it into the [`exp/yago`](exp/yago) folder.

```
run % ./sin3.sh -s ../exp/yago/sparql/yago1.sparql -d ../exp/yago/yagoFacts.nt -m fwd -v
run % ./sin3.sh -s ../exp/yago/sparql/yago2.sparql -d ../exp/yago/yagoFacts.nt -m fwd -v
run % ./sin3.sh -s ../exp/yago/sparql/yago3.sparql -d ../exp/yago/yagoFacts.nt -m fwd -v
run % ./sin3.sh -s ../exp/yago/sparql/yago4.sparql -d ../exp/yago/yagoFacts.nt -m fwd -v
run % ./sin3.sh -s ../exp/yago/sparql/yago5.sparql -d ../exp/yago/yagoFacts.nt -m fwd -v
```


## Deep Taxonomy

This taxonomy was taken from https://eulersharp.sourceforge.net/2009/12dtb/.

To run this use case, you will need to separately [download](https://files.catbox.moe/shrw87.zip) the `test-dl-1000000.n3` dataset and copy it into the [`exp/deep_taxonomy`](exp/deep_taxonomy) folder.

```
run % ./sin3.sh -s ../exp/deep_taxonomy/test-rules.sparql -d ../exp/deep_taxonomy/test-dl-1000000.n3 -q ../exp/deep_taxonomy/test-dl-query.n3 -m bwd -v
```

_Note_: `test-dl-query.n3` here was already translated from a SPARQL query into N3 rules; we leave this step out for brevity.


## Zika use case

The Zika use case can be found under the [`exp/zika`](exp/zika/) folder, including queries and datasets.

### Forward chaining

Full FHIR vocabulary:


```
run % ./sin3.sh -s ../exp/zika/queries_orig.sparql -d ../exp/zika/data_orig_0pt1.nt -m fwd -v
run % ./sin3.sh -s ../exp/zika/queries_orig.sparql -d ../exp/zika/data_orig_0pt2.nt -m fwd -v
```

_Note_: the `.nt` files were pre-processed to avoid the use of `rdf:first` and `rdf:rest` pairs in the data, as these cause issues with the `eye` reasoner (where they are recognized as builtins).

This is a temporary technical issue that will be fixed.

Reduced FHIR vocabulary:

```
run % ./sin3.sh -s ../exp/zika/queries_red.sparql -d ../exp/zika/data_red_0pt1.n3 -m fwd -v
run % ./sin3.sh -s ../exp/zika/queries_red.sparql -d ../exp/zika/data_red_0pt2.n3 -m fwd -v
```

Including the SNOMED ontology:

```
run % ./sin3.sh -s ../exp/zika/queries_red_snomed.sparql -d ../exp/zika/data_red_0pt2_snomed.n3,../exp/zika/ontology-2024-12-16_15-03-55--subclass.ttl -m fwd -v
```


### Backward chaining

Full FHIR vocabulary:

```
run % ./sin3.sh -s ../exp/zika/queries_orig.sparql -d ../exp/zika/data_orig_0pt1.nt -q ../exp/zika/bwd_query.n3 -m bwd -v
run % ./sin3.sh -s ../exp/zika/queries_orig.sparql -d ../exp/zika/data_orig_0pt2.nt -q ../exp/zika/bwd_query.n3 -m bwd -v
```

_Note_: we make the same note here about the pre-processed `.nt` files.  

_Note_: `bwd_query.n3` here was already translated from a SPARQL query into N3 rules; we leave this step out for brevity.

Reduced FHIR vocabulary:

```
run % ./sin3.sh -s ../exp/zika/queries_red.sparql -d ../exp/zika/data_red_0pt1.n3 -q ../exp/zika/bwd_query.n3 -m bwd -v
run % ./sin3.sh -s ../exp/zika/queries_red.sparql -d ../exp/zika/data_red_0pt2.n3 -q ../exp/zika/bwd_query.n3 -m bwd -v
```

Including the SNOMED ontology:

```
run % ./sin3.sh -s ../exp/zika/queries_red_snomed.sparql -d ../exp/zika/data_red_0pt2_snomed.n3,../exp/zika/ontology-2024-12-16_15-03-55--subclass.ttl -q ../exp/zika/bwd_query.n3 -m bwd -v
```

# References

[1] Reutter, J., Soto, A., Vrgoč, D.: [Recursion in SPARQL](https://www.semantic-web-journal.net/system/files/swj2276.pdf). Semantic Web 12(5), 711–740 (2021).
