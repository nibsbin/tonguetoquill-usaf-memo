# Design Index

## Active Designs

- [Composable Show Rule Architecture](./composable-show-rules.md) - Refactor from monolithic state-based API to composable show rule system
- [Paragraph Numbering System](./paragraph-numbering.md) - Native Typst-based hierarchical paragraph numbering for AFH 33-337 compliance

## Archived Designs

**Note:** The following designs have been implemented and archived to `../archive/designs/`:

- Configuration Single Source of Truth ✅ - Eliminate configuration duplication between config.typ and utils.typ
- Backmatter Rendering Unification ✅ - Eliminate backmatter rendering duplication across utils.typ, primitives.typ, and indorsement.typ
- Import Chain Simplification ✅ - Reduce import statements from 15 to 4 by leveraging transitive dependencies
- Type Normalization Utilities ✅ - Replace ~30 lines of inline type normalization with 3 canonical utility functions

See `../archive/CASCADES.md` for the full simplification cascades analysis.
