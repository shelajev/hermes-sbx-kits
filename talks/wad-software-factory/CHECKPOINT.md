# Workshop checkpoint — 2026-09-17

Both implementation repositories were clean at delivery and are independently committed.

| Repository | Original delivery | Current revision | Tags |
|---|---|---|---|
| wad-factory-workshop | 702a3bbb2652ffe273fc72c0861d8728f65840cc | 7b76f05b1e9032dca32fa026d22d5c48c4225d2d | checkpoint/implementation-delivery-20260916; checkpoint/host-happy-path-20260916; checkpoint/developer-fixes-20260917; checkpoint/host-startup-fixed-20260917 |
| incident-triage-board | e15230f28c71e05584c0caf75b6ddec1bbc05b00 | unchanged | checkpoint/implementation-delivery-20260916; all five original app fixture tags |

The workshop verification commit includes small fixes, regression coverage, the real-host report and sanitized evidence. No remote is configured in either repository; nothing was pushed or published. Chapter checkpoint pairs still need resolving after distribution packaging.

The separate test crew produced commit `d948870df2602cf1ab63f317c82873a4cbb0e07b`, reviewed by QA and passing 7/7 fixed acceptance checks. It is preserved as a complete bundle and patch, without changing the sample application's main branch. Restore with `git clone -b task/wad-101 .verification-backup/host-happy-101.bundle <destination>`.

The second pass completed both launcher entry profiles through collection and acceptance:
`b71c65ae668bf0835ca5ece3f24bec4e522abf73` passed 7/7, and
`0bb1bc8db063b03e064dabeb0745e9ed6004b826` passed 13/13 with the corrected v3
assignee-display assertion. Each export passed 18/18 checks. See
[the second host report](wad-factory-workshop/HOST-VERIFICATION-2.md) for the actual
CLI verification, the preserved v2 false-negative, and remaining distribution,
provider and preview-refresh limitations. The original host report remains historical.

## Local recovery archives

These ignored files exist locally; they are not remote backups. Both original delivery bundles and the candidate bundle were verified with git; a fresh candidate checkout was restored successfully.

| File | SHA-256 |
|---|---|
| `.verification-backup/workshop-delivery.bundle` | `ec84df86ae18c91669f6c602ce268c9433f8b2aeab695efd817fc5d7820d8c06` |
| `.verification-backup/app-delivery.bundle` | `c0b71eac0305249a1de033a2e7a53fa5ff9c34b742b75499bc2838425d96babe` |
| `.verification-backup/workshop-host-verified.bundle` | `2b1368cf6323f664007676cef3c146d97979e631edb3268bcfc51877496c46a9` |
| `.verification-backup/host-happy-101.bundle` | `c4be1965bf83d94551fab7f1ee2c4bf331992a4bd6fcb6bebbda647d4934cd46` |
| `.verification-backup/host-happy-101.patch` | `1807a9e6e59b390ba3cabc9922836b5ad253034731d2eceaa941fb35a32036e5` |
| `.verification-backup/workshop-developer-fixes.bundle` | `9bcb8bb9fa9d401c380865bc54a29052f9bb15a1d32223b39edae4b7dc653534` |
| `.verification-backup/workshop-host-startup-fixed.bundle` | `d0aeea75778a98c6dbf4ba477d322a818401087f928d5677ccbffd6231f2dcb6` |
| `.verification-backup/warmup-second-pass.bundle` | `82df1021eeda05fbf4f1b6dedd5498862461a9b2b00785fc136a62cfe661a453` |
| `.verification-backup/mcp-second-pass.bundle` | `6bdbe9d741ffc88e1e1bbdb85cd20f5ac8ba446fb8dfe9a8ade768ffb5f6cdd8` |

The second-pass candidate bundles are incremental exports. Verify/fetch them from the preserved app repository, which contains their prerequisite commits; they are not standalone clones.
