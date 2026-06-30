# Core Web Vitals Checklist

Google's page experience signals. All three must be in "Good" range for ranking benefit.

## Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|------------------|------|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5–4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | ≤ 200ms | 200–500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | 0.1–0.25 | > 0.25 |

> Note: INP replaced FID (First Input Delay) in March 2024.

## Measurement

**Field data (real users):**
- Google Search Console → Core Web Vitals report
- PageSpeed Insights → Field Data tab (CrUX data)
- Chrome UX Report (BigQuery)

**Lab data (synthetic):**
- Lighthouse (Chrome DevTools or CLI)
- WebPageTest
- PageSpeed Insights → Lab Data tab

```bash
# Run Lighthouse CLI
npx lighthouse https://example.com --output=html --output-path=./lighthouse-report.html

# Run on mobile (simulate)
npx lighthouse https://example.com --form-factor=mobile --throttling-method=simulate
```

---

## LCP Optimization Checklist

LCP element is usually: hero image, H1, or above-the-fold text block.

### Identify LCP element
```javascript
// In browser console
new PerformanceObserver((list) => {
  const entries = list.getEntries();
  const lastEntry = entries[entries.length - 1];
  console.log('LCP element:', lastEntry.element);
  console.log('LCP time:', lastEntry.startTime);
}).observe({type: 'largest-contentful-paint', buffered: true});
```

### Image LCP fixes
- [ ] Use `fetchpriority="high"` on LCP image
- [ ] Do NOT use `loading="lazy"` on LCP image
- [ ] Preload LCP image: `<link rel="preload" as="image" href="hero.webp" />`
- [ ] Serve in WebP or AVIF format
- [ ] Set explicit `width` and `height` attributes
- [ ] Use CDN with edge caching

### Text LCP fixes
- [ ] Preload critical fonts: `<link rel="preload" as="font" href="font.woff2" crossorigin />`
- [ ] Use `font-display: swap` in @font-face
- [ ] Inline critical CSS (above-the-fold styles)
- [ ] Remove render-blocking resources

### Server fixes
- [ ] Time to First Byte (TTFB) < 800ms
- [ ] Enable HTTP/2 or HTTP/3
- [ ] CDN caching for static assets
- [ ] Enable Brotli/gzip compression

---

## INP Optimization Checklist

INP measures responsiveness to all user interactions (click, tap, keyboard).

### Identify slow interactions
```javascript
// Log slow interactions
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.duration > 200) {
      console.warn('Slow interaction:', entry.name, entry.duration + 'ms');
    }
  }
}).observe({type: 'event', buffered: true, durationThreshold: 200});
```

### Fix checklist
- [ ] Break up long JavaScript tasks (> 50ms) with `scheduler.yield()` or `setTimeout(0)`
- [ ] Debounce expensive event handlers (input, scroll, resize)
- [ ] Use Web Workers for CPU-intensive work
- [ ] Avoid layout thrashing (read then write DOM, never interleave)
- [ ] Virtualize long lists (react-window, TanStack Virtual)
- [ ] Lazy-load non-critical components

```javascript
// Break up long task
async function processItems(items) {
  for (const item of items) {
    processItem(item);
    await scheduler.yield(); // yield to browser between items
  }
}
```

---

## CLS Optimization Checklist

CLS measures unexpected layout shifts — usually caused by images without dimensions, ads, or late-loading content.

### Identify CLS sources
- Chrome DevTools → Performance tab → record → look for "Layout Shift" entries
- `cls-debugger` bookmarklet

### Fix checklist
- [ ] Always set `width` and `height` on `<img>` tags
- [ ] Reserve space for dynamic content (skeleton screens, min-height)
- [ ] Avoid inserting content above existing content (banners, cookie notices)
- [ ] Use CSS `transform` for animations (not top/left/margin)
- [ ] Font loading: use `font-display: optional` if CLS is caused by font swap

```css
/* Reserve space for images */
img {
  aspect-ratio: 16 / 9;
  width: 100%;
  height: auto;
}
```

---

## Quick Wins by Impact

| Fix | Metric | Impact | Effort |
|-----|--------|--------|--------|
| Add `fetchpriority="high"` to hero image | LCP | High | Low |
| Remove unused JavaScript | INP | High | Medium |
| Serve WebP/AVIF images | LCP | High | Low |
| Set image dimensions | CLS | High | Low |
| Preload critical fonts | LCP | Medium | Low |
| Enable CDN caching | LCP, TTFB | High | Medium |
| Break up long JS tasks | INP | High | High |
| Remove render-blocking CSS | LCP | Medium | Medium |
