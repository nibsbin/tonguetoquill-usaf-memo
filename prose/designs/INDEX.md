# Design Index

## Active Designs

No active design documents at this time. All previous designs have been successfully implemented and archived.

## Archived Designs

**Note:** The following designs have been implemented and archived to `../archive/designs/`:

- **Composable Show Rule Architecture** ✅ - Refactored from monolithic state-based API to composable show rule system (frontmatter → mainmatter → backmatter → indorsements)
- **Paragraph Numbering System** ✅ - Implemented native Typst-based hierarchical paragraph numbering for AFH 33-337 compliance
- **Configuration Single Source of Truth** ✅ - Eliminated configuration duplication between config.typ and utils.typ
- **Backmatter Rendering Unification** ✅ - Eliminated backmatter rendering duplication across utils.typ, primitives.typ, and indorsement.typ
- **Import Chain Simplification** ✅ - Reduced import statements from 15 to 4 by leveraging transitive dependencies
- **Type Normalization Utilities** ✅ - Replaced ~30 lines of inline type normalization with 3 canonical utility functions

See `../archive/CASCADES.md` for the full simplification cascades analysis.
