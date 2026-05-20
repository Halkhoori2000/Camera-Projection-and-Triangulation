# Camera Projection & Triangulation — MATLAB

Multi-view geometry pipeline implemented in MATLAB. Projects 3D motion capture joints onto two calibrated camera views, back-projects 2D image points to 3D rays, triangulates joint positions from two views, and evaluates triangulation accuracy against ground truth mocap data.

**[Live Demo →](https://halkhoori2000.github.io/Camera-Projection-and-Triangulation/)**

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
