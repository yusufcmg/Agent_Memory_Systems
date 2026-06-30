---
name: seo-technical-optimization
description: >
  Technical SEO audit and implementation. Core Web Vitals, structured data (JSON-LD),
  meta tags, sitemap, robots.txt, Lighthouse CI. Turkey-specific: Yandex, hreflang tr-TR,
  JobPosting schema for career sites. Trigger: "SEO audit", "technical SEO", structured data.
---

# SEO Technical Optimization Skill

Complete technical SEO implementation guide covering Core Web Vitals, structured data, meta tags, and Turkish market specifics.

## Audit Checklist Order

Run in this order — each section builds on the previous:

1. **Core Web Vitals** → `checklists/core-web-vitals.md`
2. **Meta tags** → `checklists/meta-tags-checklist.md`
3. **Structured data** → `checklists/structured-data-checklist.md`
4. **Sitemap + robots** → `templates/sitemap-template.xml` + `templates/robots-template.txt`

## Quick Wins (Do These First)

```html
<!-- 1. Title tag — max 60 chars, keyword first -->
<title>Yazılım Mühendisi İlanları | Kariyer Radarı</title>

<!-- 2. Meta description — max 155 chars -->
<meta name="description" content="Türkiye'nin en güncel yazılım mühendisliği iş ilanları. 5000+ pozisyon, hızlı başvuru." />

<!-- 3. Canonical -->
<link rel="canonical" href="https://example.com/current-page" />

<!-- 4. Open Graph -->
<meta property="og:title" content="..." />
<meta property="og:description" content="..." />
<meta property="og:image" content="https://example.com/og-image.jpg" />
<meta property="og:url" content="https://example.com/current-page" />
<meta property="og:type" content="website" />
```

## Structured Data (JSON-LD)

Use templates in `templates/`:
- `json-ld-jobposting.json` — JobPosting schema (critical for career sites)
- `json-ld-organization.json` — Organization schema
- `json-ld-faq.json` — FAQ schema for rich results

Inject as:
```html
<script type="application/ld+json">
  { /* paste template content here */ }
</script>
```

Validate at: https://search.google.com/test/rich-results

## Image Optimization

```html
<!-- Modern formats with fallback -->
<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="Descriptive alt text" width="800" height="600"
       loading="lazy" decoding="async" />
</picture>

<!-- Hero image: don't lazy-load, add fetchpriority -->
<img src="hero.webp" alt="..." fetchpriority="high" />
```

## Hreflang (TR/EN)

```html
<link rel="alternate" hreflang="tr-TR" href="https://example.com/tr/page" />
<link rel="alternate" hreflang="en-US" href="https://example.com/en/page" />
<link rel="alternate" hreflang="x-default" href="https://example.com/en/page" />
```

## URL Slug Normalization (Turkish Characters)

```javascript
function slugify(text) {
  const trMap = { 'ç':'c','ğ':'g','ı':'i','İ':'i','ö':'o','ş':'s','ü':'u',
                   'Ç':'c','Ğ':'g','Ö':'o','Ş':'s','Ü':'u' };
  return text
    .replace(/[çğışöüÇĞİÖŞÜ]/g, c => trMap[c] || c)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}
// "Yazılım Mühendisi" → "yazilim-muhendisi"
```

## Lighthouse CI (GitHub Actions)

```yaml
# .github/workflows/lighthouse.yml
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v11
  with:
    urls: |
      https://staging.example.com/
      https://staging.example.com/jobs
    budgetPath: .lighthouse-budget.json
    uploadArtifacts: true
```

```json
// .lighthouse-budget.json
[{
  "path": "/*",
  "timings": [
    {"metric": "largest-contentful-paint", "budget": 2500},
    {"metric": "total-blocking-time", "budget": 200}
  ],
  "resourceSizes": [{"resourceType": "total", "budget": 300}]
}]
```

## Turkey-Specific

### Search Console Setup
1. Google Search Console: verify via DNS TXT record
2. Yandex Webmaster: https://webmaster.yandex.com.tr — add site, verify
3. Submit sitemap to both

### Yandex-specific meta
```html
<meta name="yandex-verification" content="YOUR_CODE" />
```

### Google Rich Results for Jobs
JobPosting schema is **required** for Google for Jobs listings in Turkey.
Use `templates/json-ld-jobposting.json` — fill in all required fields.
Missing required fields → no rich result.

Required fields: title, datePosted, description, hiringOrganization, jobLocation

## Sitemap

Use FastAPI/Next.js dynamic sitemap endpoint:
- Template: `templates/sitemap-template.xml`
- Submit to GSC: Search Console → Sitemaps → Add URL

## Robots.txt

- Template: `templates/robots-template.txt`
- Block AI scrapers (optional, ethical decision): GPTBot, CCBot, Claude-Web, Google-Extended
- Never block Googlebot or Yandex

## Validation Tools

| Tool | URL | What it checks |
|------|-----|----------------|
| Rich Results Test | search.google.com/test/rich-results | JSON-LD structured data |
| PageSpeed Insights | pagespeed.web.dev | Core Web Vitals, field data |
| Schema Validator | validator.schema.org | Schema.org compliance |
| GSC Coverage | search.google.com | Indexing issues |
| Yandex Webmaster | webmaster.yandex.com.tr | Yandex indexing |
