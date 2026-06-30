---
name: sync-from-template
description: >
  Mevcut projede manuel değiştirilen agent/skill dosyalarını AMS2 şablonuna geri yansıt.
  T-001 sync-to-project.sh'in ters yönü — proje → AMS2 template senkronizasyonu.
  Kullanım: /sync-from-template [--diff] [--apply] [--agent <isim>] [--skill <isim>]
---

# /sync-from-template

Mevcut projede iyileştirdiğin bir agent veya skill'i AMS2 template'ine geri yansıt.

**Yön:** Proje `.claude/` → AMS2 template

**Güvenlik kısıtı:** `memory-bank/` içeriği ASLA yansıtılmaz (proje-spesifik).

---

## Kullanım

```bash
# Neyin farklı olduğunu gör (hiçbir şey değiştirmez)
/sync-from-template --diff

# Belirli bir agent'ı karşılaştır
/sync-from-template --diff --agent security

# Belirli bir skill'i karşılaştır
/sync-from-template --diff --skill kvkk-compliance

# Değişiklikleri AMS2'ye uygula (onay ister)
/sync-from-template --apply --agent security

# Tüm farklı dosyaları AMS2'ye uygula
/sync-from-template --apply
```

---

## Bu Komut Ne Yapar

1. **Tespit:** Mevcut projede `.claude/` altındaki dosyaları AMS2 template ile karşılaştırır
2. **Filtrele:** Yalnızca AMS2'de de var olan ama projede değiştirilmiş dosyaları listeler
3. **Göster:** `--diff` modunda farkları gösterir
4. **Sor:** `--apply` modunda her dosya için "Bu değişikliği AMS2'ye alsın mı?" sorar
5. **Kopyala:** Onaylanan dosyaları AMS2 template'ine yazar

---

## Neyi Yansıtır / Neyi Yansıtmaz

### Yansıtılabilir
- `.claude/agents/*.md` — Agent konfigürasyonları
- `.claude/skills/**/*.md` — Skill dosyaları
- `.claude/commands/*.md` — Komut dosyaları
- `.claude/rules/**/*.md` — Kural dosyaları

### ASLA Yansıtılmaz
- `.claude/memory-bank/**` — Proje-spesifik bağlam
- `.claude/settings.local.json` — Yerel ayarlar
- `.claude/active-skills.txt` — Proje-spesifik skill listesi
- `*.env`, `*.secret` — Hassas dosyalar

---

## Agent'a Verilen Görev

Bu komutu çalıştırdığında harness-optimizer agent aşağıdaki adımları izler:

1. **AMS2 yolu bul:** `~/.claude/` veya kullanıcının belirttiği AMS2 dizini
2. **Fark hesapla:** `diff -u <ams2-dosya> <proje-dosyası>` ile karşılaştır
3. **Filtrele:** Sadece proje tarafında değişmiş dosyaları listele
4. **Raporla:** Özet tablo: dosya adı, satır farkı, değişiklik türü
5. **Uygula (--apply):** Her dosya için onay al, AMS2'ye yaz

---

## Örnek Akış

```
Proje: ~/projects/kariyer_radari
AMS2:  ~/Agent_Memory_Systems2

Karşılaştırılıyor...

Değiştirilen dosyalar:
┌─────────────────────────────────┬──────────┬────────────────────┐
│ Dosya                           │ +Satır   │ -Satır             │
├─────────────────────────────────┼──────────┼────────────────────┤
│ agents/security.md              │ +12      │ -3                 │
│ skills/kvkk-compliance/SKILL.md │ +5       │ -0                 │
└─────────────────────────────────┴──────────┴────────────────────┘

security.md farkını AMS2'ye al? [y/N]: y
  ✅ Kopyalandı: ~/Agent_Memory_Systems2/.claude/agents/security.md

kvkk-compliance/SKILL.md farkını AMS2'ye al? [y/N]: n
  ⏭️  Atlandı

1 dosya güncellendi.
```

---

## Dikkat

- Bu komut AMS2 dosyalarını **değiştirir** — git commit yapmadan önce `--diff` ile kontrol et
- Proje-spesifik konfigürasyonları (env, token, özel path) kopyalamadan önce temizle
- AMS2'de bu değişiklikler `feat/` branch'ine girecekse önce branch aç

---

## İlgili Komutlar

- `scripts/sync-to-project.sh` — Ters yön: AMS2 → Proje
- `/sync-memory` — memory-bank ile kod senkronizasyonu (farklı iş)
- `/status` — Mevcut görev durumu
