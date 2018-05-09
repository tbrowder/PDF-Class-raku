use v6;

use PDF::COS::Tie::Hash;

role PDF::NumberTree
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    has PDF::NumberTree @.Kids is entry(:indirect); #| (Root and intermediate nodes only; required in intermediate nodes; present in the root node if and only if Nums is not present) Shall be an array of indirect references to the immediate children of this node. The children may be intermediate or leaf nodes.
    has @.Nums is entry; #| Root and leaf nodes only; required in leaf nodes; present in the root node if and only if Kids is not present) An array of the form
                         #| [ key 1 value 1 key 2 value 2 ... key n value n ]
                         #| where each key i is an integer and the corresponding value i shall be the object associated with that key. The keys are sorted in numerical order
    method nums {
        Proxy.new(
            FETCH => sub ($) {
                with self<Nums> -> $nums {
                    (1, 3 ... $nums.elems).map: { $nums[$_-1] => $nums[$_] }
                }
            },
            STORE => sub ($, %nums) {
                my @nums = flat %nums.sort(*.key.Int).map: {.key.Int, .value}
                self<Nums> = @nums;
            }
        )
    }
    has Numeric @.Limits is entry(:len(2)); #| (Shall be present in Intermediate and leaf nodes only) Shall be an array of two integers, that shall specify the (numerically) least and greatest keys included in the Nums array of a leaf node or in the Nums arrays of any leaf nodes that are descendants of an intermediate node.
}
