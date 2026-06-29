# Servo as an alternative webview — feasibility, proof, and the blocker

Goal: let an app pick between the system webview (WKWebView) and **Servo** at
runtime (`PERRY_WEBVIEW=servo`), so Servo can be compared/tested as it matures.

## TL;DR

- ✅ **Servo builds in this environment** in ~3 min — `mozjs_sys` downloads a
  **prebuilt SpiderMonkey**, so the `autoconf2.13` / `llvm-config` toolchain
  gaps never matter. Full `servo` 0.1.1 stack (835 crates) links into a binary.
- ✅ **Servo runs and renders, verified headlessly** — a `SoftwareRenderingContext`
  probe loaded a page, composited frames, and reading back the pixel buffer
  showed the expected content (see "Proof" below).
- ⛔ **In-process integration is BLOCKED by a `libsqlite3-sys` conflict that
  cascades across perry's whole DB layer.** servo needs `rusqlite 0.37 →
  libsqlite3-sys 0.35`; perry uses `rusqlite 0.32 → libsqlite3-sys 0.30` AND
  `sqlx 0.8.6 → sqlx-sqlite → libsqlite3-sys 0.30`. Only one `links="sqlite3"`
  version is allowed per workspace lockfile, and it fails at **resolution time**
  (so `servo` can't be added even as an optional dep). Bumping rusqlite alone
  doesn't help — it then collides with sqlx. Unblocking requires a **coordinated
  `rusqlite 0.32→0.37` + `sqlx 0.8→0.9` migration** across sqlite/mysql/postgres,
  or running Servo **out-of-process**.

So the **engine is proven workable**; the **perry integration has a hard
prerequisite** — a coordinated rusqlite+sqlx DB-layer migration, or an
out-of-process Servo design (recommended).

## Proof (reproducible)

A standalone crate (`servo = "0.1"`, `url`, `dpi`) with this `main` rendered a
page offscreen and inspected the result:

```
RENDER loaded=true frames=12 size=400x300 red=118194/120000 nonwhite=118643/120000
SERVO_RENDER_OK
```

i.e. a page with `background:rgb(255,0,0)` came back **98.5% red** (the rest is
the white heading text) — Servo actually rendered it, no GUI. The verified
embedding shape (servo 0.1.1):

```rust
use dpi::PhysicalSize;
use servo::{DeviceIntRect, DeviceIntSize, LoadStatus, RenderingContext, ServoBuilder,
            SoftwareRenderingContext, WebView, WebViewBuilder, WebViewDelegate};
use url::Url;

#[derive(Clone)] struct Waker;
impl servo::EventLoopWaker for Waker {
    fn clone_box(&self) -> Box<dyn servo::EventLoopWaker> { Box::new(self.clone()) }
    fn wake(&self) {}                       // on AppKit: dispatch spin_event_loop to main queue
}
struct State { loaded: std::cell::Cell<bool> }
impl WebViewDelegate for State {
    fn notify_load_status_changed(&self, _: WebView, s: LoadStatus) {
        if matches!(s, LoadStatus::Complete) { self.loaded.set(true); }
    }
    fn notify_new_frame_ready(&self, _: WebView) { /* request paint+present */ }
}

let rc = std::rc::Rc::new(SoftwareRenderingContext::new(PhysicalSize::new(w, h))?);
rc.make_current()?;
let servo = ServoBuilder::default().event_loop_waker(Box::new(Waker)).build();
let wv = WebViewBuilder::new(&servo, rc.clone()).url(Url::parse(html)?).delegate(state).build();
wv.focus(); wv.resize(PhysicalSize::new(w, h));
// loop: servo.spin_event_loop(); wv.paint(); rc.present();
let img = rc.read_to_image(DeviceIntRect::from_size(DeviceIntSize::new(w, h)))?; // RgbaImage
```

Host→renderer scripting is `WebView::evaluate_javascript(script, cb)`; preload
is `UserContentManager::add_script`. **Renderer→host messaging has no Servo
equivalent yet** (no `window.webkit.messageHandlers`); the IPC bridge must use
`console.log`-JSON interception (`ServoDelegate::show_console_message` /
`EmbedderMsg::ShowConsoleApiMessage`) until upstream PR #40513 lands.

## The blocker, precisely

```
libsqlite3-sys links to native lib `sqlite3`, conflicts with a previous package:
  servo → servo-storage → rusqlite 0.37 → libsqlite3-sys 0.35
  perry-ext-better-sqlite3 / perry-stdlib → rusqlite 0.32 → libsqlite3-sys 0.30
