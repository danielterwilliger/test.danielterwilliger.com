# danielterwilliger.com

Personal site and portfolio of Daniel C. Terwilliger — hand-rolled static HTML/CSS, hosted on GitHub Pages.

**Process:** all work follows [docs/SDLC.md](docs/SDLC.md) — everything gets an issue, everything lands by PR, and changes promote test → uat → prod. Environments: [test](https://test.danielterwilliger.com) · [uat](https://uat.danielterwilliger.com) · [prod](https://danielterwilliger.com).

- `index.html` — landing page (profile, selected work, experience)
- `work/` — case-study pages
- `profile.md` — plain-markdown experience record for agents/ATS
- `llms.txt` — machine-readable index (llms.txt convention)

Local dev: serve the repo root with any static server, e.g. `python -m http.server 4173`.
