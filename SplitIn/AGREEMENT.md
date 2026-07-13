# Team Development Agreement
*Panduan best practice profesional untuk branching, coding standard, workflow, dan Pull Request.*

## Daftar Isi
1. [Branching Strategy](#1-branching-strategy)
2. [Code Standard](#2-code-standard)
3. [Commit Message Convention](#3-commit-message-convention)
4. [Workflow Harian](#4-workflow-harian)
5. [Pull Request — Zero Conflict Practice](#5-pull-request--zero-conflict-practice)
6. [Code Review Standard](#6-code-review-standard)
7. [Issue & Task Management](#7-issue--task-management)

---

## 1. Branching Strategy

Menggunakan pendekatan **Git Flow** (ada branch tengah `develop` sebagai tempat integrasi & testing sebelum masuk `main`):

```
main        ← branch stabil, production-ready, jarang disentuh
  ↑
develop     ← branch staging, tempat semua fitur digabung & di-test
  ↑
feat/xxx    ← branch kerja individual, dibuat dari develop
fix/xxx
```

| Branch | Fungsi |
|---|---|
| `main` | Kode production-ready. Hanya menerima merge dari `develop` (rilis) atau `hotfix/*` (darurat). |
| `develop` | Tempat semua fitur digabung dan di-test bareng sebelum rilis. |
| `feat/*` | Fitur baru. Dibuat dari `develop`, PR-nya juga ke `develop`. |
| `fix/*` | Perbaikan bug (non-darurat). Dibuat dari `develop`, PR-nya juga ke `develop`. |
| `hotfix/*` | Perbaikan darurat di production. Dibuat dari `main`, di-merge ke `main` **dan** `develop`. |
| `chore/*` | Perubahan non-fitur (config, dependency, dokumentasi). Dari & ke `develop`. |

### Alur Kerja Branch
1. Branch `feat/*` / `fix/*` dibuat dari `develop` yang sudah ter-update (`git pull origin develop` dulu).
2. PR dibuka **ke `develop`**, bukan langsung ke `main`.
3. Semua fitur yang sudah masuk `develop` di-test bareng (integration testing) — di sinilah bug antar fitur biasanya ketauan sebelum sampai ke user.
4. Kalau `develop` sudah stabil dan fitur-fitur yang direncanakan untuk rilis sudah lolos test → `develop` di-merge ke `main` lewat PR release (opsional dikasih tag versi, mis. `v1.0.0`).
5. Kalau ada bug darurat di production: branch `hotfix/*` dari `main`, fix, lalu merge ke `main` **dan** `develop` sekaligus supaya `develop` tidak ketinggalan fix tersebut.

### Aturan Branch
- **Semua perubahan wajib lewat branch + Pull Request.** Tidak ada commit langsung ke `main` atau `develop`, sekecil apapun perubahannya.
- **Satu branch = satu tujuan.** Jangan campur fix bug dengan fitur baru dalam satu branch.
- **Short-lived branch**: idealnya selesai dan di-merge dalam 1–3 hari. Semakin lama branch hidup, semakin jauh menyimpang dari `develop`, semakin besar risiko conflict.
- Branch dihapus otomatis setelah PR di-merge (baik lokal maupun remote).

### Format Penamaan
```
feat/nama-fitur
fix/nama-bug
hotfix/nama-masalah
chore/deskripsi-singkat
```
Contoh: `feat/create-group`, `fix/wrong-total-calculation`, `hotfix/checkout-crash`, `chore/update-dependencies`

---

## 2. Code Standard

### Naming Convention

| Elemen | Format | Contoh |
|---|---|---|
| Class | PascalCase | `UserService`, `OrderController` |
| Interface | PascalCase | `UserRepository` |
| Function / Method | camelCase | `getUserData`, `createOrder` |
| Variable | camelCase | `userName`, `totalPrice` |
| Constant | SCREAMING_SNAKE_CASE | `MAX_LIMIT`, `BASE_URL` |
| File (JS/TS) | kebab-case | `user-service.ts`, `order-controller.ts` |
| React Component (file & fungsi) | PascalCase | `UserCard.tsx`, `function UserCard()` |
| Database Table | snake_case | `users`, `order_items` |
| Database Column | snake_case | `created_at`, `user_id` |
| CSS Class | kebab-case | `.main-header`, `.btn-primary` |
| Environment Variable | SCREAMING_SNAKE_CASE | `DATABASE_URL`, `JWT_SECRET` |

### Prinsip Clean Code
- **Single Responsibility** — satu function/component hanya melakukan satu hal.
- **DRY (Don't Repeat Yourself)** — logic yang berulang dijadikan reusable function/component.
- **No magic number/string** — pakai constant yang diberi nama jelas, bukan angka/string mentah di tengah logic.
- **Comment yang berguna** — jelaskan *kenapa*, bukan *apa* (kode yang jelas biasanya sudah menjelaskan "apa"-nya sendiri).
- Hapus `console.log`, kode mati (dead code), dan komentar yang sudah tidak relevan sebelum PR dibuka.

### Penggunaan AI Tools
- Boleh menggunakan AI untuk membantu coding, **tapi wajib dibaca, dipahami, dan diuji sendiri** sebelum commit — jangan asal paste.
- Penulis PR tetap bertanggung jawab penuh atas kualitas dan kebenaran kode yang dihasilkan AI.

---

## 3. Commit Message Convention

Menggunakan format **[Conventional Commits](https://www.conventionalcommits.org/)**:
```
<type>: <deskripsi singkat>

[opsional: penjelasan lebih detail]
```

| Type | Kapan Dipakai |
|---|---|
| `feat` | Menambah fitur baru |
| `fix` | Memperbaiki bug |
| `refactor` | Mengubah struktur kode tanpa mengubah behavior |
| `style` | Perubahan formatting, tidak mengubah logic |
| `docs` | Perubahan dokumentasi |
| `test` | Menambah/memperbaiki test |
| `chore` | Perubahan tooling, config, dependency |

Contoh:
```
feat: add create group functionality
fix: correct total calculation on checkout
refactor: extract validation logic to separate util
```

---

## 4. Workflow Harian

1. **Pull `develop`** sebelum mulai kerja setiap hari.
2. Buat/lanjutkan branch `feat/*` atau `fix/*` dari `develop` terbaru.
3. Kerjakan task, commit secara berkala dengan message yang jelas (jangan satu commit raksasa di akhir).
4. **Pull & merge `develop`** ke branch sendiri secara berkala (minimal sekali sehari) — jangan tunggu sampai mau PR baru sinkron.
5. Push ke branch masing-masing.
6. Jalankan test/self-review sebelum membuka PR.
7. Buka PR **ke `develop`**, minta review.
8. Setelah cukup fitur terkumpul dan `develop` stabil, dibuat PR release dari `develop` ke `main`.

**Prinsip kerja:**
- Komunikasi dulu sebelum menyentuh file yang sedang dikerjakan orang lain.
- Update progress secara rutin ke tim (harian/per-task selesai).

---

## 5. Pull Request — Zero Conflict Practice

Tujuan: meminimalkan risiko merge conflict lewat kebiasaan kerja, bukan cuma menyelesaikannya setelah terjadi.

### 5.1 Sebelum Mulai Task
- Pastikan task tidak overlap file/komponen dengan task lain yang sedang berjalan. Kalau ada kemungkinan overlap, tandai di issue dan koordinasi dengan pemilik task lain.
- Branch dari `develop` yang sudah paling baru.

### 5.2 Selama Mengerjakan
- **PR kecil dan fokus** — satu PR idealnya < 400 baris perubahan dan hanya untuk satu task/fitur. PR besar lebih sulit direview dan lebih rawan conflict karena lama nyangkut.
- Sinkron dengan `develop` secara rutin (rebase atau merge, sesuai kesepakatan tim), jangan biarkan branch menyimpang terlalu jauh.
- Hindari refactor besar-besaran di file yang juga sedang disentuh anggota lain — pisahkan jadi task/PR sendiri dan koordinasikan waktunya.

### 5.3 Sebelum Membuka PR
- Sinkronkan branch dengan `develop` terbaru, selesaikan conflict (kalau ada) **secara lokal**, baru push.
- Pastikan build/test lolos di branch sendiri sebelum minta review.
- PR mengarah **ke `develop`**, bukan `main` (kecuali PR release atau hotfix).

### 5.4 Urutan Merge
- PR yang **sudah approved dan siap duluan → merge duluan** ke `develop`.
- PR lain yang masih terbuka wajib sync ulang ke `develop` dan re-test setelah ada PR yang merge sebelumnya.

### 5.5 Kalau Conflict Tetap Terjadi
- Selesaikan bersama pemilik kode yang bentrok — diskusikan lewat chat/call singkat, jangan menimpa/memilih salah satu versi secara sepihak.
- Setelah resolve, jalankan ulang test sebelum push.

### 5.6 Template PR
```
## Title
[FEATURE] Nama fitur singkat

## What
- Apa yang ditambahkan/diubah
- Komponen/file utama yang terdampak

## How to Test
- Langkah spesifik untuk mereview/testing perubahan ini

## Screenshots (jika ada perubahan UI)
```

### 5.7 Merge Strategy
- Gunakan **Squash & Merge** ke `main` supaya history tetap bersih (satu PR = satu commit di `main`).

---

## 6. Code Review Standard
- Minimal **1 reviewer approve** sebelum merge.
- Reviewer memeriksa: kesesuaian dengan task, clean code standard, potensi bug, dan ada/tidaknya test.
- Beri feedback yang spesifik dan actionable, bukan sekadar "kurang rapi".
- Penulis PR wajib merespons/mengatasi semua comment sebelum merge.

---

## 7. Issue & Task Management

1. **Issue utama** merepresentasikan flow/user story besar:
   ```
   [FLOW-1] Create Group & Add Member
   [FLOW-2] Input Nota & Daftar Item
   ```
2. **Sub-task** dipecah dari issue utama:
   ```
   [1-TASK-01] Buat Desain UI ...
   [2-TASK-01] Buat API endpoint ...
   ```
3. Setiap sub-task punya **Acceptance Criteria (AC)** yang jelas dan dicentang saat selesai.
4. Update status task (in progress/done) dan share progress secara rutin ke tim.

