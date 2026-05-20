# TODO

## Sidebar Rendering

- Replace broad `NSCollectionView.reloadData()` updates with targeted row updates.
  - Preferred: move sidebar rows to `NSCollectionViewDiffableDataSource` with stable row IDs.
  - Alternative: use `performBatchUpdates` for folder expand/collapse inserts and deletes.
  - Goal: avoid redrawing the entire sidebar when opening a folder, preserving hover, selection, and row animations.
