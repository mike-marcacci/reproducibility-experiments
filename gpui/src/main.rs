use gpui::*;

struct Content;

impl Render for Content {
    fn render(&mut self, _cx: &mut ViewContext<Self>) -> impl IntoElement {
        div()
            .flex()
            .flex_col()
            .size_full()
            .justify_center()
            .items_center()
            .bg(rgb(0x17191c))
            .child(
                div()
                    .flex()
                    .flex_col()
                    .size_full()
                    .text_xl()
                    .justify_center()
                    .items_center()
                    .text_color(rgb(0xffffff))
                    .child("Hello from GPUI!"),
            )
    }
}

fn main() {
    App::new().run(|cx: &mut AppContext| {
        cx.open_window(
            WindowOptions {
                window_bounds: Some(WindowBounds::Windowed(Bounds::centered(
                    None,
                    size(px(320.0), px(80.0)),
                    cx,
                ))),
                ..Default::default()
            },
            |cx| cx.new_view(|_cx| Content),
        )
        .unwrap();
    });
}
