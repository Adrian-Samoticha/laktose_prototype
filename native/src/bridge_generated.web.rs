use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_layout_graph(port_: MessagePort, number_of_nodes: u32, edges: JsValue) {
    wire_layout_graph_impl(port_, number_of_nodes, edges)
}

#[wasm_bindgen]
pub fn wire_add(port_: MessagePort, a: f32, b: f32) {
    wire_add_impl(port_, a, b)
}

#[wasm_bindgen]
pub fn wire_platform(port_: MessagePort) {
    wire_platform_impl(port_)
}

#[wasm_bindgen]
pub fn wire_rust_release_mode(port_: MessagePort) {
    wire_rust_release_mode_impl(port_)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<Vec<RustEdge>> for JsValue {
    fn wire2api(self) -> Vec<RustEdge> {
        self.dyn_into::<JsArray>()
            .unwrap()
            .iter()
            .map(Wire2Api::wire2api)
            .collect()
    }
}
impl Wire2Api<RustEdge> for JsValue {
    fn wire2api(self) -> RustEdge {
        let self_ = self.dyn_into::<JsArray>().unwrap();
        assert_eq!(
            self_.length(),
            2,
            "Expected 2 elements, got {}",
            self_.length()
        );
        RustEdge {
            from_index: self_.get(0).wire2api(),
            to_index: self_.get(1).wire2api(),
        }
    }
}

// Section: impl Wire2Api for JsValue

impl Wire2Api<f32> for JsValue {
    fn wire2api(self) -> f32 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<u32> for JsValue {
    fn wire2api(self) -> u32 {
        self.unchecked_into_f64() as _
    }
}
