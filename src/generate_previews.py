"""
Replicates project2.m pipeline and saves preview images to data/previews/.
Run from repo root: python3 src/generate_previews.py
Requires: numpy scipy matplotlib Pillow
"""

import numpy as np
import scipy.io as sio
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from pathlib import Path

OUT = Path("data/previews")
OUT.mkdir(parents=True, exist_ok=True)

# ── Load data ────────────────────────────────────────────────────────────────
print("Loading data...")
vue2 = sio.loadmat("data/vue2CalibInfo.mat", squeeze_me=True, struct_as_record=False)["vue2"]
vue4 = sio.loadmat("data/vue4CalibInfo.mat", squeeze_me=True, struct_as_record=False)["vue4"]
mocap = sio.loadmat("data/Subject4-Session3-Take4_mocapJoints.mat",
                     squeeze_me=True, struct_as_record=False)["mocapJoints"]
print(f"  mocapJoints: {mocap.shape}  (frames × joints × [x,y,z,valid])")

# ── Camera model (replicates Project.m) ─────────────────────────────────────
def project(pts3D, calib, correct_nl=True):
    """3D world points (3×N) → 2D pixel coords (2×N)."""
    n = pts3D.shape[1]
    aug = np.vstack([pts3D, np.ones((1, n))])
    P4 = np.vstack([calib.Pmat, [0, 0, 0, 1]])
    cam = np.hstack([calib.Kmat, np.zeros((3, 1))])
    t2d = cam @ (P4 @ aug)
    p2d = t2d[:2] / t2d[2]
    if correct_nl:
        o = np.tile(calib.prinpoint.reshape(2, 1), (1, n))
        r = np.linalg.norm(p2d - o, axis=0)
        k = calib.radial
        corr = (p2d - o) * (k[0] * r**2 + k[1] * r**4)
        p2d = p2d - corr
    return p2d

def backproject(p2d, calib):
    """2D pixel coords (2×N) → unit rays (3×N)."""
    n = p2d.shape[1]
    aug = np.vstack([p2d, np.ones((1, n))])
    rays = np.linalg.inv(calib.Rmat) @ np.linalg.inv(calib.Kmat) @ aug
    return rays / np.linalg.norm(rays, axis=0)

def triangulate(r1, r2, pos1, pos2):
    """Two-view triangulation via ray nearest-midpoint."""
    n = r2.shape[1]
    n1 = np.cross(r2.T, np.cross(r1.T, r2.T)).T
    n2 = np.cross(r1.T, np.cross(r2.T, r1.T)).T
    p1 = np.tile(pos1.reshape(3, 1), (1, n))
    p2 = np.tile(pos2.reshape(3, 1), (1, n))
    s1 = p1 + np.sum((p2 - p1) * n1, axis=0) / np.sum(r1 * n1, axis=0) * r1
    s2 = p2 + np.sum((p1 - p2) * n2, axis=0) / np.sum(r2 * n2, axis=0) * r2
    return (s1 + s2) / 2

# ── Skeleton drawing ─────────────────────────────────────────────────────────
LIMBS = [
    ([0, 1, 2],   "#4ade80", "Right arm"),    # joints 1-3 → indices 0-2
    ([3, 4, 5],   "#fb923c", "Left arm"),
    ([6, 7, 8],   "#f472b6", "Right leg"),
    ([9, 10, 11], "#60a5fa", "Left leg"),
    ([6, 9],      "#c084fc", "Shoulder"),
    ([0, 3],      "#c084fc", "Hip"),
]

def draw_skeleton_2d(ax, pts2d, valid, color_override=None, alpha=1.0, lw=2):
    """Draw 2D skeleton on axes. pts2d: (2, 12), valid: (12,)"""
    for indices, color, _ in LIMBS:
        c = color_override or color
        xs = [pts2d[0, i] for i in indices if valid[i]]
        ys = [pts2d[1, i] for i in indices if valid[i]]
        if len(xs) >= 2:
            ax.plot(xs, ys, '-o', color=c, linewidth=lw, markersize=5,
                    alpha=alpha, solid_capstyle='round')
    # Spine: midpoint(hip) → midpoint(shoulder)
    if all(valid[[0, 3, 6, 9]]):
        hip_mid = pts2d[:, [0, 3]].mean(axis=1)
        sho_mid = pts2d[:, [6, 9]].mean(axis=1)
        ax.plot([hip_mid[0], sho_mid[0]], [hip_mid[1], sho_mid[1]],
                '-', color=color_override or "#c084fc", linewidth=lw,
                alpha=alpha, solid_capstyle='round')

