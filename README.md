# Tally Desk

**Open the tool:** https://g-avinash21.github.io/tally-desk/ (or download `Tally_Desk.html`).

Offline, single-file workbench for TallyPrime — bank statements to Tally, bank reconciliation, suspense clearing, GST and TDS (Income-tax Act 2025) reconciliations, and a compliance health check. Concept by Avinash G.

## Files

| File | What it is |
|---|---|
| `Tally_Desk.html` | The tool. Open in Chrome or Edge. |
| `Tally_Desk_Auto.zip` | The tool + `Tally Desk Auto.bat` (connects to TallyPrime on port 9000). Unzip once and run the .bat. |
| `Tally_Desk_MCP.zip` | Optional MCP server so an AI assistant can read your books and draft entries or ledgers that you approve. Kill switch (`read_only`), blocked ledgers, duplicate refusal, read-back from Tally after posting. See `MCP Setup.txt` inside. |
| `Tally_Desk_AI_Pack.tdpack` | Optional AI pack (≈19 MB). Install inside the tool: Bank Statement → Tally → Learning Engine → Install from pack file. |
| `Tally_Desk_Handbook.pdf` | Plain-language guide to every module. |

## Start

1. In TallyPrime: F1 Help → Settings → Connectivity → TallyPrime acts as Server, port 9000.
2. Unzip `Tally_Desk_Auto.zip`, run `Tally Desk Auto.bat` and keep its window open.
3. Open `Tally_Desk.html`, click the status badge at the top and Sync. Pick the company and year.

Everything runs on your computer; nothing is uploaded. The only internet use is the optional "Download & install" of the AI pack.

## Open-source parts
Tesseract.js 5, tesseract.js-core and the English model (Apache-2.0) · jsQR (Apache-2.0) · simple-statistics (ISC) · Razorpay IFSC bank data (MIT) · kharchalens narration clean-up idea (MIT) · AI pack: all-MiniLM-L6-v2 (Apache-2.0) with ONNX Runtime Web (MIT).
