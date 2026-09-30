# Additional manual rejection cases

These are sketches from the original temporary refinement examples. Instantiate each separately and expand it with `ObjectOf` to inspect its diagnostic; they are not active tests until a type checker is available to verify each outcome.

- Function refinements: incompatible `lookup` parameter (`number` instead of `string`), return (`number` instead of `string`), extra parameter, incompatible variadic tail, or wrong number of `pair` return values.
- Immutable indexers: a class member declared as `Immut<Recursive>` where `Recursive` is `{ [string]: Recursive }` should report a cycle rather than recurse forever. `Immut` is a class-member modifier, not a standalone table transformer.
- Type-only refinements: narrowing `Ball<string>` to a type not compatible with `string`, adding an unknown member, or applying type arguments to the nongeneric `Object` reference should be rejected.