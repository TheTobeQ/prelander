# HomeScan MVP architecture

## Native stack
- SwiftUI — interface
- RoomPlan — room capture and semantic reconstruction
- ARKit — spatial tracking / LiDAR-backed capture
- RealityKit — future interactive 3D viewer
- USDZ — portable 3D export

## Next product milestones
1. Multi-room scanning and automatic floor merging.
2. Interactive 3D viewer with furniture visibility controls.
3. Automatic room labels and measurements.
4. PDF floor-plan export.
5. Shareable project links.
6. AI renovation / furniture visualization.
7. Cloud projects and user accounts.

The current MVP intentionally uses Apple's RoomPlan capture pipeline instead of trying to implement raw LiDAR reconstruction from scratch.
