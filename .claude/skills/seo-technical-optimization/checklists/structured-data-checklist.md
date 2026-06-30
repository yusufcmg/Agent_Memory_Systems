# Structured Data Checklist

JSON-LD structured data enables Google rich results (job cards, FAQ dropdowns, org info).
Always validate before deploying: https://search.google.com/test/rich-results

## Schema Types by Page

| Page Type | Schema | Rich Result |
|-----------|--------|-------------|
| Job listing | JobPosting | Google for Jobs card |
| FAQ page | FAQPage | FAQ dropdown in SERP |
| Company/About | Organization | Knowledge panel |
| Article/Blog | Article | News carousel |
| Product | Product | Price/rating in SERP |
| Breadcrumb | BreadcrumbList | Path in SERP snippet |

---

## Implementation Checklist

### General Rules
- [ ] Use `<script type="application/ld+json">` — never mix with HTML attributes
- [ ] Place in `<head>` or anywhere in `<body>` (head preferred)
- [ ] One schema block per entity type per page
- [ ] Validate every schema before deploy
- [ ] Schema content must match visible page content (Google policy)

### JobPosting (Critical for Career Sites)

Required fields — Google will NOT show rich result without these:
- [ ] `title` — exact job title
- [ ] `datePosted` — ISO 8601 format (YYYY-MM-DD)
- [ ] `description` — full job description (min 50 chars)
- [ ] `hiringOrganization` — name + url + logo
- [ ] `jobLocation` → `addressLocality` + `addressCountry`

Strongly recommended:
- [ ] `validThrough` — expiry date
- [ ] `employmentType` — FULL_TIME / PART_TIME / CONTRACTOR / TEMPORARY / INTERN
- [ ] `baseSalary` → `minValue` + `maxValue` + `currency` + `unitText`
- [ ] `workHours` — e.g., "40 hours per week"
- [ ] `experienceRequirements`

Turkey-specific:
- [ ] `addressCountry: "TR"`
- [ ] `currency: "TRY"` for TL salaries
- [ ] `@language: "tr"` for Turkish content

Use template: `templates/json-ld-jobposting.json`

### Organization

- [ ] `name` — legal company name
- [ ] `url` — canonical homepage URL
- [ ] `logo` — ImageObject with url + width + height
- [ ] `sameAs` — LinkedIn, Twitter, Wikipedia URLs
- [ ] `contactPoint` — customer support email/phone
- [ ] `address` — PostalAddress for Turkish address

Use template: `templates/json-ld-organization.json`

### FAQPage

- [ ] Each `Question` has `name` (question text) and `acceptedAnswer.text` (full answer)
- [ ] Max 20 FAQ items (Google typically shows 3-4)
- [ ] FAQ content must be visible on the page (not hidden)
- [ ] Don't use for navigational questions ("How do I contact you?")

Use template: `templates/json-ld-faq.json`

### BreadcrumbList

- [ ] Each `ListItem` has `position` (1-indexed integer) and `item.name` + `item.id` (URL)
- [ ] Last breadcrumb = current page
- [ ] Matches visible breadcrumb trail on page

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "item": {"@id": "https://example.com", "name": "Ana Sayfa"}},
    {"@type": "ListItem", "position": 2, "item": {"@id": "https://example.com/jobs", "name": "İlanlar"}},
    {"@type": "ListItem", "position": 3, "item": {"@id": "https://example.com/jobs/backend", "name": "Backend Developer"}}
  ]
}
```

---

## Validation Workflow

1. **Before commit:** paste JSON into https://validator.schema.org
2. **Before deploy:** test at https://search.google.com/test/rich-results
3. **After deploy:** submit URL to Google Search Console → URL Inspection → Request indexing
4. **After indexing (2-5 days):** check GSC → Enhancements tab for errors

## Common Errors

| Error | Fix |
|-------|-----|
| "Missing field: description" | Add full text description (not HTML) |
| "Invalid date format" | Use ISO 8601: "2024-12-31" not "31.12.2024" |
| "Logo must be 112x112px minimum" | Resize logo, set exact width/height in schema |
| "Content mismatch" | Schema content must match what's visible on page |
| "URL not crawlable" | Check robots.txt — Google must be able to fetch the URL |
