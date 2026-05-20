# Camera Projection & Triangulation — MATLAB

Given the 3D positions of a person's body joints from a motion capture system, this project figures out exactly where those joints would appear on two camera views — and then works backwards from those camera images to reconstruct the 3D positions. It measures how accurately the reconstruction matches the original motion capture data.

Implemented in MATLAB from scratch. The pipeline applies a full camera model (K·[R|t] with radial distortion correction) to project 3D world points to 2D pixel coordinates, inverts the camera model to back-project 2D points to 3D unit rays, and triangulates 3D positions using a cross-product ray nearest-midpoint formula. Evaluation computes per-joint L2 error against ground truth across all frames, with statistics (mean, std, median, min, max) and visual overlays of projected joints and skeleton on actual video frames from both cameras.

**[Live Demo →](https://halkhoori2000.github.io/Camera-Projection-and-Triangulation/)**

## Use Cases
- Optical motion capture for film and VFX: exactly the setup used here — multiple calibrated cameras reconstruct 3D joint positions from a performer, driving character animation
- Sports biomechanics analysis: multi-camera systems track athlete joint angles and velocities for injury prevention and performance optimisation
- Stereo vision depth estimation: triangulation from two calibrated views is the core of stereo cameras used in autonomous vehicles and robotics
- Augmented reality: projecting virtual objects into a real camera view requires the same K·[R|t] projection model implemented in Project.m

## Challenges
- **Radial distortion correction**: lens distortion displaces image points from their ideal positions — the k₁r²+k₂r⁴ correction must be applied after projection because the correction magnitude depends on the projected pixel's distance from the principal point, creating a chicken-and-egg dependency between the ideal and distorted coordinates
- **Triangulation degeneracy**: when two rays are nearly parallel (the 3D point is far from both cameras relative to their baseline), the nearest-midpoint formula becomes numerically unstable — small angular errors in the back-projected rays produce disproportionately large errors in the reconstructed 3D position
- **Coordinate frame alignment**: mocap data and camera calibration use independent 3D coordinate systems — the world origin, axis orientation, and scale must match exactly for the L2 error comparison against ground truth to be valid; a misaligned frame produces large apparent errors even when the triangulation itself is correct
- **Occlusion and invalid joints**: not all 12 joints are visible in every mocap frame — including frames with missing joints in the error statistics biases the mean and std; the valid-frame filter (requiring all 12 joints present) in QuantitativeAnalysis.m is essential for meaningful accuracy reporting

---

## Pipeline

```
3D Mocap Joints (12 joints × N frames)
        │
        ▼
 Project.m  ←  K · [R|t] · [X Y Z 1]ᵀ  +  radial distortion (k1·r², k2·r⁴)
        │  2D pixel coordinates on each camera view
        ▼
 BackProject.m  ←  R⁻¹ · K⁻¹ · [u v 1]ᵀ  →  normalised 3D ray
        │
        ▼
 Triangulate.m  ←  nearest midpoint of two rays (cross-product formula)
        │  reconstructed 3D positions
        ▼
 ProcessData.m  ←  L2 error  =  ‖triangulated − mocap ground truth‖ per joint
        │
        ├─ QuantitativeAnalysis.m  ←  mean / std / median / min / max per joint and global
        └─ QualitativeAnalysis.m   ←  projected joints + epipolar lines + skeleton overlay on video frames
```

---

## Functions

| File | Description |
|---|---|
| `Project.m` | 3D→2D projection: K·[R\|t] camera model, homogeneous coordinates, optional radial distortion correction |
| `BackProject.m` | 2D→3D: inverts K and R to compute a unit direction ray for each image point |
| `Triangulate.m` | Two-view triangulation via nearest midpoint of two rays using cross-product formula |
| `ProcessFrame.m` | Per-frame pipeline: project → back-project → triangulate → compute epipolar lines |
| `ProcessData.m` | Batch pipeline across all mocap frames; computes per-joint L2 error vs ground truth |
| `QuantitativeAnalysis.m` | Per-joint and global statistics; plots total L2 error per frame |
| `QualitativeAnalysis.m` | Visual overlay of projected joints (green) and re-projected triangulations (red) on video frames |
| `DrawJoints.m` | Draws joint points with epipolar lines on a camera image |
| `DrawSkeleton.m` | Renders 12-joint skeleton (arms, legs, spine) from projected 2D points |
| `project2.m` | Main driver script |

---

## Tech Stack

| Item | Detail |
|---|---|
| Language | MATLAB |
| Input | 3D mocap joints (12 joints, Subject 4 Session 3 Take 4); two camera calibrations (vue2, vue4) |
| Libraries | None — all geometry implemented from scratch |

---

## Project Structure

```
Camera-Projection-and-Triangulation/
├── src/
│   ├── Project.m                ← 3D→2D projection with radial distortion
│   ├── BackProject.m            ← 2D→3D ray back-projection
│   ├── Triangulate.m            ← two-view ray triangulation
│   ├── ProcessFrame.m           ← per-frame pipeline
│   ├── ProcessData.m            ← batch processing + L2 error
│   ├── QuantitativeAnalysis.m   ← error statistics and plots
│   ├── QualitativeAnalysis.m    ← visual overlay on video frames
│   ├── DrawJoints.m             ← draw joints + epipolar lines
│   ├── DrawSkeleton.m           ← skeleton renderer
│   └── project2.m               ← main driver script
├── data/
│   ├── Subject4-Session3-Take4_mocapJoints.mat
│   ├── vue2CalibInfo.mat
│   └── vue4CalibInfo.mat
└── index.html                   ← pipeline walkthrough (GitHub Pages)
```

---

## Run

**Requirements:** MATLAB. Video files (`Vue2.mp4`, `Vue4.mp4`) must be placed alongside `data/` — not included in the repo due to size.

```matlab
% From MATLAB, navigate to src/
cd src
project2
```

---

## Course

TBD  
The Pennsylvania State University
