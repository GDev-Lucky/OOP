# Limitations and status

## Runtime is unfinished

OOP currently implements its type-function compiler in `src/types.luau`. It does not yet provide runtime class construction, instance dispatch, or a usable package module. In particular, `src/init.luau` is unfinished and should not be used as an entry point.

The examples in this repository use `nil :: any` values to demonstrate type surfaces. They are compiler tests, not runnable object implementations.

## Luau type-system limits

`Immut<T>` makes indexed values deeply immutable, but Luau may still allow replacing an indexed value itself:

```luau
array[1].score = 10 -- intended to be rejected
array[1] = replacement -- may still type-check
```

The same caveat applies to dictionary entries. This is a current Luau type-system limitation, not intended framework behavior.

## Recursive indexer cycles

The resolver cannot currently process a recursive table cycle that passes through an indexer. Such a type produces a compiler error rather than a resolved view.

## Hidden metadata

View conversion depends on hidden metadata embedded in compiled types and on Luau preserving enough union/intersection structure to recover it. Use the documented conversion APIs instead of relying on that representation.

## Compatibility

This project relies on Luau type functions. Tooling support can vary by Luau version and environment. Before depending on OOP, run its type examples with the same Luau toolchain used by your Roblox project.