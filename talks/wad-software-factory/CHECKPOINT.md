# Workshop checkpoint — 2026-09-16

Both implementation repositories were clean at delivery and are independently committed.

| Repository | Original delivery | Current revision | Tags |
|---|---|---|---|
| wad-factory-workshop | 702a3bbb2652ffe273fc72c0861d8728f65840cc | 8632c0aeba7ce1ff934226f3fb4a2f1d54e45a1d | checkpoint/implementation-delivery-20260916; checkpoint/host-happy-path-20260916 |
| incident-triage-board | e15230f28c71e05584c0caf75b6ddec1bbc05b00 | unchanged | checkpoint/implementation-delivery-20260916; all five original app fixture tags |

The workshop verification commit includes small fixes, regression coverage, the real-host report and sanitized evidence. No remote is configured in either repository; nothing was pushed or published. Chapter checkpoint pairs still need resolving after launcher/distribution repair.

The separate test crew produced commit `d948870df2602cf1ab63f317c82873a4cbb0e07b`, reviewed by QA and passing 7/7 fixed acceptance checks. It is preserved as a complete bundle and patch, without changing the sample application's main branch. Restore with `git clone -b task/wad-101 .verification-backup/host-happy-101.bundle <destination>`.

See [the host verification report](wad-factory-workshop/HOST-VERIFICATION.md) for passes, failures, manual bootstrap boundaries and developer work. The real host launcher is not yet an attendee-ready happy path. The working test app remains at http://127.0.0.1:3088 while the dedicated sandbox is running.

## Local recovery archives

These ignored files exist locally; they are not remote backups. Both original delivery bundles and the candidate bundle were verified with git; a fresh candidate checkout was restored successfully.

| File | SHA-256 |
|---|---|
| `.verification-backup/workshop-delivery.bundle` | `ec84df86ae18c91669f6c602ce268c9433f8b2aeab695efd817fc5d7820d8c06` |
| `.verification-backup/app-delivery.bundle` | `c0b71eac0305249a1de033a2e7a53fa5ff9c34b742b75499bc2838425d96babe` |
| `.verification-backup/workshop-host-verified.bundle` | `2b1368cf6323f664007676cef3c146d97979e631edb3268bcfc51877496c46a9` |
| `.verification-backup/host-happy-101.bundle` | `c4be1965bf83d94551fab7f1ee2c4bf331992a4bd6fcb6bebbda647d4934cd46` |
| `.verification-backup/host-happy-101.patch` | `1807a9e6e59b390ba3cabc9922836b5ad253034731d2eceaa941fb35a32036e5` |
