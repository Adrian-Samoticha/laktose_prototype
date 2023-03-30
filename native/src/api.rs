use fdg_sim::{
    force, petgraph::stable_graph::NodeIndex, ForceGraph, ForceGraphHelper, Simulation,
    SimulationParameters,
};

// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

// A plain enum without any fields. This is similar to Dart- or C-style enums.
// flutter_rust_bridge is capable of generating code for enums with fields
// (@freezed classes in Dart and tagged unions in C).
pub enum Platform {
    Unknown,
    Android,
    Ios,
    Windows,
    Unix,
    MacOS(String),
    Wasm,
}

/// Represents an edge between two vertices in a graph.
///
/// # Fields
///
/// * `from_index` - The index of the vertex this edge originates from
/// * `to_index` - The index of the vertex this edge terminates at
#[derive(Clone)]
pub struct RustEdge {
    pub from_index: u32,
    pub to_index: u32,
}

#[derive(Clone)]
pub struct Position {
    pub x: f32,
    pub y: f32,
    pub z: f32,
}

pub fn layout_graph(number_of_nodes: u32, edges: Vec<RustEdge>) -> Vec<Position> {
    let mut graph: ForceGraph<(), ()> = ForceGraph::default();

    let nodes: Vec<NodeIndex> = (0..number_of_nodes)
        .map(|i| graph.add_force_node(i.to_string(), ()))
        .collect();

    for edge in edges {
        graph.add_edge(
            nodes[edge.from_index as usize],
            nodes[edge.to_index as usize],
            (),
        );
    }

    let mut simulation = Simulation::from_graph(
        graph,
        SimulationParameters::new(
            200.0,
            fdg_sim::Dimensions::Three,
            force::fruchterman_reingold(2.0, 0.975),
        ),
    );

    for _ in 0..1000 {
        simulation.update(0.0015);
    }

    simulation
        .get_graph()
        .node_weights()
        .map(|weight| Position {
            x: weight.location.x,
            y: weight.location.y,
            z: weight.location.z,
        })
        .collect()
}

/// Adds two floating point numbers `a` and `b` and returns the result.
///
/// # Parameters
///
/// * `a` - The first number to add
/// * `b` - The second number to add
///
/// # Returns
///
/// The sum of `a` and `b` as a floating point number
pub fn add(a: f32, b: f32) -> f32 {
    a + b
}

// A function definition in Rust. Similar to Dart, the return type must always be named
// and is never inferred.
pub fn platform() -> Platform {
    // This is a macro, a special expression that expands into code. In Rust, all macros
    // end with an exclamation mark and can be invoked with all kinds of brackets (parentheses,
    // brackets and curly braces). However, certain conventions exist, for example the
    // vector macro is almost always invoked as vec![..].
    //
    // The cfg!() macro returns a boolean value based on the current compiler configuration.
    // When attached to expressions (#[cfg(..)] form), they show or hide the expression at compile time.
    // Here, however, they evaluate to runtime values, which may or may not be optimized out
    // by the compiler. A variety of configurations are demonstrated here which cover most of
    // the modern oeprating systems. Try running the Flutter application on different machines
    // and see if it matches your expected OS.
    //
    // Furthermore, in Rust, the last expression in a function is the return value and does
    // not have the trailing semicolon. This entire if-else chain forms a single expression.
    if cfg!(windows) {
        Platform::Windows
    } else if cfg!(target_os = "android") {
        Platform::Android
    } else if cfg!(target_os = "ios") {
        Platform::Ios
    } else if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
        Platform::MacOS("Apple Silicon".into())
    } else if cfg!(target_os = "macos") {
        Platform::MacOS("Intel".into())
    } else if cfg!(target_family = "wasm") {
        Platform::Wasm
    } else if cfg!(unix) {
        Platform::Unix
    } else {
        Platform::Unknown
    }
}

// The convention for Rust identifiers is the snake_case,
// and they are automatically converted to camelCase on the Dart side.
pub fn rust_release_mode() -> bool {
    cfg!(not(debug_assertions))
}
