use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_layout_graph(
    port_: i64,
    number_of_nodes: u32,
    edges: *mut wire_list_rust_edge,
) {
    wire_layout_graph_impl(port_, number_of_nodes, edges)
}

#[no_mangle]
pub extern "C" fn wire_add(port_: i64, a: f32, b: f32) {
    wire_add_impl(port_, a, b)
}

#[no_mangle]
pub extern "C" fn wire_platform(port_: i64) {
    wire_platform_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_rust_release_mode(port_: i64) {
    wire_rust_release_mode_impl(port_)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_list_rust_edge_0(len: i32) -> *mut wire_list_rust_edge {
    let wrap = wire_list_rust_edge {
        ptr: support::new_leak_vec_ptr(<wire_RustEdge>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<Vec<RustEdge>> for *mut wire_list_rust_edge {
    fn wire2api(self) -> Vec<RustEdge> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<RustEdge> for wire_RustEdge {
    fn wire2api(self) -> RustEdge {
        RustEdge {
            from_index: self.from_index.wire2api(),
            to_index: self.to_index.wire2api(),
        }
    }
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_rust_edge {
    ptr: *mut wire_RustEdge,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RustEdge {
    from_index: u32,
    to_index: u32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_RustEdge {
    fn new_with_null_ptr() -> Self {
        Self {
            from_index: Default::default(),
            to_index: Default::default(),
        }
    }
}

impl Default for wire_RustEdge {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
