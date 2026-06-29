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
- ⛔ **In-process integration is BLOCKED by a dependency conflict**: servo pulls
  `rusqlite 0.37 → libsqlite3-sys 0.35`; perry uses `rusqlite 0.32 →
  libsqlite3-sys 0.30`. Both declare `links = "sqlite3"`, and Cargo forbids two
  versions of a `links` native lib in one workspace lockfile. This fails at
  **dependency-resolution time**, so `servo` cannot be added even as an
  *optional* dep of any perry crate until perry's `rusqlite` is aligned to 0.37.

So the **engine is proven workable**; the **perry integration has a hard
prerequisite** (a perry-core `rusqlite` bump) or needs an out-of-process design.

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

## Paths forward

1. **Align perry to `rusqlite 0.37` (libsqlite3-sys 0.35)** — bump it in
   `perry-stdlib` + `perry-ext-better-sqlite3`, migrate the API deltas (0.32→0.37),
   and re-validate perry's sqlite (better-sqlite3 / node:sqlite / Drizzle). This
   is a **separate, breaking, test-heavy perry-core change** and the gating
   prerequisite for *any* in-process Servo embedding. Once done, the
   `servo-webview` feature + `ServoEngine` (below) drop in.
2. **Out-of-process Servo** — run Servo in a child helper binary (its own dep
   graph, so no `libsqlite3-sys` clash) and share a render surface (IOSurface)
   + an IPC channel with perry. Bigger architecture (the Verso/`versoview`
   model, now archived), but it sidesteps the conflict and isolates crashes.

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
