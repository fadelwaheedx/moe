# EcoSys IT Playbook — VitePress (GitHub Pages)

A ready-to-run VitePress documentation site (Laravel-docs style sidebar) with:
- English + Arabic structure
- Local search
- Mermaid diagrams
- Monochrome government theme
- GitHub Pages deployment workflow

## Run locally
```bash
npm install
npm run dev
```

## GitHub Pages
1) Repo → Settings → Pages → Source: GitHub Actions  
2) The workflow sets BASE to `/<repo>/` for Project Pages.  
   If you use a custom domain (or user/org pages), set BASE to `/` in `.github/workflows/deploy.yml`.

Edit sidebar: `docs/.vitepress/config.mts`