# ── Stage 1: Projected skeletons — sample frame ──────────────────────────────
FRAME = 1235  # same frame used in project2.m QualitativeAnalysis call
print(f"Stage 1: Projected skeletons for frame {FRAME}")

frame_data = mocap[FRAME]           # (12, 4)
xyz = frame_data[:, :3].T           # (3, 12)
valid = frame_data[:, 3].astype(bool)

p2d_v2 = project(xyz, vue2, correct_nl=True)   # (2, 12)
p2d_v4 = project(xyz, vue4, correct_nl=True)

# Epipoles
ep2 = project(vue4.position.reshape(3, 1), vue2, correct_nl=False).flatten()
ep4 = project(vue2.position.reshape(3, 1), vue4, correct_nl=False).flatten()

IMG_W, IMG_H = 1920, 1080  # approximate sensor resolution from principal point

for cam_name, p2d, ep, calib in [("vue2", p2d_v2, ep2, vue2),
                                    ("vue4", p2d_v4, ep4, vue4)]:
    fig, ax = plt.subplots(figsize=(10, 6))
    fig.patch.set_facecolor("#0d1117")
    ax.set_facecolor("#161b22")

    # Draw epipolar lines through each joint toward the epipole
    for i in range(12):
        if valid[i]:
            jx, jy = p2d[0, i], p2d[1, i]
            dx, dy = ep[0] - jx, ep[1] - jy
            length = np.sqrt(dx**2 + dy**2) + 1e-9
            ax.plot([jx - dx / length * 300, jx + dx / length * 300],
                    [jy - dy / length * 300, jy + dy / length * 300],
                    '-', color='#30363d', linewidth=1, alpha=0.7)

    # Draw mocap projection (green = ground truth)
    draw_skeleton_2d(ax, p2d, valid, alpha=1.0, lw=2.5)

    # Triangulate and re-project (red = reconstructed)
    r1 = backproject(p2d_v2, vue2)
    r2 = backproject(p2d_v4, vue4)
    tri = triangulate(r1, r2, vue2.position, vue4.position)
    p2d_tri = project(tri, calib, correct_nl=False)
    draw_skeleton_2d(ax, p2d_tri, valid, color_override="#f87171", alpha=0.85, lw=2)

    ax.set_xlim(0, IMG_W)
    ax.set_ylim(IMG_H, 0)
    ax.set_aspect('equal')
    ax.set_title(f"Camera {cam_name.upper()} — Frame {FRAME}",
                 color='#e6edf3', fontsize=13, pad=10)
    ax.tick_params(colors='#8b949e', labelsize=8)
    for spine in ax.spines.values():
        spine.set_edgecolor('#30363d')

    legend = [
        mpatches.Patch(color='#4ade80', label='Mocap projection (ground truth)'),
        mpatches.Patch(color='#f87171', label='Triangulated re-projection'),
        mpatches.Patch(color='#30363d', label='Epipolar lines'),
    ]
    ax.legend(handles=legend, loc='lower right', fontsize=9,
              facecolor='#161b22', edgecolor='#30363d', labelcolor='#e6edf3')

    out_path = OUT / f"skeleton_{cam_name}.png"
    plt.tight_layout()
    plt.savefig(out_path, dpi=130, bbox_inches='tight',
                facecolor=fig.get_facecolor())
    plt.close()
    print(f"  saved {out_path}")

# ── Stage 2: L2 error over frames ────────────────────────────────────────────
print("Stage 2: L2 error analysis across all frames")

# Only compute on frames where all 12 joints are valid (matches QuantitativeAnalysis.m)
all_valid = (mocap[:, :, 3] == 1).all(axis=1)
valid_frames = np.where(all_valid)[0]
print(f"  {len(valid_frames)} fully valid frames out of {mocap.shape[0]}")

SAMPLE = valid_frames[::50]  # every 50th valid frame for speed
l2_errors = np.zeros((len(SAMPLE), 12))

for i, f in enumerate(SAMPLE):
    fd = mocap[f]
    xyz_f = fd[:, :3].T
    r1_f = backproject(project(xyz_f, vue2), vue2)
    r2_f = backproject(project(xyz_f, vue4), vue4)
    tri_f = triangulate(r1_f, r2_f, vue2.position, vue4.position)
    l2_errors[i] = np.linalg.norm(xyz_f - tri_f, axis=0)

total_err = l2_errors.sum(axis=1)

fig, axes = plt.subplots(2, 1, figsize=(11, 7))
fig.patch.set_facecolor("#0d1117")

