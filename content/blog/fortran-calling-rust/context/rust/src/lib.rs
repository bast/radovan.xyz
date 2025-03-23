use once_cell::sync::Lazy;
use std::sync::Mutex;

static GLOBAL_STATE: Lazy<Mutex<Option<State>>> =
    Lazy::new(|| Mutex::new(Some(State { value: 0 })));

struct State {
    value: i32,
}

#[unsafe(no_mangle)]
pub extern "C" fn initialize() {
    let mut state = GLOBAL_STATE.lock().unwrap();
    *state = Some(State { value: 42 });
    println!("initialized");
}

#[unsafe(no_mangle)]
pub extern "C" fn query() -> i32 {
    let state = GLOBAL_STATE.lock().unwrap();

    match state.as_ref() {
        Some(s) => s.value,
        None => {
            println!("query failed: state is uninitialized");
            -1 // return an error code or default value
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn finalize() {
    let mut state = GLOBAL_STATE.lock().unwrap();
    *state = None; // drop the data
    println!("finalized and deallocated");
}