failed to select a version for `libsqlite3-sys`
```

No `[patch]` fixes this — the two `libsqlite3-sys` majors ship incompatible
bindgen output, and servo's storage can't drop sqlite. The conflict is at
resolution time, so it breaks the *whole workspace* the moment `servo` appears
in any Cargo.toml.

### It is NOT just rusqlite — it cascades into sqlx (attempted + reverted)

Bumping perry to `rusqlite 0.37` (→ libsqlite3-sys 0.35) was attempted. It then
collides with perry's **`sqlx 0.8.6`**: `sqlx 0.8.6` hard-pins
`sqlx-sqlite = "=0.8.6"` (pulled via the `macros` feature for `query!` offline
checking), and `sqlx-sqlite 0.8.6` pins `libsqlite3-sys` to the **0.30-era**
version — irreconcilable with rusqlite 0.37's 0.35. Three crates consume sqlx
(`perry-ext-mysql2`, `perry-ext-pg`, `perry-stdlib`). So the in-process unblock
is a **coordinated `rusqlite 0.32→0.37` AND `sqlx 0.8→0.9` migration across
perry's entire sqlite/mysql/postgres DB layer** — a large, high-regression-risk
change (validated only with live MySQL/Postgres + the full adapter suites), far
beyond a webview toggle. Attempt reverted; workspace restored.

## Paths forward

1. **Coordinated DB-layer migration** — bump `rusqlite 0.32→0.37` AND
   `sqlx 0.8→0.9` so the whole workspace unifies on `libsqlite3-sys 0.35`,
   migrating the API deltas in `perry-stdlib` (sqlite + sqlx), `perry-ext-better-sqlite3`,
   `perry-ext-mysql2`, `perry-ext-pg`, then re-validate sqlite/MySQL/Postgres/Drizzle.
   This is the gating prerequisite for *any* in-process Servo embedding and a
   significant standalone effort with real regression risk to perry's DB stack.
2. **Out-of-process Servo (recommended)** — run Servo in a child helper binary
   (its own dep graph, so the `libsqlite3-sys`/sqlx clash simply doesn't exist)
   and share a render surface (IOSurface) + an IPC channel with perry. Bigger
   architecture (the Verso/`versoview` model, now archived), but it sidesteps
   the entire conflict, isolates Servo crashes, and decouples Servo's heavy/
   churning dep tree from the perry workspace. Given the cascade above, this is
   the cleaner path.

## Integration design (for when unblocked)

- `Cargo.toml`: `servo-webview = ["dep:servo", "dep:url", "dep:dpi"]` (off by
  default — heavy: ~110 MB, the full servo stack).
- `webview::create`: read `PERRY_WEBVIEW`; if `servo` (+ feature), build a
  `ServoEngine` and register it in a `HashMap<i64, ServoEngine>` keyed by the
  same widget handle; otherwise the current WKWebView path.
- The webview FFIs (`load_url`, `evaluate_js`, `set_on_message`,
  `set_on_loaded`, `add_user_script`) check that map first and dispatch to
  `ServoEngine`, else WKWebView.
- `ServoEngine`: a child `NSView` in the window → `WindowRenderingContext`
  (raw-window-handle 0.6, `RawWindowHandle::AppKit { ns_view }`); `ServoBuilder`
  with an `EventLoopWaker` that `dispatch_async`es `spin_event_loop` to the main
  queue; `notify_new_frame_ready` → `paint()` + `present()`; `load` / `resize` /
  `evaluate_javascript` / `UserContentManager`; console.log-JSON IPC stopgap.
- Verifiable headlessly via the `SoftwareRenderingContext` + `read_to_image`
  probe above; on-screen display is GUI-verified.