# Top: total L2 error per frame
ax = axes[0]
ax.set_facecolor("#161b22")
ax.plot(SAMPLE, total_err, color='#388bfd', linewidth=1.2, alpha=0.9)
ax.fill_between(SAMPLE, total_err, alpha=0.15, color='#388bfd')
ax.set_title("Total L2 Triangulation Error per Frame (sum over 12 joints)",
             color='#e6edf3', fontsize=12, pad=8)
ax.set_xlabel("Mocap Frame", color='#8b949e', fontsize=10)
ax.set_ylabel("L2 Error (mm)", color='#8b949e', fontsize=10)
ax.tick_params(colors='#8b949e')
for spine in ax.spines.values():
    spine.set_edgecolor('#30363d')

# Bottom: per-joint mean error bar chart
ax2 = axes[1]
ax2.set_facecolor("#161b22")
joint_means = l2_errors.mean(axis=0)
joint_stds  = l2_errors.std(axis=0)
colors_bar = (
    ["#4ade80"] * 3 +   # right arm
    ["#fb923c"] * 3 +   # left arm
    ["#f472b6"] * 3 +   # right leg
    ["#60a5fa"] * 3     # left leg
)
bars = ax2.bar(range(1, 13), joint_means, yerr=joint_stds,
               color=colors_bar, capsize=4, error_kw={"color": "#8b949e", "lw": 1.2})
ax2.set_title("Mean L2 Error per Joint (± std) across Valid Frames",
              color='#e6edf3', fontsize=12, pad=8)
ax2.set_xlabel("Joint Index", color='#8b949e', fontsize=10)
ax2.set_ylabel("L2 Error (mm)", color='#8b949e', fontsize=10)
ax2.set_xticks(range(1, 13))
ax2.tick_params(colors='#8b949e')
for spine in ax2.spines.values():
    spine.set_edgecolor('#30363d')

legend2 = [
    mpatches.Patch(color='#4ade80', label='Right arm (1–3)'),
    mpatches.Patch(color='#fb923c', label='Left arm (4–6)'),
    mpatches.Patch(color='#f472b6', label='Right leg (7–9)'),
    mpatches.Patch(color='#60a5fa', label='Left leg (10–12)'),
]
ax2.legend(handles=legend2, fontsize=9, facecolor='#161b22',
           edgecolor='#30363d', labelcolor='#e6edf3')

plt.tight_layout(pad=2)
err_path = OUT / "l2_error.png"
plt.savefig(err_path, dpi=130, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.close()
print(f"  saved {err_path}")

# ── Stage 3: 3D skeleton snapshot ────────────────────────────────────────────
print("Stage 3: 3D skeleton snapshot")

fig = plt.figure(figsize=(8, 6))
fig.patch.set_facecolor("#0d1117")
ax3 = fig.add_subplot(111, projection='3d')
ax3.set_facecolor("#161b22")

fd = mocap[FRAME]
xyz_f = fd[:, :3]     # (12, 3)
valid_f = fd[:, 3].astype(bool)

for indices, color, label in LIMBS:
    pts = [xyz_f[i] for i in indices if valid_f[i]]
    if len(pts) >= 2:
        pts = np.array(pts)
        ax3.plot(pts[:, 0], pts[:, 1], pts[:, 2],
                 '-o', color=color, linewidth=2, markersize=5)

# Spine
if all(valid_f[[0, 3, 6, 9]]):
    hip_mid = xyz_f[[0, 3]].mean(axis=0)
    sho_mid = xyz_f[[6, 9]].mean(axis=0)
    ax3.plot([hip_mid[0], sho_mid[0]],
             [hip_mid[1], sho_mid[1]],
             [hip_mid[2], sho_mid[2]],
             '-', color='#c084fc', linewidth=2)

ax3.set_title(f"3D Mocap Skeleton — Frame {FRAME}",
              color='#e6edf3', fontsize=12, pad=10)
ax3.tick_params(colors='#8b949e', labelsize=7)
ax3.xaxis.pane.fill = False
ax3.yaxis.pane.fill = False
ax3.zaxis.pane.fill = False
ax3.xaxis.pane.set_edgecolor('#30363d')
ax3.yaxis.pane.set_edgecolor('#30363d')
ax3.zaxis.pane.set_edgecolor('#30363d')
ax3.set_xlabel("X (mm)", color='#8b949e', fontsize=8)
ax3.set_ylabel("Y (mm)", color='#8b949e', fontsize=8)
ax3.set_zlabel("Z (mm)", color='#8b949e', fontsize=8)

skel_path = OUT / "skeleton_3d.png"
plt.tight_layout()
plt.savefig(skel_path, dpi=130, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.close()
print(f"  saved {skel_path}")

print("Done.")
