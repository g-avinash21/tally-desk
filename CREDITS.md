# Ideas and credits

Tally Desk is one offline HTML file. No code from the projects below is copied into it.
They were suggested as references, and only their **ideas** were written afresh in plain JavaScript.
The repositories were not opened or audited when the ideas were taken; the notes below say what each is
described as doing.

| Project | What it is described as doing | Idea used in Tally Desk |
|---|---|---|
| Rakeshks7/gst-recon-engine | GST matching that runs in the browser | Invoice numbers compared after cleaning (INV-2023/01 = INV202301). Tally Desk already did this. |
| man-singh-dev/GSTLens | GST validation rules | Money worked in whole paise; IGST vs CGST/SGST checked against the state code; totals must carry through. Used in the background check. |
| arinbiki/GST-ITC-Reconciliation-Engine | Two-pass matching | Exact match first, then a controlled near match. Tally Desk already did this. |
| SHalimoosavi/SYJ-GST-Reconciliation | GST reconciliation with many automated tests | Built-in test cases with known answers that run every time the file opens. |
| Tamil-Venthan/Rekvia | Reconciliation with one-to-one pairing | Two identical bills are paired one-to-one and never double-matched. Tally Desk already did this; now covered by a start-up test. |
| KedarDamale/Automated-Reconcillation | Reconciliation separating date-only differences | Same invoice and tax with only the date different is marked "timing, not value". |
| Pritish-23/ITC-Guard | ITC risk tagging and supplier follow-up | Risk scoring already existed. |
| SGFGOV/sgf-gstin-validator | GSTIN format and checksum | GSTIN checksum check already existed. |
| resilient-tech/india-compliance | Indian GST features for ERPNext | Reference only. |
| aerele/reconciler | Supplier-wise and document-wise GSTR-2B view | Reference only. |
| S-Addithya/GST-Graph-Reconciliation-Engine | Risk levels across GSTR-1, 2B and 3B | Reference only. |

Checks written for Tally Desk itself: the Tally input GST ledger vs purchase register check, the
PASS / CHECK audit row in every Excel export, and the SHA-256 code of each source file printed on the
working paper.
