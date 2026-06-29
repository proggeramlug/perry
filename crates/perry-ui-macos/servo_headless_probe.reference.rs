// Standalone reference (NOT a workspace member — see SERVO_WEBVIEW.md for why).
// Headless Servo render probe: render a known page offscreen (CPU/software
// rendering context), read the pixel buffer back, and verify the page actually
// rendered (expected red background). Proves Servo runs + renders without a GUI.
use std::cell::Cell;
use std::rc::Rc;
use std::time::Duration;

use dpi::PhysicalSize;
use servo::{
    DeviceIntRect, DeviceIntSize, LoadStatus, RenderingContext, ServoBuilder,
    SoftwareRenderingContext, WebView, WebViewBuilder, WebViewDelegate,
};
use url::Url;

#[derive(Clone)]
struct NoopWaker;
impl servo::EventLoopWaker for NoopWaker {
    fn clone_box(&self) -> Box<dyn servo::EventLoopWaker> {
        Box::new(self.clone())
    }
    fn wake(&self) {}
}

#[derive(Default)]
struct State {
    loaded: Cell<bool>,
    frames: Cell<u32>,
}
impl WebViewDelegate for State {
    fn notify_load_status_changed(&self, _wv: WebView, status: LoadStatus) {
        if matches!(status, LoadStatus::Complete) {
            self.loaded.set(true);
        }
    }
    fn notify_new_frame_ready(&self, _wv: WebView) {
        self.frames.set(self.frames.get() + 1);
    }
}

fn main() {
    let (w, h) = (400u32, 300u32);
    let rc = Rc::new(
        SoftwareRenderingContext::new(PhysicalSize::new(w, h)).expect("software rendering context"),
    );
    let _ = rc.make_current();

    let servo = ServoBuilder::default()
        .event_loop_waker(Box::new(NoopWaker))
        .build();

    let state = Rc::new(State::default());
    let html = "data:text/html,<html><body style='margin:0;background:rgb(255,0,0)'>\
                <h1 style='color:white'>SERVO OK</h1></body></html>";
    let webview = WebViewBuilder::new(&servo, rc.clone())
        .url(Url::parse(html).expect("url"))
        .delegate(state.clone())
        .build();
    webview.focus();
    webview.resize(PhysicalSize::new(w, h));

    // Spin the engine until the page reports load-complete (or time out).
    let mut spins = 0;
    while !state.loaded.get() && spins < 6000 {
        servo.spin_event_loop();
        spins += 1;
        std::thread::sleep(Duration::from_millis(2));
    }

    // Drive a few frames and present so the framebuffer has the painted page.
    for _ in 0..150 {
        servo.spin_event_loop();
        webview.paint();
        rc.present();
        std::thread::sleep(Duration::from_millis(4));
    }

    let rect = DeviceIntRect::from_size(DeviceIntSize::new(w as i32, h as i32));
    match rc.read_to_image(rect) {
        Some(img) => {
            let (iw, ih) = (img.width(), img.height());
            let raw = img.as_raw();
            let mut red = 0u64;
            let mut nonwhite = 0u64;
            for px in raw.chunks_exact(4) {
                let (r, g, b) = (px[0], px[1], px[2]);
                if r > 180 && g < 80 && b < 80 {
                    red += 1;
                }
                if !(r > 240 && g > 240 && b > 240) {
                    nonwhite += 1;
                }
            }
            let total = (iw as u64) * (ih as u64);
            println!(
                "RENDER loaded={} frames={} size={}x{} red={}/{} nonwhite={}/{}",
                state.loaded.get(),
                state.frames.get(),
                iw,
                ih,
                red,
                total,
                nonwhite,
                total
            );
            if red > total / 4 {
                println!("SERVO_RENDER_OK");
            } else {
                println!("SERVO_RENDER_UNCERTAIN");
            }
        }
        None => println!("SERVO_RENDER_FAIL read_to_image=None"),
    }
}
