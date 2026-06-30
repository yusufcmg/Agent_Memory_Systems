# Meta Tags Checklist

Meta tags control how your page appears in search results and social sharing.

## Required Tags (Every Page)

```html
<head>
  <!-- Character encoding — must be first -->
  <meta charset="UTF-8" />

  <!-- Viewport — required for mobile-first indexing -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <!-- Title — 50-60 chars, keyword first, brand last -->
  <title>Backend Developer İlanları | Kariyer Radarı</title>

  <!-- Meta description — 120-155 chars, include CTA -->
  <meta name="description" content="Türkiye'nin en güncel backend developer iş ilanları. 1500+ pozisyon, hızlı başvuru, günlük güncelleme." />

  <!-- Canonical — prevents duplicate content issues -->
  <link rel="canonical" href="https://example.com/jobs/backend" />
</head>
```

---

## Title Tag Rules

| Rule | Value |
|------|-------|
| Max length | 60 characters (Google truncates at ~580px) |
| Structure | Primary keyword → Secondary → Brand |
| Turkish example | `Yazılım Mühendisi İlanları | Kariyer Radarı` |
| Uniqueness | Every page must have a unique title |
| Avoid | All caps, keyword stuffing, duplicate across pages |

## Meta Description Rules

| Rule | Value |
|------|-------|
| Max length | 155 characters |
| Include | Primary keyword, value proposition, soft CTA |
| Turkish example | `2024'ün en iyi yazılım mühendisi fırsatları. Günlük güncellenen 5000+ ilan, hızlı başvuru.` |
| Note | Google may rewrite if it finds a better excerpt |

---

## Open Graph (Social Sharing)

Required for proper Facebook, LinkedIn, WhatsApp previews:

```html
<meta property="og:title" content="Backend Developer İlanları | Kariyer Radarı" />
<meta property="og:description" content="Türkiye'nin en güncel backend iş ilanları." />
<meta property="og:image" content="https://example.com/og/backend-jobs.jpg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:url" content="https://example.com/jobs/backend" />
<meta property="og:type" content="website" />
<meta property="og:locale" content="tr_TR" />
<meta property="og:site_name" content="Kariyer Radarı" />
```

OG image requirements:
- [ ] Minimum: 1200x630px (preferred)
- [ ] File size: < 1MB
- [ ] Format: JPG or PNG
- [ ] No sensitive content (will appear in previews)

## Twitter Cards

```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="Backend Developer İlanları" />
<meta name="twitter:description" content="Türkiye'nin en güncel backend iş ilanları." />
<meta name="twitter:image" content="https://example.com/og/backend-jobs.jpg" />
<meta name="twitter:site" content="@kariyerradari" />
```

---

## Robots Directives

```html
<!-- Default — allow indexing and following links -->
<meta name="robots" content="index, follow" />

<!-- Block indexing (paginated pages, search results, admin) -->
<meta name="robots" content="noindex, follow" />

<!-- Block link following (privacy policy, legal pages) -->
<meta name="robots" content="index, nofollow" />
```

**Pages to noindex:**
- Paginated pages beyond page 2 (or use canonical to page 1)
- Internal search results: `/search?q=...`
- Admin, login, profile pages
- Duplicate content (parameters: `?sort=`, `?color=`)
- Thank-you pages, confirmation pages

---

## Language and Region

```html
<!-- Primary language of page -->
<html lang="tr">

<!-- For TR/EN bilingual site — in <head> -->
<link rel="alternate" hreflang="tr-TR" href="https://example.com/tr/jobs" />
<link rel="alternate" hreflang="en-US" href="https://example.com/en/jobs" />
<link rel="alternate" hreflang="x-default" href="https://example.com/en/jobs" />
```

---

## Page-Specific Templates

### Homepage
```html
<title>Yazılım & Teknoloji İş İlanları | Kariyer Radarı</title>
<meta name="description" content="Türkiye'nin en büyük teknoloji iş ilanı platformu. 5000+ aktif pozisyon, günlük güncelleme." />
<meta property="og:type" content="website" />
```

### Job Listing Page
```html
<title>{jobTitle} - {company} | Kariyer Radarı</title>
<meta name="description" content="{company} şirketi {jobTitle} pozisyonu için {location}'da {employmentType} çalışan arıyor." />
```

### Category/Search Page
```html
<title>{keyword} İş İlanları {year} | Kariyer Radarı</title>
<!-- noindex if thin content or paginated beyond page 1 -->
```

---

## Checklist Summary

- [ ] Unique title (50-60 chars) on every page
- [ ] Meta description (120-155 chars) on every page
- [ ] Canonical URL set on every page
- [ ] OG tags (title, description, image, url) present
- [ ] Twitter card tags present
- [ ] `<html lang="tr">` set
- [ ] hreflang tags for multilingual pages
- [ ] Robots meta correct (noindex on thin/dupe pages)
- [ ] OG image 1200x630px, < 1MB
- [ ] No duplicate titles or descriptions across pages
